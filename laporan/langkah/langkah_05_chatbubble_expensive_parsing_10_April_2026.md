# Langkah Fix #5 — ChatBubble RichText Parsing di build()

## Masalah
Pattern: `ExpensiveBuildComputation`

`ChatBubble._buildStyledText()` menjalankan regex parsing + string manipulation di `build()` → setiap kali ChatBubble di-build (termasuk saat parent rebuild, scroll, dll), regex dijalankan ulang untuk SELURUH isi pesan → O(n) complexity per build.

## Current (Entire)
- **File:** `lib/features/chat/widgets/chat_bubble.dart`
- **Line:** 118-214
- **Behavior:** Setiap `build()` → `_buildStyledText()` dipanggil → `RegExp.allMatches()` dijalankan → loop melalui semua matches → buat TextSpan per match → 5-15ms untuk pesan 500+ karakter
- **Root cause:** Parsing dilakukan di build() padahal konten pesan TIDAK BERUBAH setelah message dibuat
- **Code:**
```dart
RichText _buildStyledText(String text, Color textColor) {
  final spans = <TextSpan>[];
  final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|`(.+?)`');
  final matches = pattern.allMatches(text);  // ← O(n) SETIAP BUILD

  if (matches.isEmpty) {
    spans.add(TextSpan(text: text, style: ...));
  } else {
    var lastIndex = 0;
    for (final match in matches) {  // ← LOOP SETIAP BUILD
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start), ...));
      }
      // ... buat formatted TextSpan ...
      lastIndex = match.end;
    }
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), ...));
    }
  }
  return RichText(text: TextSpan(children: spans));
}
```

## Target
- **Behavior:** Parsing dilakukan SEKALI saat ChatMessage dibuat → hasilnya di-cache → build() hanya pakai cached result → O(1) per build
- **Output:** Visual formatting sama (bold, italic, code tetap berfungsi)
- **Metric:** ChatBubble build time: 5-15ms → 1-3ms

## Constraints
- Tidak boleh mengubah class ChatMessage (hanya tambahkan field baru)
- Tidak boleh mengubah visual output
- Regex pattern harus tetap sama
- Pattern pencegahan: "Jika komputasi hanya bergantung pada input yang tidak berubah setelah objek dibuat → lakukan sekali di constructor/factory, bukan di build()"

## Langkah Penyelesaian

### Step 1 — Buka file
`lib/features/chat/models/chat_message.dart`

### Step 2 — Tambahkan cached parsed spans di ChatMessage
Tambahkan field dan method parsing:

```dart
import 'package:flutter/material.dart';

class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;
  
  // CACHED parsed spans
  late final List<TextSpan> parsedSpans = _parseContent(content);

  ChatMessage({required this.role, required this.content, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  static List<TextSpan> _parseContent(String text) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|`(.+?)`');
    final matches = pattern.allMatches(text);

    if (matches.isEmpty) {
      spans.add(
        TextSpan(
          text: text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            height: 1.6,
            letterSpacing: 0.2,
            wordSpacing: 1.5,
          ),
        ),
      );
    } else {
      var lastIndex = 0;
      for (final match in matches) {
        if (match.start > lastIndex) {
          spans.add(
            TextSpan(
              text: text.substring(lastIndex, match.start),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                height: 1.6,
                letterSpacing: 0.2,
                wordSpacing: 1.5,
              ),
            ),
          );
        }

        if (match.group(1) != null) {
          spans.add(
            TextSpan(
              text: match.group(1),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.6,
                letterSpacing: 0.2,
                wordSpacing: 1.5,
              ),
            ),
          );
        } else if (match.group(2) != null) {
          spans.add(
            TextSpan(
              text: match.group(2),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: const Color(0xFF1A1A1A).withValues(alpha: 0.9),
                fontStyle: FontStyle.italic,
                height: 1.6,
                letterSpacing: 0.2,
                wordSpacing: 1.5,
              ),
            ),
          );
        } else if (match.group(3) != null) {
          spans.add(
            TextSpan(
              text: match.group(3),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Color(0xFF8A8A8A),
                height: 1.6,
                letterSpacing: 0.2,
                wordSpacing: 1.5,
              ),
            ),
          );
        }

        lastIndex = match.end;
      }

      if (lastIndex < text.length) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.6,
              letterSpacing: 0.2,
              wordSpacing: 1.5,
            ),
          ),
        );
      }
    }

    return spans;
  }
}
```

### Step 3 — Buka file ChatBubble
`lib/features/chat/widgets/chat_bubble.dart`

### Step 4 — Hapus method `_buildStyledText` dan `_formatLongText`
Hapus seluruh method `_buildStyledText` (line 118-214) dan `_formatLongText` (line 85-115).

### Step 5 — Ganti `_buildMessageContent` untuk pakai cached spans
```dart
Widget _buildMessageContent(BuildContext context, bool isUser) {
  final textColor = isUser ? AppColors.activeDayText : AppColors.textPrimary;
  
  // For AI messages, use cached parsed spans
  if (!isUser) {
    // Apply textColor to cached spans
    final coloredSpans = message.parsedSpans.map((span) {
      return TextSpan(
        text: span.text,
        style: span.style?.copyWith(color: textColor),
      );
    }).toList();
    
    return RichText(text: TextSpan(children: coloredSpans));
  }

  // User messages stay simple
  return Text(
    message.content,
    style: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      color: isUser ? AppColors.activeDayText : AppColors.textPrimary,
      height: 1.5,
      letterSpacing: 0.2,
      wordSpacing: 1.2,
    ),
  );
}
```

### Step 6 — Verify
Tidak ada lagi `RegExp` atau `allMatches` di `build()` ChatBubble.

### Step 7 — Test
- Kirim pesan ke AI → response harus terformat (bold, italic, code)
- Scroll chat → harus smooth, tidak ada janky
- Pesan panjang (500+ karakter) → build time harus <3ms

## Verifikasi Berhasil
- ✅ `parsedSpans` ada di ChatMessage (cached)
- ✅ `_parseContent` adalah static method (dipanggil sekali di field init)
- ✅ Tidak ada `RegExp` di ChatBubble `build()`
- ✅ Visual formatting sama
- ✅ Scroll smooth (build time <3ms)
