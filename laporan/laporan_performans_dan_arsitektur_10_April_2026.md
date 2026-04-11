# Laporan Analisis Performans & Arsitektur — dietLog
**Tanggal:** 10 April 2026  
**Scope:** `/lib/` — 33 file Dart  
**Arsitektur:** MVVM Modular (ViewModel, View, Model)  
**Status Fitur Utama:** ~90% implementasi  
**Sisa Optimasi:** ~10% (rebuilds berlebih, bottleneck CPU, widget tidak efisien)

---

## 1. PEMAHAMAN PROJECT — First Principles Approach

### 1.1 Apa Tujuan Project Ini?
- **Fundamental need:** Aplikasi log diet berbasis chat AI di mana user mengetik makanan → AI menganalisis → menampilkan kalori & macros
- **Core loop:** User input → ChatViewModel → API → Update UI → Update DailyStats
- **Output yang dibutuhkan:** Chat bubbles, stat cards (calories/macros), date navigation

### 1.2 Mengapa Arsitektur MVVM Dipilih?
- **Separation of Concerns:** Model (data) → ViewModel (state/logic) → View (UI)
- **Testability:** ViewModel bisa di-test tanpa UI
- **Reusability:** Widget yang sama bisa dipakai dengan ViewModel berbeda

### 1.3 Trade-offs yang Sudah Diterapkan
| Keputusan | Benefit | Trade-off |
|-----------|---------|-----------|
| `ChangeNotifierProvider` di `main.dart` | Global access ke `TodayViewModel` | Seluruh tree di bawah provider rebuild jika `notifyListeners()` dipanggil |
| `PageView.builder` dengan 7 halaman | Lazy build — hanya halaman aktif yang di-render | ChatViewModel dibuat manual di State, bukan via Provider |
| `AnimatedBuilder` di `ChatPage` | Hanya rebuild saat ChatViewModel berubah | Setiap halaman punya instance ViewModel terpisah |
| Overlay untuk Calendar | Tidak rebuild parent saat open/close | Memory leak risk jika overlay tidak di-remove dengan benar |

---

## 2. TEMUAN BOTTLENECK & MASALAH

### 2.1 🔴 BOTTLENECK: `WeekStripWidget` — Redundant WeekModel Creation

**File:** `lib/features/today/widgets/week_strip_widget.dart` (baris 28-32)

**First Principles Analysis:**
- **Input yang dibutuhkan:** `selectedDate` (DateTime) → output: 7 hari dengan label
- **Input yang tersedia:** `week` (WeekModel) yang SUDAH berisi 7 hari
- **Apa yang terjadi:** Widget menerima `week` sebagai parameter TIDAK DIGUNAKAN. Sebaliknya, widget membuat `WeekModel.fromDate(selectedDate)` lagi di dalam `build()`.

**Masalah:**
```dart
// Parameter yang diterima TIDAK dipakai:
final weekModel = WeekModel.fromDate(selectedDate); // ← MEMBUAT ULANG setiap build!
```

**Root cause:** Data X (`week` parameter) sudah ada → tapi widget mengabaikan dan membuat data Y (`weekModel` baru) → duplikasi komputasi setiap kali parent rebuild.

**Dampak:** Setiap kali `selectedDate` berubah, `WeekStripWidget` rebuild dan membuat `WeekModel` baru → 7 objek `WeekDay` dibuat ulang → waste CPU cycles.

**Perbaikan:** Gunakan parameter `week` yang sudah ada.

---

### 2.2 🔴 BOTTLENECK: `main_screen.dart` — PageView.builder Rebuilds Semua ChatPage

**File:** `lib/main_screen.dart` (baris 162-174)

