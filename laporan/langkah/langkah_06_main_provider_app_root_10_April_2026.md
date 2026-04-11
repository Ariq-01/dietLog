# Langkah Fix #6 — main.dart TodayViewModel Provider di App Root

## Masalah
Pattern: `OverlyBroadConsumer` (related) — Provider scope terlalu luas

`TodayViewModel` di-provide di root `BiteLogApp` → SELURUH app punya access → tapi hanya `HomeScreen` yang butuh → ViewModel hidup sepanjang app lifecycle → tidak pernah di-dispose → memory leak potential.

## Current (Entire)
- **File:** `lib/main.dart`
- **Line:** 15-17
- **Behavior:** `ChangeNotifierProvider` di `BiteLogApp.build()` → ViewModel dibuat saat app start → tidak pernah di-dispose sampai app ditutup
- **Root cause:** Provider di level root MaterialApp
- **Code:**
```dart
class BiteLogApp extends StatelessWidget {
  const BiteLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TodayViewModel>(  // ← DI ROOT, APP-WIDE
      create: (_) => TodayViewModel(),
      child: MaterialApp(
        title: 'BiteLog',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
```

## Target
- **Behavior:** `TodayViewModel` hanya tersedia di `HomeScreen` → di-dispose saat HomeScreen di-pop/dihapus dari navigation stack
- **Output:** App tetap berfungsi normal, tapi lifecycle ViewModel lebih proper
- **Metric:** ViewModel scope: App-wide → Screen-level

## Constraints
- Tidak boleh mengubah BiteLogApp structure terlalu banyak
- Hanya pindahkan Provider dari `main.dart` ke `main_screen.dart`
- HomeScreen harus tetap const constructor
- Pattern pencegahan: "Provider hanya di level screen yang butuh, bukan app root"

## Langkah Penyelesaian

### Step 1 — Buka file
`lib/main.dart`

### Step 2 — Hapus ChangeNotifierProvider dari BiteLogApp
Ganti:
```dart
@override
Widget build(BuildContext context) {
  return ChangeNotifierProvider<TodayViewModel>(
    create: (_) => TodayViewModel(),
    child: MaterialApp(
      title: 'BiteLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    ),
  );
}
```

Menjadi:
```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'BiteLog',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const HomeScreen(),
  );
}
```

### Step 3 — Buka file
`lib/main_screen.dart`

### Step 4 — Tambahkan ChangeNotifierProvider di HomeScreen.build()
Wrap body Scaffold dengan Provider:

```dart
@override
Widget build(BuildContext context) {
  return ChangeNotifierProvider<TodayViewModel>(
    create: (_) => TodayViewModel(),
    child: _HomeScreenContent(),
  );
}
```

Tapi ini akan mengubah structure cukup banyak. Alternatif yang lebih minimal:

Wrap di `build()` method `_HomeScreenState`:

```dart
@override
Widget build(BuildContext context) {
  return ChangeNotifierProvider<TodayViewModel>(
    create: (_) => TodayViewModel(),
    child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ... seluruh isi Scaffold tetap sama
          ],
        ),
      ),
    ),
  );
}
```

### Step 5 — Hapus import provider di main.dart (jika tidak dipakai lagi)
Di `main.dart`, hapus: `import 'package:provider/provider.dart';` (jika tidak ada lagi yang pakai)

### Step 6 — Tambahkan import provider di main_screen.dart (jika belum ada)
Pastikan `import 'package:provider/provider.dart';` ada di `main_screen.dart`

### Step 7 — Verify
Code di `main.dart`:
```dart
class BiteLogApp extends StatelessWidget {
  const BiteLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BiteLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
```

Code di `main_screen.dart`:
```dart
@override
Widget build(BuildContext context) {
  return ChangeNotifierProvider<TodayViewModel>(
    create: (_) => TodayViewModel(),
    child: Scaffold(
      // ... seluruh isi tetap sama
    ),
  );
}
```

### Step 8 — Test
- Jalankan app → HomeScreen harus normal
- Consumer<TodayViewModel> di dalam Scaffold harus tetap dapat access ViewModel
- Tidak ada error "Could not find the correct Provider<TodayViewModel>"

## Verifikasi Berhasil
- ✅ `ChangeNotifierProvider` tidak ada di `main.dart`
- ✅ `ChangeNotifierProvider` ada di `main_screen.dart` (di dalam `build()`)
- ✅ App tetap berfungsi normal
- ✅ `TodayViewModel` akan di-dispose saat HomeScreen di-pop
- ✅ Tidak ada error "Could not find Provider" di console
