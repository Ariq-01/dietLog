# Pola Kesalahan Berulang — dietLog
**Tanggal:** 10 April 2026  
**Source:** `laporan_performans_dan_arsitektur_10_April_2026.md`

---

## Patterns yang Ditemukan

Dokumen ini berisi **pola kesalahan yang muncul berulang kali** di berbagai file dalam project. Setiap pattern dijelaskan dengan root cause, contoh, dan prinsip pencegahannya.

---

### Pattern 1: "Data Tersedia, Tapi Dihitung Ulang"

**Nama Pattern:** `RedundantDataRecomputation`  
**Terjadi di:** `WeekStripWidget`, potensi di widget lain yang menerima parameter tapi tidak dipakai

#### Deskripsi
Widget menerima data sebagai parameter (input X), tapi di dalam `build()` mengabaikan parameter tersebut dan menghitung ulang data yang sama (output Y) dari parameter lain yang sudah ada.

#### Contoh Kode (Masalah)
```dart
class WeekStripWidget extends StatelessWidget {
  final WeekModel week;         // ← Parameter SUDAH ADA
  final DateTime selectedDate;
  
  @override
  Widget build(BuildContext context) {
    final weekModel = WeekModel.fromDate(selectedDate);  // ← HITUNG ULANG!
    // week parameter TIDAK DIPAKAI
  }
}
```

#### First Principles Explanation
- **Premis:** Jika data X sudah tersedia sebagai input → tidak perlu menghitung X lagi dari sumber lain
- **Pelanggaran:** Widget menerima `week` (data X) tapi membuat `weekModel` baru (data X yang sama) dari `selectedDate` (data Y)
- **Mengapa terjadi:** Developer mungkin refactoring — awalnya widget hanya butuh `selectedDate`, lalu ditambah parameter `week` tapi logic `build()` tidak diupdate
- **Konsekuensi:** Setiap `build()` = alokasi objek baru = CPU waste + GC pressure

#### Pattern Pencegahan
```dart
// ✅ CORRECT — Gunakan parameter yang sudah ada
@override
Widget build(BuildContext context) {
  // week SUDAH tersedia, langsung pakai
  final monday = week.days.first.fullDate;
  // Tidak perlu WeekModel.fromDate(selectedDate) lagi
}
```

**Aturan:** *Jika parameter sudah tersedia, gunakan. Jangan hitung ulang apa yang sudah diberikan.*

---

### Pattern 2: "Consumer Terlalu Luas — Rebuild Lebih Banyak dari yang Dibutuhkan"

**Nama Pattern:** `OverlyBroadConsumer`  
**Terjadi di:** `main_screen.dart` (Consumer wrap PageView), potensi di screen lain

#### Deskripsi
`Consumer<T>` atau `context.watch<T>()` di-wrap di level parent yang terlalu tinggi → saat `notifyListeners()` dipanggil, SELURUH child widget rebuild padahal hanya sebagian kecil yang butuh data yang berubah.

#### Contoh Kode (Masalah)
```dart
// main_screen.dart
Consumer<TodayViewModel>(  // ← Consumer di level PageView
  builder: (context, todayVm, _) {
    // SELURUH PageView rebuild saat selectedDate berubah
    return PageView.builder(
      itemCount: 7,
      itemBuilder: (context, index) {
        final date = monday.add(Duration(days: index));
        return ChatPage(chatVm: chatVm, date: date);  // ← 7 widget di-recreate
      },
    );
  },
)
```

#### First Principles Explanation
- **Premis:** Widget hanya boleh rebuild jika data yang dia gunakan berubah
- **Pelanggaran:** PageView tidak butuh data dari ViewModel — yang butuh hanya tanggal untuk setiap halaman
- **Mengapa terjadi:** Developer ingin "access ViewModel" di dalam itemBuilder, jadi wrap seluruh PageView dengan Consumer
- **Konsekuensi:** Swipe 1 halaman → 7 ChatPage di-recreate → 14-21 widget instances baru

#### Pattern Pencegahan
```dart
// ✅ CORRECT — Consumer hanya di bagian yang butuh
Column(
  children: [
    // Top section — butuh selectedDate
    Consumer<TodayViewModel>(
      builder: (context, vm, _) => TodayHeaderWidget(selectedDate: vm.selectedDate),
    ),
    
    // PageView — TIDAK perlu Consumer, cukup initial date
    PageView.builder(
      controller: _pageController,  // const controller di State
      itemBuilder: (context, index) {
        // Hitung date dari controller, bukan dari ViewModel
        final date = _monday.add(Duration(days: index));
        return ChatPage(chatVm: _getChatVmForDate(date), date: date);
      },
    ),
  ],
)
```