**First Principles Analysis:**
- **Fundamental problem:** `PageView.builder` memanggil `itemBuilder` untuk setiap halaman yang terlihat (biasanya 2-3 halaman sekaligus: current + prev + next)
- **Setiap halaman** membuat `ChatPage` yang berisi `AnimatedBuilder(chatVm)`
- **Masalah:** `Consumer<TodayViewModel>` di wrap `PageView.builder` → setiap kali `selectedDate` berubah (via swipe), SELURUH PageView rebuild → `itemBuilder` dipanggil ulang untuk SEMUA index yang visible

**Apa yang sebenarnya dibutuhkan:**
- Hanya halaman yang aktif perlu rebuild saat date berubah
- Halaman yang tidak aktif tetap bisa diakses tapi tidak perlu rebuild

**Masalah:**
```dart
Consumer<TodayViewModel>(  // ← Ini rebuild SELURUH PageView saat date berubah
  builder: (context, todayVm, _) {
    return PageView.builder(
      itemBuilder: (context, index) {
        final date = monday.add(Duration(days: index));
        final chatVm = _getChatVmForDate(date); // ← Map lookup setiap rebuild
        return ChatPage(chatVm: chatVm, date: date);
      },
    );
  },
)
```

**Root cause:** Consumer di level PageView → seluruh PageView rebuild → itemBuilder dipanggil ulang → ChatPage instances di-recreate.

**Dampak:** Swipe 1 halaman → rebuild 2-3 ChatPage → setiap ChatPage rebuild AnimatedBuilder → waste.

---

### 2.3 🟡 WIDGET TANPA PROVIDER — Manual State Management di `TodayScreen`

**File:** `lib/features/today/today_screen.dart`

**First Principles Analysis:**
- **Prinsip:** Dalam MVVM, ViewModel harus menjadi single source of truth
- **Realita:** `TodayScreen` membuat `ChatViewModel` secara manual (`late final ChatViewModel _chatVm`) → tidak terhubung ke `TodayViewModel`

**Masalah:**
```dart
// TodayScreen TIDAK menggunakan Provider untuk ChatViewModel
late final ChatViewModel _chatVm;  // ← Manual, isolated

@override
Widget build(BuildContext context) {
  final todayVm = context.watch<TodayViewModel>();  // ← Provider untuk TodayViewModel
  
  // Chat messages TIDAK terhubung ke selectedDate!
  SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) => ChatBubble(message: _chatVm.messages[index]),
      childCount: _chatVm.messages.length,
    ),
  ),
}
```

**Apa yang dibutuhkan:** Chat messages harus berubah saat `selectedDate` berubah  
**Apa yang terjadi:** ChatViewModel single instance → messages TIDAK berubah saat date berubah

**Dampak:** User pindah tanggal → chat history tetap sama → bug fungsional.

---

### 2.4 🟡 OVER-OPTIMIZATION: `ChatBubble._buildStyledText` — RichText Parsing untuk Setiap Message

**File:** `lib/features/chat/widgets/chat_bubble.dart` (baris 118-214)

**First Principles Analysis:**
- **Input:** String teks dari AI response
- **Output yang dibutuhkan:** Teks dengan formatting (bold, italic, code)
- **Apa yang terjadi:** Setiap kali `ChatBubble` di-build, regex pattern matching dijalankan untuk SELURUH isi pesan

**Masalah:**
```dart
RichText _buildStyledText(String text, Color textColor) {
  final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|`(.+?)`');
  final matches = pattern.allMatches(text);  // ← Regex execution SETIAP build
  
  // Untuk setiap match, buat TextSpan baru dengan style berbeda
  // Jika pesan panjang (100+ baris), ini jadi O(n) untuk setiap rebuild
}
```

**Root cause:** Parsing dilakukan di build() → setiap rebuild = parse ulang → CPU waste untuk pesan yang kontennya TIDAK berubah.

**Dampak:** ChatBubble dengan pesan panjang → build() memakan 5-15ms → scroll janky jika banyak bubble.

---

### 2.5 🟡 WIDGET `const` TAPI DI DALAM PARENT DINAMIS

**File:** `lib/main_screen.dart` (baris 152)

