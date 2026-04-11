# Langkah Fix #2 — TodayViewModel WeekModel Field Initialization

## Masalah
Pattern: `RedundantDataRecomputation` (related)

`WeekModel.today()` dipanggil di field initialization → computed SEKALI saat ViewModel dibuat → TIDAK PERNAH update jika user navigate ke tanggal di luar minggu current.

## Current (Entire)
- **File:** `lib/features/viewModels/today_viewmodel.dart`
- **Line:** 9
- **Behavior:** `final WeekModel week = WeekModel.today();` → week selalu minggu saat ViewModel di-init, tidak berubah saat `selectedDate` pindah ke minggu lain
- **Root cause:** Field initialization terjadi sekali, `final` tidak bisa di-reassign
- **Code:**
```dart
class TodayViewModel extends ChangeNotifier {
  final WeekModel week = WeekModel.today();  // ← COMPUTED SEKALI, NEVER UPDATES
  late DateTime _selectedDate;
  DailyStats _stats = DailyStats.empty();

  TodayViewModel() : _selectedDate = DateTime.now();

  void onDateSelected(DateTime date) {
    if (_selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day) {
      return;
    }
    _selectedDate = date;
    notifyListeners();  // ← week TIDAK update saat ini dipanggil
  }
}
```

## Target
- **Behavior:** `week` computed dari `_selectedDate` setiap kali diakses → guarantee correctness untuk cross-week navigation
- **Output:** `week` selalu merefleksikan minggu dari `selectedDate`
- **Metric:** Week correctness: ❌ Wrong → ✅ Correct
- **Trade-off:** 7 allocations per `notifyListeners()` (acceptable untuk correctness)

## Constraints
- Tidak boleh mengubah signature public API (`week` getter tetap ada)
- Tidak boleh mengubah `onDateSelected` behavior
- Pattern pencegahan: "Data hanya dihitung di satu tempat, dipakai ulang di tempat lain"

## Langkah Penyelesaian

### Step 1 — Buka file
`lib/features/viewModels/today_viewmodel.dart`

### Step 2 — Hapus field `final WeekModel week`
Hapus seluruh line: `final WeekModel week = WeekModel.today();`

### Step 3 — Tambahkan getter `week`
Tambahkan setelah line `DailyStats _stats = DailyStats.empty();`:

```dart
WeekModel get week => WeekModel.fromDate(_selectedDate);
```

### Step 4 — Verify
Code menjadi:
```dart
class TodayViewModel extends ChangeNotifier {
  late DateTime _selectedDate;
  DailyStats _stats = DailyStats.empty();

  WeekModel get week => WeekModel.fromDate(_selectedDate);  // ← COMPUTED DARI selectedDate

  TodayViewModel() : _selectedDate = DateTime.now();
  ...
}
```

### Step 5 — Test
- Jalankan app
- Pindah ke tanggal di minggu depan (via calendar)
- WeekStripWidget harus menampilkan minggu yang benar (bukan minggu saat init)
- Swipe kiri/kanan → WeekStripWidget update sesuai

## Verifikasi Berhasil
- ✅ `week` adalah getter (bukan field final)
- ✅ `week` computed dari `_selectedDate`
- ✅ Cross-week navigation menampilkan minggu yang benar
- ✅ Tidak ada error di console
