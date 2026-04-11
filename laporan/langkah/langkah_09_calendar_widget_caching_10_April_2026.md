# Langkah Fix #9 — CalendarWidget Tidak Di-Cache

## Masalah
Pattern: `ConstInDynamicZone` (related) — Widget recreation tanpa caching

`CalendarWidget` dibuat ulang SETIAP kali `_openCalendar()` dipanggil → widget tree di-recreate dari nol → tidak ada caching state atau position → overhead creation setiap kali dibuka.

## Current (Entire)
- **File:** `lib/main_screen.dart`
- **Line:** 108-123 (di dalam `_openCalendar()`)
- **Behavior:** `_openCalendar()` → `OverlayEntry(builder: ...)` → `CalendarWidget(...)` dibuat baru → state internal CalendarWidget (month position, selected date) di-init ulang → jika user buka/tutup calendar berkali-kali, widget creation overhead terakumulasi
- **Root cause:** CalendarWidget di-create di dalam builder function, tidak ada caching
- **Code:**
```dart
void _openCalendar() {
  final overlay = Overlay.of(context);

  _calendarOverlay = OverlayEntry(
    builder: (context) {
      return Stack(
        children: [
          GestureDetector(...),
          Positioned(
            top: _calendarTop,
            left: _calendarHorizontal,
            right: _calendarHorizontal,
            child: CalendarWidget(  // ← DIBUAT BARU SETIAP KALI
              initialDate: context.read<TodayViewModel>().selectedDate,
              onDateSelected: _onDateSelected,
              onClose: _closeCalendar,
            ),
          ),
        ],
      );
    },
  );

  overlay.insert(_calendarOverlay!);
}
```

## Target
- **Behavior:** CalendarWidget di-cache → saat dibuka lagi, widget instance yang sama dipakai → state (selected month position) preserved
- **Output:** Calendar tetap smooth, user experience sama atau lebih baik (state preserved)
- **Metric:** Minor — eliminasi widget creation overhead

## Constraints
- Tidak boleh mengubah CalendarWidget class
- Harus tetap bisa di-close via overlay
- Pattern pencegahan: "Compute Once, Use Many"

## Langkah Penyelesaian

### Step 1 — Buka file
`lib/main_screen.dart`

### Step 2 — Tambahkan field untuk cache CalendarWidget
Tambahkan di class `_HomeScreenState`:

```dart
CalendarWidget? _cachedCalendar;
```

### Step 3 — Buat method `_getCalendarWidget()`
```dart
CalendarWidget _getCalendarWidget() {
  if (_cachedCalendar == null) {
    _cachedCalendar = CalendarWidget(
      initialDate: context.read<TodayViewModel>().selectedDate,
      onDateSelected: _onDateSelected,
      onClose: _closeCalendar,
    );
  }
  return _cachedCalendar!;
}
```

### Step 4 — Update `_openCalendar()` untuk pakai cached widget
Ganti:
```dart
child: CalendarWidget(
  initialDate: context.read<TodayViewModel>().selectedDate,
  onDateSelected: _onDateSelected,
  onClose: _closeCalendar,
),
```

Menjadi:
```dart
child: _getCalendarWidget(),
```

### Step 5 — Reset cache saat date berubah (opsional)
Tambahkan di `_onDateSelected` atau saat date berubah secara signifikan:

```dart
void _onDateSelected(DateTime date) {
  context.read<TodayViewModel>().onDateSelected(date);
  _closeCalendar();
  _cachedCalendar = null;  // ← Reset cache saat date berubah
  _swipeToDate(date);
}
```

Atau biarkan saja — CalendarWidget akan pakai initialDate yang lama (tidak masalah untuk UX)

### Step 6 — Verify
Code menjadi:
```dart
class _HomeScreenState extends State<HomeScreen> {
  // ... fields lain
  CalendarWidget? _cachedCalendar;

  CalendarWidget _getCalendarWidget() {
    if (_cachedCalendar == null) {
      _cachedCalendar = CalendarWidget(
        initialDate: context.read<TodayViewModel>().selectedDate,
        onDateSelected: _onDateSelected,
        onClose: _closeCalendar,
      );
    }
    return _cachedCalendar!;
  }

  void _openCalendar() {
    final overlay = Overlay.of(context);
    _calendarOverlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(...),
            Positioned(
              top: _calendarTop,
              left: _calendarHorizontal,
              right: _calendarHorizontal,
              child: _getCalendarWidget(),  // ← CACHED
            ),
          ],
        );
      },
    );
    overlay.insert(_calendarOverlay!);
  }
}
```

### Step 7 — Test
- Buka calendar → pilih bulan berbeda → tutup
- Buka calendar lagi → harus masih di bulan yang sama (state preserved)
- Pilih tanggal → calendar tertutup → swipe ke halaman tanggal tersebut

## Verifikasi Berhasil
- ✅ `_cachedCalendar` field ada
- ✅ `_getCalendarWidget()` method ada (lazy init)
- ✅ `_openCalendar()` pakai `_getCalendarWidget()`
- ✅ Calendar state preserved saat buka/tutup berkali-kali
- ✅ Tidak ada error di console
