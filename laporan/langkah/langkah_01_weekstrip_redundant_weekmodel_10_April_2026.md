# Langkah Fix #1 — WeekStripWidget Redundant WeekModel Creation

## Masalah
Pattern: `RedundantDataRecomputation`

Widget menerima parameter `week` (WeekModel) tapi TIDAK DIPAKAI. Sebaliknya, widget membuat `WeekModel.fromDate(selectedDate)` lagi di dalam `build()` — duplikasi komputasi setiap rebuild.

## Current (Entire)
- **File:** `lib/features/today/widgets/week_strip_widget.dart`
- **Line:** 28-32
- **Behavior:** Setiap kali `build()` dipanggil, `WeekModel.fromDate(selectedDate)` membuat 7 objek `WeekDay` baru → 7 allocations × 200 bytes = ~1.4KB waste per rebuild
- **Root cause:** Parameter `week` diterima tapi diabaikan
- **Code:**
```dart
@override
Widget build(BuildContext context) {
  final locale = MaterialLocalizations.of(context);
  final narrowDays = locale.narrowWeekdays;

  // INI MASALAHNYA — week parameter TIDAK DIPAKAI
  final weekModel = WeekModel.fromDate(selectedDate);  // ← MEMBUAT ULANG
  final monday = weekModel.days.first.fullDate;
  final dayLabels = List.generate(7, (i) {
    final d = monday.add(Duration(days: i));
    return narrowDays[d.weekday % 7];
  });

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: List.generate(7, (i) {
      final day = weekModel.days[i];  // ← Pakai weekModel baru, bukan parameter
      ...
    }),
  );
}
```

## Target
- **Behavior:** Gunakan parameter `week` yang sudah ada → 0 allocations tambahan per rebuild
- **Output:** Widget menampilkan hari yang sama, tapi tanpa alokasi objek baru
- **Metric:** Eliminasi ~1.4KB allocation per rebuild

## Constraints
- Tidak boleh mengubah signature widget (parameter tetap sama)
- Tidak boleh mengubah visual output
- Hanya ubah logic di dalam `build()`
- Pattern pencegahan: "Jika parameter sudah tersedia, gunakan. Jangan hitung ulang apa yang sudah diberikan."

## Langkah Penyelesaian

### Step 1 — Buka file
`lib/features/today/widgets/week_strip_widget.dart`

### Step 2 — Hapus line 29
Hapus: `final weekModel = WeekModel.fromDate(selectedDate);`

### Step 3 — Ganti semua `weekModel` dengan `week`
- Line 30: `final monday = weekModel.days.first.fullDate;` → `final monday = week.days.first.fullDate;`
- Line 31-34: `dayLabels` tetap sama (menggunakan `monday` yang sudah diganti)
- Line 38: `final day = weekModel.days[i];` → `final day = week.days[i];`

### Step 4 — Verify
Tidak ada lagi pemanggilan `WeekModel.fromDate` di dalam `build()`

### Step 5 — Test
- Jalankan app
- Swipe halaman → WeekStripWidget harus menampilkan hari yang sama seperti sebelumnya
- Tap tanggal di WeekStrip → harus navigate ke halaman yang benar

## Verifikasi Berhasil
- ✅ `week` parameter digunakan (bukan dibuat ulang)
- ✅ Tidak ada `WeekModel.fromDate` di `build()`
- ✅ Visual output sama
- ✅ Tidak ada error di console