**Aturan:** *Consumer harus se-kecil mungkin — wrap hanya widget yang LANGSUNG butuh data dari ViewModel.*

---

### Pattern 3: "Widget const di Dalam Parent Dinamis — const Tidak Berfungsi Optimal"

**Nama Pattern:** `ConstInDynamicZone`  
**Terjadi di:** `main_screen.dart` (Divider), `ChatPage` (SliverPadding const)

#### Deskripsi
Widget dideklarasikan sebagai `const` (yang seharusnya skip rebuild) tapi ditempatkan di dalam parent yang rebuild → Flutter tetap optimasi, tapi benefit-nya minimal karena parent sudah rebuild.

#### Contoh Kode
```dart
Consumer<TodayViewModel>(
  builder: (context, vm, _) {
    return Column(
      children: [
        // Widget dinamis
        TodayHeaderWidget(...),
        
        // const widget — TETAP const, tapi parent sudah rebuild
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Divider(color: AppColors.divider, height: 1),
        ),
        
        // Widget dinamis lagi
        PageView.builder(...),
      ],
    );
  },
)
```

#### First Principles Explanation
- **Premis:** `const` widget tidak rebuild saat parent rebuild (Flutter optimasi via canonicalization)
- **Realita:** `const` widget TETAP efisien karena Flutter's widget canonicalization — tapi **posisinya di dalam build() yang sering dipanggil** → overhead function call tetap ada
- **Mengapa bukan masalah besar:** Flutter sangat pintar mengoptimasi const widget — tapi secara prinsip, const widget sebaiknya di-extract keluar dari rebuild zone untuk menghindari function call overhead
- **Konsekuensi:** Minor — function call ~0.001ms, tidak noticeable

#### Pattern Pencegahan
```dart
// ✅ MORE CORRECT — Extract const widget keluar dari Consumer
Column(
  children: [
    Consumer<TodayViewModel>(...),
    _divider,  // ← static const field di class level
    PageView.builder(...),
  ],
)

static const _divider = Padding(
  padding: EdgeInsets.only(top: 16),
  child: Divider(color: AppColors.divider, height: 1),
);
```

**Aturan:** *`const` widget yang tidak berubah sebaiknya di-extract ke static field di luar `build()` untuk menghindari function call overhead.*

---

### Pattern 4: "Parsing/Processing di build() — O(n) Setiap Render"

**Nama Pattern:** `ExpensiveBuildComputation`  
**Terjadi di:** `ChatBubble._buildStyledText()`, potensi di widget lain yang processing data di build()

#### Deskripsi
Widget melakukan komputasi yang mahal (regex parsing, string manipulation, list generation) di dalam method `build()` → setiap widget rebuild, komputasi diulang dari awal meskipun input tidak berubah.

#### Contoh Kode (Masalah)
```dart
RichText _buildStyledText(String text, Color textColor) {
  final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|`(.+?)`');
  final matches = pattern.allMatches(text);  // ← O(n) SETIAP BUILD
  
  // Loop melalui semua matches → buat TextSpan per match
  // Jika text = 1000 karakter dengan 50 matches → 50 TextSpan creations
}
```

#### First Principles Explanation
- **Premis:** `build()` harus se-ringan mungkin — hanya assembly widget tree, bukan data processing
- **Pelanggaran:** Regex parsing + string splitting + TextSpan creation dilakukan di `build()`
- **Mengapa terjadi:** Developer ingin "format text saat render" — masuk akal karena text bisa berubah
- **Missing piece:** Text content TIDAK berubah setelah message dibuat — parsing cukup sekali
- **Konsekuensi:** Pesan 500 karakter → ~5-15ms build time → scroll janky jika ada 10+ bubble

#### Pattern Pencegahan
```dart
// ✅ CORRECT — Parse sekali di ChatMessage, cache hasilnya
class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;
  
  // Cache hasil parsing
  late final List<TextSpan> parsedSpans = _parseContent(content);
  
  static List<TextSpan> _parseContent(String text) {
    final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|`(.+?)`');
    // ... parsing logic ...
    return spans;
  }
}

// Di ChatBubble — langsung pakai cached spans
Widget build(BuildContext context) {
  return RichText(text: TextSpan(children: message.parsedSpans));  // ← O(1)
}
```

