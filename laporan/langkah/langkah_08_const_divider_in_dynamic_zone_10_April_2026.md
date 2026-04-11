# Langkah Fix #8 — Const Widget di Dalam Parent Dinamis (Divider)

## Masalah
Pattern: `ConstInDynamicZone`

Widget `const` (Divider) ditempatkan di dalam parent yang rebuild (Consumer) → Flutter tetap optimasi via canonicalization, tapi function call overhead tetap ada setiap kali `build()` dipanggil.

## Current (Entire)
- **File:** `lib/main_screen.dart`
- **Line:** 152
- **Behavior:** `const Padding(child: Divider(...))` di dalam `Column` yang children-nya di-rebuild oleh Consumer → function call ~0.001ms per rebuild
- **Root cause:** Const widget di dalam rebuild zone
- **Code:**
```dart
Consumer<TodayViewModel>(
  builder: (context, todayVm, _) {
    return Column(
      children: [
        // Top section
        Padding(...TodayHeaderWidget...),
        Padding(...WeekStripWidget...),
        
        // INI — const widget di dalam rebuild zone
        const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Divider(color: AppColors.divider, height: 1),
        ),
        
        // PageView
        Expanded(child: PageView.builder(...)),
        Padding(...BottomNavBarWidget...),
      ],
    );
  },
),
```

## Target
- **Behavior:** Const widget di-extract ke static field di luar `build()` → eliminasi function call overhead
- **Output:** Visual sama, tapi lebih efisien
- **Metric:** Minor optimization — function call elimination

## Constraints
- Tidak boleh mengubah visual output
- Hanya extract ke static field
- Pattern pencegahan: "const widget yang tidak berubah sebaiknya di-extract ke static field di luar build()"

## Langkah Penyelesaian

### Step 1 — Buka file
`lib/main_screen.dart`

### Step 2 — Tambahkan static const field di class `_HomeScreenState`
Tambahkan setelah deklarasi variabel lain di State:

```dart
class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  OverlayEntry? _calendarOverlay;
  final Map<String, ChatViewModel> _chatVmsByDate = {};

  // Tambahkan ini:
  static const _divider = Padding(
    padding: EdgeInsets.only(top: 16),
    child: Divider(color: AppColors.divider, height: 1),
  );

  // ... seluruh code tetap sama
```

### Step 3 — Ganti const Padding dengan static field
Di `build()`, ganti:
```dart
const Padding(
  padding: EdgeInsets.only(top: 16),
  child: Divider(color: AppColors.divider, height: 1),
),
```

Menjadi:
```dart
_divider,
```

### Step 4 — Verify
Code di `build()`:
```dart
Column(
  children: [
    Consumer<TodayViewModel>(...),
    _divider,  // ← Static field, bukan const inline
    Expanded(child: ...),
    Padding(...),
  ],
),
```

### Step 5 — Test
- Jalankan app → divider harus tetap terlihat
- Swipe halaman → divider tetap di posisi yang sama
- Tidak ada perubahan visual

## Verifikasi Berhasil
- ✅ `_divider` static const field ada di `_HomeScreenState`
- ✅ Tidak ada `const Padding(...Divider...)` inline di `build()`
- ✅ Visual output sama
- ✅ Function call overhead eliminasi
