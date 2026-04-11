# Langkah Fix #4 — TodayScreen Disconnected ChatViewModel

## Masalah
Pattern: `DisconnectedViewModel`

`TodayScreen` membuat `ChatViewModel` secara manual (`late final ChatViewModel _chatVm`) → tidak terhubung ke `TodayViewModel` → `selectedDate` berubah tapi chat messages TIDAK berubah → bug fungsional.

## Current (Entire)
- **File:** `lib/features/today/today_screen.dart`
- **Line:** 22-25, 38-50
- **Behavior:** ChatViewModel dibuat SEKALI di `initState()` → tidak pernah update saat `selectedDate` berubah → chat history sama untuk semua tanggal
- **Root cause:** ChatViewModel tidak terhubung ke TodayViewModel's selectedDate
- **Code:**
```dart
class _TodayScreenState extends State<TodayScreen> {
  late final ChatViewModel _chatVm;  // ← MANUAL, ISOLATED

  @override
  void initState() {
    super.initState();
    _chatVm = ChatViewModel();  // ← DIBUAT SEKALI, TIDAK PERNAH UPDATE
  }

  @override
  Widget build(BuildContext context) {
    final todayVm = context.watch<TodayViewModel>();  // ← selectedDate berubah

    // Chat messages TIDAK terhubung ke selectedDate!
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ChatBubble(message: _chatVm.messages[index]),
        childCount: _chatVm.messages.length,
      ),
    ),
  }
}
```

## Target
- **Behavior:** Chat messages harus berubah saat `selectedDate` berubah — setiap tanggal punya chat history sendiri
- **Output:** User pindah tanggal → chat history berubah sesuai tanggal
- **Metric:** Fix bug fungsional — chat sekarang date-aware

## Constraints
- Tidak boleh mengubah ChatViewModel class
- Tidak boleh mengubah signature TodayScreen
- Harus cache ChatViewModel per date (tidak re-init setiap date change untuk preserve history)
- Pattern pencegahan: "ViewModel yang bergantung pada state lain harus di-re-init atau di-switch saat state dependency berubah"

## Langkah Penyelesaian

### Step 1 — Buka file
`lib/features/today/today_screen.dart`

### Step 2 — Ganti single ChatViewModel dengan Map
Hapus: `late final ChatViewModel _chatVm;`

Tambahkan: `final Map<String, ChatViewModel> _chatVmsByDate = {};`

### Step 3 — Tambahkan helper method
```dart
ChatViewModel _getChatVmForDate(DateTime date) {
  final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  if (!_chatVmsByDate.containsKey(key)) {
    _chatVmsByDate[key] = ChatViewModel();
  }
  return _chatVmsByDate[key]!;
}

String _dateKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
```

### Step 4 — Update build() untuk get ChatViewModel dari Map
Ganti `_chatVm` dengan `_getChatVmForDate(todayVm.selectedDate)`:

```dart
@override
Widget build(BuildContext context) {
  final todayVm = context.watch<TodayViewModel>();
  final chatVm = _getChatVmForDate(todayVm.selectedDate);  // ← DATE-AWARE

  return Scaffold(
    ...
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ChatBubble(message: chatVm.messages[index]),
        childCount: chatVm.messages.length,
      ),
    ),
    ...
    BottomNavBarWidget(
      onSend: chatVm.sendMessage,  // ← PAKAI chatVm yang benar
      ...
    ),
  );
}
```

### Step 5 — Update dispose untuk dispose semua ChatViewModel
```dart
@override
void dispose() {
  for (final vm in _chatVmsByDate.values) {
    vm.dispose();
  }
  super.dispose();
}
```

### Step 6 — Verify
Code menjadi:
```dart
class _TodayScreenState extends State<TodayScreen> {
  final Map<String, ChatViewModel> _chatVmsByDate = {};

  ChatViewModel _getChatVmForDate(DateTime date) {
    final key = _dateKey(date);
    if (!_chatVmsByDate.containsKey(key)) {
      _chatVmsByDate[key] = ChatViewModel();
    }
    return _chatVmsByDate[key]!;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    for (final vm in _chatVmsByDate.values) {
      vm.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayVm = context.watch<TodayViewModel>();
    final chatVm = _getChatVmForDate(todayVm.selectedDate);
    // ... pakai chatVm
  }
}
```

### Step 7 — Test
- Buka TodayScreen → kirim pesan → chat masuk
- Pindah tanggal (via WeekStrip) → chat history kosong (date baru)
- Kembali ke tanggal sebelumnya → chat history muncul lagi (cached)

## Verifikasi Berhasil
- ✅ `_chatVmsByDate` Map ada (bukan single `_chatVm`)
- ✅ `_getChatVmForDate` method ada
- ✅ Chat messages berubah saat `selectedDate` berubah
- ✅ Chat history preserved saat kembali ke tanggal sebelumnya
- ✅ `dispose` dispose semua ViewModel di Map
- ✅ Tidak ada error di console