**Aturan:** *Jika komputasi hanya bergantung pada input yang tidak berubah setelah objek dibuat → lakukan sekali di constructor/factory, bukan di build().*

---

### Pattern 5: "ViewModel Terisolasi — Tidak Terhubung ke State Utama"

**Nama Pattern:** `DisconnectedViewModel`  
**Terjadi di:** `TodayScreen` (ChatViewModel tidak terhubung ke selectedDate)

#### Deskripsi
ViewModel dibuat secara manual di StatefulWidget → tidak terhubung ke state utama (TodayViewModel) → data tidak sinkron saat state utama berubah.

#### Contoh Kode (Masalah)
```dart
class _TodayScreenState extends State<TodayScreen> {
  late final ChatViewModel _chatVm;  // ← Manual, isolated
  
  @override
  void initState() {
    _chatVm = ChatViewModel();  // ← Dibuat sekali, tidak pernah update
  }
  
  @override
  Widget build(BuildContext context) {
    final todayVm = context.watch<TodayViewModel>();  // ← selectedDate berubah
    
    // Chat messages TIDAK berubah saat date berubah!
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ChatBubble(message: _chatVm.messages[index]),
        childCount: _chatVm.messages.length,
      ),
    );
  }
}
```

#### First Principles Explanation
- **Premis:** Dalam MVVM, View harus reflect state dari ViewModel
- **Pelanggaran:** ChatViewModel terisolasi dari TodayViewModel → selectedDate berubah tapi chat tidak update
- **Mengapa terjadi:** Developer membuat ChatViewModel sebagai local state → lupa connect ke date changes
- **Missing link:** Tidak ada mechanism untuk re-init atau switch ChatViewModel saat date berubah
- **Konsekuensi:** Bug fungsional — user pindah tanggal, chat history tetap sama

#### Pattern Pencegahan
```dart
// ✅ CORRECT — Hubungkan ChatViewModel ke selectedDate
@override
Widget build(BuildContext context) {
  final todayVm = context.watch<TodayViewModel>();
  
  // Gunakan Map untuk cache ChatViewModel per date
  final dateKey = _dateKey(todayVm.selectedDate);
  final chatVm = _chatVmsByDate.putIfAbsent(dateKey, () => ChatViewModel());
  
  // Atau: re-init saat date berubah (lebih sederhana, lebih banyak allocation)
  // final chatVm = useMemoized(() => ChatViewModel(), [todayVm.selectedDate]);
  
  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) => ChatBubble(message: chatVm.messages[index]),
      childCount: chatVm.messages.length,
    ),
  );
}
```

**Aturan:** *ViewModel yang bergantung pada state lain harus di-re-init atau di-switch saat state dependency berubah.*

---

## Summary Pattern

| Pattern | Nama | Frequency | Impact | Fix Effort |
|---------|------|-----------|--------|------------|
| RedundantDataRecomputation | Data dihitung ulang padahal sudah ada | 1 file | Medium | 2 menit |
| OverlyBroadConsumer | Consumer terlalu luas, rebuild banyak widget | 1 file | High | 15 menit |
| ConstInDynamicZone | Const widget di dalam rebuild zone | 2 files | Low | 5 menit |
| ExpensiveBuildComputation | Parsing di build() bukan di init | 1 file | Medium | 30 menit |
| DisconnectedViewModel | ViewModel tidak terhubung ke state utama | 1 file | High (bug) | 20 menit |

---

## Prinsip Umum Pencegahan

1. **Single Source of Truth:** Data hanya dihitung di satu tempat, dipakai ulang di tempat lain
2. **Minimal Rebuild:** Consumer/Provider harus se-kecil mungkin — wrap hanya yang butuh
3. **Compute Once, Use Many:** Parsing/processing di constructor, bukan di build()
4. **Connected State:** ViewModel harus terhubung ke state dependencies-nya
5. **Const Outside Build:** Widget const di-extract ke static field di luar build()

---

*Dokumen ini dibuat untuk mengidentifikasi POLA kesalahan yang berulang, sehingga developer bisa menghindari pattern yang sama di file-file baru.*
