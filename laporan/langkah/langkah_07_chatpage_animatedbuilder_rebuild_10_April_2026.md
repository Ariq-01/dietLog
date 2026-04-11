# Langkah Fix #7 — ChatPage AnimatedBuilder Rebuild Seluruh List

## Masalah
Pattern: `ExpensiveBuildComputation` (related)

`AnimatedBuilder` di `ChatPage` rebuild SELURUH `CustomScrollView` + `SliverList` saat ada message baru → meskipun hanya 1 message yang ditambahkan, seluruh widget tree di bawah AnimatedBuilder di-recreate.

## Current (Entire)
- **File:** `lib/features/home/pages/chat_page.dart`
- **Line:** 20-43
- **Behavior:** `AnimatedBuilder(animation: chatVm)` → saat `notifyListeners()` dipanggil (message baru atau loading berubah), SELURUH builder dipanggil → CustomScrollView + SliverList di-recreate
- **Root cause:** AnimatedBuilder wrap seluruh CustomScrollView
- **Code:**
```dart
@override
Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: chatVm,  // ← Rebuild saat ada perubahan di ViewModel
    builder: (context, _) {
      final shouldShowLoading = chatVm.isLoading && chatVm.messages.isNotEmpty;
      final messageCount = shouldShowLoading
          ? chatVm.messages.length - 1
          : chatVm.messages.length;

      return CustomScrollView(  // ← SELURUH INI di-recreate
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ChatBubble(message: chatVm.messages[index]),
              childCount: messageCount,
            ),
          ),
          if (shouldShowLoading)
            SliverToBoxAdapter(
              child: LoadingUserMessage(userMessage: chatVm.messages.last.content),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      );
    },
  );
}
```

## Target
- **Behavior:** AnimatedBuilder tetap rebuild, tapi dampannya minimal — hanya message baru yang di-render, existing messages tidak rebuild
- **Output:** Chat tetap smooth saat message baru ditambahkan
- **Metric:** Dampak minor — SliverChildBuilderDelegate sudah lazy, tapi bisa lebih baik dengan key per item

## Constraints
- Tidak boleh mengubah ChatViewModel
- Tidak boleh mengubah visual output
- Sliver system harus tetap dipakai (bukan ListView)
- Pattern pencegahan: "Consumer harus se-kecil mungkin" + "Compute Once, Use Many"

## Langkah Penyelesaian

### Step 1 — Buka file
`lib/features/home/pages/chat_page.dart`

### Step 2 — Tambahkan ValueKey per ChatBubble
Ganti SliverChildBuilderDelegate dengan builder yang punya key per item:

```dart
SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) {
      final message = chatVm.messages[index];
      return KeyedSubtree(
        key: ValueKey('${message.timestamp.millisecondsSinceEpoch}'),
        child: ChatBubble(message: message),
      );
    },
    childCount: messageCount,
  ),
),
```

### Step 3 — Extract LoadingUserMessage dengan key
```dart
if (shouldShowLoading)
  SliverToBoxAdapter(
    key: const ValueKey('loading_message'),
    child: LoadingUserMessage(userMessage: chatVm.messages.last.content),
  ),
```

### Step 4 — Verify
Code menjadi:
```dart
@override
Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: chatVm,
    builder: (context, _) {
      final shouldShowLoading = chatVm.isLoading && chatVm.messages.isNotEmpty;
      final messageCount = shouldShowLoading
          ? chatVm.messages.length - 1
          : chatVm.messages.length;

      return CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final message = chatVm.messages[index];
                return KeyedSubtree(
                  key: ValueKey('${message.timestamp.millisecondsSinceEpoch}'),
                  child: ChatBubble(message: message),
                );
              },
              childCount: messageCount,
            ),
          ),
          if (shouldShowLoading)
            SliverToBoxAdapter(
              key: const ValueKey('loading_message'),
              child: LoadingUserMessage(userMessage: chatVm.messages.last.content),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      );
    },
  );
}
```

### Step 5 — Test
- Kirim pesan → user bubble muncul → loading muncul → AI response muncul
- Existing messages tidak rebuild (tetap di posisi, tidak flicker)
- Loading message muncul/hilang smooth

## Verifikasi Berhasil
- ✅ `ValueKey` ada di setiap `ChatBubble` (via `KeyedSubtree`)
- ✅ Loading message punya `ValueKey('loading_message')`
- ✅ Existing messages tidak rebuild saat message baru ditambahkan
- ✅ Tidak ada flicker atau visual glitch
- ✅ Scroll tetap smooth
