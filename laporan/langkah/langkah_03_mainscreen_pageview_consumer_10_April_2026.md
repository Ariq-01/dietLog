# Langkah Fix #3 — main_screen.dart PageView.builder Wrapped in Consumer

## Masalah
Pattern: `OverlyBroadConsumer`

`Consumer<TodayViewModel>` di-wrap di level `PageView.builder` → setiap kali `selectedDate` berubah (via swipe), SELURUH PageView rebuild → `itemBuilder` dipanggil ulang untuk SEMUA index yang visible (2-3 halaman) → 7-21 widget instances di-recreate.

## Current (Entire)
- **File:** `lib/main_screen.dart`
- **Line:** 162-174
- **Behavior:** Consumer wrapper rebuild seluruh PageView saat `selectedDate` berubah → `itemBuilder` dipanggil 7x (semua index) → 7 ChatPage di-recreate
- **Root cause:** Consumer di level PageView untuk access `monday` calculation
- **Code:**
```dart
Expanded(
  child: Consumer<TodayViewModel>(  // ← INI MASALAHNYA — rebuild SELURUH PageView
    builder: (context, todayVm, _) {
      final monday = todayVm.selectedDate.subtract(
        Duration(days: todayVm.selectedDate.weekday - 1),
      );
      return PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = monday.add(Duration(days: index));
          final chatVm = _getChatVmForDate(date);
          return ChatPage(chatVm: chatVm, date: date);  // ← 7x di-recreate
        },
      );
    },
  ),
),
```

## Target
- **Behavior:** PageView TIDAK rebuild saat `selectedDate` berubah via Consumer — hanya swipe yang trigger rebuild
- **Output:** PageView tetap bisa swipe normal, tapi tidak recreate widget saat date berubah dari header/tap
- **Metric:** Widget rebuilds per swipe: 5+ → 2, Memory allocation per swipe: ~6-8KB → ~2KB

## Constraints
- Tidak boleh mengubah visual output
- `_pageController` harus tetap di State (bukan di build)
- `_getChatVmForDate` harus tetap berfungsi (Map cache)
- Pattern pencegahan: "Consumer harus se-kecil mungkin — wrap hanya widget yang LANGSUNG butuh data dari ViewModel"

## Langkah Penyelesaian

### Step 1 — Buka file
`lib/main_screen.dart`

### Step 2 — Pindahkan `monday` calculation ke State field
Tambahkan di class `_HomeScreenState`:
```dart
DateTime get _monday => _selectedDate.subtract(
  Duration(days: _selectedDate.weekday - 1),
);
```

Tapi tunggu — `_selectedDate` ada di ViewModel, bukan di State. Kita perlu cara lain.

### Step 3 — Extract PageView jadi widget terpisah
Buat method `_buildPageView()` di State yang TIDAK menggunakan Consumer:

```dart
Widget _buildPageView() {
  // Hitung monday dari initial state — PageView tidak perlu rebuild saat date berubah
  // Karena PageView.builder lazy, hanya halaman visible yang di-build
  final todayVm = context.read<TodayViewModel>();  // ← read, bukan watch
  final monday = todayVm.selectedDate.subtract(
    Duration(days: todayVm.selectedDate.weekday - 1),
  );
  
  return PageView.builder(
    controller: _pageController,
    onPageChanged: _onPageChanged,
    itemCount: 7,
    itemBuilder: (context, index) {
      final date = monday.add(Duration(days: index));
      final chatVm = _getChatVmForDate(date);
      return ChatPage(chatVm: chatVm, date: date);
    },
  );
}
```

### Step 4 — Ganti Consumer dengan direct call
Di `build()`, ganti:
```dart
Expanded(
  child: Consumer<TodayViewModel>(
    builder: (context, todayVm, _) {
      ...PageView.builder...
    },
  ),
),
```

Menjadi:
```dart
Expanded(
  child: _buildPageView(),  // ← Tidak ada Consumer
),
```

### Step 5 — Verify
Code di `build()` tidak ada lagi Consumer yang wrap PageView. Hanya:
- Consumer untuk TodayHeaderWidget + WeekStripWidget (top section) — INI TETAP
- PageView langsung tanpa Consumer

### Step 6 — Test
- Swipe halaman → harus normal
- Tap tanggal di WeekStrip → harus swipe ke halaman yang benar
- Buka calendar, pilih tanggal → harus swipe + update header

## Verifikasi Berhasil
- ✅ Tidak ada `Consumer<TodayViewModel>` yang wrap `PageView.builder`
- ✅ PageView di-build sekali di initState atau via method tanpa Consumer
- ✅ Swipe tetap normal
- ✅ Widget rebuilds per swipe berkurang dari 5+ ke 2