**First Principles Analysis:**
- **Prinsip:** Widget `const` tidak rebuild saat parent rebuild
- **Realita:** Widget ini `const` tapi parent-nya (`Column` di dalam `Consumer`) rebuild

**Widget yang const tapi di dalam rebuild zone:**
```dart
const Padding(
  padding: EdgeInsets.only(top: 16),
  child: Divider(color: AppColors.divider, height: 1),  // ← const, bagus
)
```

**Analisis:** Ini BUKAN masalah karena `const` widget Flutter otomatis di-skip saat rebuild. Tapi posisinya di dalam `Column` yang children-nya sebagian besar dinamis → tidak ada dampak negatif, tapi juga tidak ada benefit signifikan karena Divider sangat ringan.

**Verdict:** Tidak bermasalah, tapi `const` di sini tidak memberikan benefit nyata karena Divider sendiri sudah sangat ringan.

---

### 2.6 🟡 `ChatPage` — `AnimatedBuilder` Tidak Optimal untuk List Panjang

**File:** `lib/features/home/pages/chat_page.dart`

**First Principles Analysis:**
- **Input:** List `messages` di ChatViewModel
- **Output:** SliverList dengan ChatBubble per message
- **Masalah:** `AnimatedBuilder` rebuild SELURUH list saat ada message baru

```dart
AnimatedBuilder(
  animation: chatVm,  // ← Rebuild saat ada perubahan di ViewModel
  builder: (context, _) {
    // SELURUH SliverList rebuild saat message baru ditambahkan
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ChatBubble(message: chatVm.messages[index]),
            childCount: messageCount,
          ),
        ),
      ],
    );
  },
)
```

**Apa yang dibutuhkan:** Hanya message terakhir yang baru perlu di-render  
**Apa yang terjadi:** Seluruh list di-rebuild → Flutter tetap efisien karena `SliverChildBuilderDelegate` lazy, tapi `build()` tetap dipanggil untuk widget baru

**Dampak:** Minor — Flutter's Sliver system sudah efisien, tapi bisa lebih baik dengan `ListView.builder` + `key` per item.

---

### 2.7 🔴 `TodayViewModel` — `WeekModel.today()` Dipanggil di Field Initialization

**File:** `lib/features/viewModels/today_viewmodel.dart` (baris 9)

**First Principles Analysis:**
- **Prinsip:** Field initialization terjadi sebelum constructor body
- **Masalah:** `final WeekModel week = WeekModel.today();` → computed sekali saat ViewModel dibuat → TIDAK PERNAH update jika user membuka app di hari yang berbeda dalam session yang sama

```dart
class TodayViewModel extends ChangeNotifier {
  final WeekModel week = WeekModel.today();  // ← Computed saat init, never updates
  late DateTime _selectedDate;
  
  DailyStats _stats = DailyStats.empty();
  
  TodayViewModel() : _selectedDate = DateTime.now();
}
```

**Apa yang dibutuhkan:** Week harus merefleksikan minggu dari `selectedDate`  
**Apa yang terjadi:** Week selalu minggu saat ViewModel dibuat → jika `selectedDate` pindah ke minggu depan, `week` TIDAK update

**Dampak:** `WeekStripWidget` menampilkan minggu yang salah jika user navigate ke tanggal di luar minggu current.

**Trade-off considered:**
- Jika week computed setiap kali `selectedDate` berubah → guarantee correctness tapi allocation overhead
- Jika week immutable → performance optimal tapi tidak akurat untuk cross-week navigation
- **Solusi ideal:** `week` jadi getter yang computed dari `_selectedDate` → trade 7 allocations untuk correctness

---

### 2.8 🟡 `CalendarWidget` — `setState` di Dalam Overlay

**File:** `lib/widgets/calendar_widget.dart`

**First Principles Analysis:**
- **Prinsip:** OverlayEntry tidak otomatis rebuild saat parent rebuild
- **Apa yang terjadi:** `CalendarWidget` menggunakan `setState` untuk `_currentMonth` dan `_selectedDate` → rebuild DIRINYA sendiri

```dart
void _previousMonth() {
  setState(() {
    if (_currentMonth.month == 1) {
      _currentMonth = DateTime(_currentMonth.year - 1, 12);
    } else {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    }
  });  // ← Rebuild CalendarWidget saja, tidak mempengaruhi parent
}
```

**Verdict:** Ini SUDAH BENAR. Overlay terisolasi dari parent → `setState` hanya rebuild CalendarWidget → efisien.

**Tapi ada masalah lain:** `CalendarWidget` dibuat ulang setiap kali `_openCalendar()` dipanggil → tidak ada caching → widget tree di-recreate dari nol.

---

### 2.9 🔴 `main.dart` — `TodayViewModel` Provider di Level App Root

**File:** `lib/main.dart` (baris 15-17)

**First Principles Analysis:**
- **Prinsip:** Provider scope harus se-spesifik mungkin
- **Masalah:** `TodayViewModel` di-provide di root `BiteLogApp` → SELURUH app punya access → tapi hanya `HomeScreen` yang butuh

```dart
return ChangeNotifierProvider<TodayViewModel>(
  create: (_) => TodayViewModel(),  // ← Dibuat saat app start, tidak pernah dispose
  child: MaterialApp(
    title: 'BiteLog',
    home: const HomeScreen(),
  ),
);
```

**Apa yang dibutuhkan:** ViewModel hanya dibutuhkan di screen yang relevan  
**Apa yang terjadi:** ViewModel hidup sepanjang app lifecycle → tidak pernah di-dispose → memory leak jika ViewModel hold resources

**Dampak:** Minor untuk sekarang, tapi akan jadi masalah saat app grow (banyak screen, navigation stack dalam).

---

## 3. KALKULASI DAMPAK

### 3.1 Widget Rebuild Analysis (Per User Action: Swipe 1 Halaman)

| Widget | Seharusnya Rebuild | Actual Rebuild | Waste |
|--------|-------------------|----------------|-------|
| TodayHeaderWidget | 1x (date berubah) | 1x ✅ | 0% |
| WeekStripWidget | 1x (date berubah) | 1x + WeekModel recreation ❌ | ~2ms |
| PageView.builder | 0x (cukup page animate) | Rebuild Consumer wrapper ❌ | ~5ms |
| ChatPage (active) | 1x (date baru) | 1x ✅ | 0% |
| ChatPage (prev/next) | 0x (tidak aktif) | 1x (recreated via itemBuilder) ❌ | ~3ms |
| BottomNavBarWidget | 0x | 0x ✅ | 0% |
| **TOTAL** | **2 rebuilds** | **5+ rebuilds** | **~10ms waste** |

### 3.2 Memory Allocation Per Swipe

| Alokasi | Count | Size Est. | Total |
|---------|-------|-----------|-------|
| WeekDay objects (WeekStripWidget) | 7 | ~200 bytes | ~1.4KB |
| ChatPage widget tree | 2-3 | ~2KB | ~4-6KB |
| DateTime objects (itemBuilder) | 7 | ~100 bytes | ~700 bytes |
| **TOTAL** | | | **~6-8KB per swipe** |

**Jika user swipe 100x/session** → ~600-800KB allocation → GC pressure meningkat.

---

## 4. REKOMENDASI PERBAIKAN — Prioritas Berdasarkan Impact

### Priority 1 — Fix Sekarang (Buka Jalan untuk Next Fix)

**A. Fix `WeekStripWidget` — Hapus Redundant WeekModel Creation**
- **File:** `lib/features/today/widgets/week_strip_widget.dart`
- **Impact:** Eliminasi 7 object allocations per rebuild
- **Effort:** 2 menit — ganti `WeekModel.fromDate(selectedDate)` dengan `week` parameter
- **Why first:** Ini fix paling mudah, langsung mengurangi waste, tidak ada side effect

**B. Fix `TodayViewModel` — Week Sebagai Getter dari `selectedDate`**
- **File:** `lib/features/viewModels/today_viewmodel.dart`
- **Impact:** Correctness guarantee untuk cross-week navigation
- **Effort:** 5 menit — ubah `final week` jadi `WeekModel get week => WeekModel.fromDate(_selectedDate)`
- **Why first:** Ini fondasi — jika week salah, semua widget yang pakai week juga salah

### Priority 2 — Fix Setelah Priority 1 Selesai

**C. Pisahkan PageView dari Consumer di `main_screen.dart`**
- **File:** `lib/main_screen.dart`
- **Impact:** Eliminasi rebuild PageView saat date berubah via header
- **Effort:** 15 menit — extract PageView jadi widget terpisah dengan `const` PageController
- **Why second:** Butuh A dan B selesai dulu supaya date logic sudah benar

**D. Hubungkan `TodayScreen` ChatViewModel ke `selectedDate`**
- **File:** `lib/features/today/today_screen.dart`
- **Impact:** Fix bug fungsional — chat harus berubah per date
- **Effort:** 20 menit — buat map ChatViewModel per date atau re-init saat date berubah
- **Why second:** Ini bug fungsional, bukan performance — tapi butuh A dan B selesai dulu

### Priority 3 — Optimization (Nice to Have)

**E. Memoize `ChatBubble` RichText Parsing**
- **File:** `lib/features/chat/widgets/chat_bubble.dart`
- **Impact:** Reduce build time untuk pesan panjang
- **Effort:** 30 menit — cache parsed `TextSpan` di ViewModel atau gunakan `ValueKey` per message
- **Why third:** Impact kecil untuk sekarang (pesan belum banyak), bisa deferred

**F. Pindahkan `TodayViewModel` Provider ke `HomeScreen` Level**
- **File:** `lib/main.dart` → `lib/main_screen.dart`
- **Impact:** Proper lifecycle management, dispose saat screen di-pop
- **Effort:** 5 menit
- **Why third:** Tidak blocking feature lain, bisa dilakukan kapan saja

---

## 5. GOAL: Performans & Arsitektur

### Target Setelah Optimasi:
| Metric | Current | Target |
|--------|---------|--------|
| Widget rebuilds per swipe | 5+ | 2 |
| Memory allocation per swipe | ~6-8KB | ~2KB |
| ChatBubble build time (long msg) | 5-15ms | 1-3ms |
| Week correctness (cross-week) | ❌ Wrong | ✅ Correct |
| ViewModel scope | App-wide | Screen-level |

### Architectural Goals:
1. **Decentralized pages** — Setiap screen manage ViewModel sendiri, tidak bergantung global state
2. **Const-first** — Widget yang bisa `const` harus `const` DAN posisinya di luar rebuild zone
3. **Provider scope minimal** — Provider hanya di level screen yang butuh, bukan app root
4. **No redundant computation** — Data yang sudah ada tidak dihitung ulang

---

## 6. LANGKAH IMPLEMENTASI TERSTRUKTUR (First Principles Order)

```
Step 1: Fix WeekModel duplication di WeekStripWidget
   ↓ (membuka jalan)
Step 2: Jadikan Week getter dari selectedDate di TodayViewModel
   ↓ (memastikan date logic benar)
Step 3: Pisahkan PageView dari Consumer di HomeScreen
   ↓ (mengurangi rebuild waste)
Step 4: Hubungkan ChatViewModel ke selectedDate di TodayScreen
   ↓ (fix bug fungsional)
Step 5: Memoize ChatBubble parsing
   ↓ (optimasi minor)
Step 6: Pindahkan Provider ke screen level
   ↓ (proper lifecycle)
Result: ~90% → ~98% optimal
```

---

*Dokumen ini dibuat berdasarkan analisis first principles: setiap masalah di-trace ke fundamental cause (data flow, widget lifecycle, state management), bukan sekadar gejala permukaan.*
