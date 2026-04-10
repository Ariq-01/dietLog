# Widget Progress

**Deadline: April 12, 2026**

## Progress Widgets

- [x] Kalender ✅
- [x] Bubble Chat v2 ✅
- [ ] Local Storage Hive
- [ ] Firebase Login (iPhone & Google)

### Completed

| # | Widget | File | Date |
|---|--------|------|------|
| 1 | LoadingUserMessage | `lib/features/chat/widgets/loading_user_message.dart` | Apr 10 |
| 2 | CaloriesCard | `lib/features/today/widgets/calories_card.dart` | Apr 10 |
| 3 | MacrosCard | `lib/features/today/widgets/macros_card.dart` | Apr 10 |
| 4 | DailyStats Model | `lib/features/today/models/daily_stats.dart` | Apr 10 |
| 5 | Firebase Login (iPhone & Google) | `lib/features/auth/` | Apr 10 |
| 6 | **Date-Centric Navigation Refactor** | `lib/main_screen.dart` | Apr 10 |

---

## Date-Centric Navigation Refactor (Apr 10)

### Perubahan Utama:
- **7 pages** → sekarang mewakili **7 tanggal dalam 1 minggu** (bukan kategori)
- **Swipe page** → update `selectedDate` di TodayViewModel
- **Tap tanggal di WeekStrip** → update `selectedDate` + swipe ke page yang sesuai
- **ChatViewModel** → sekarang dibuat on-demand dan di-cache per tanggal (Map<date, ChatViewModel>)
- **Page indicator** → dihapus (tidak diperlukan, WeekStrip sudah cukup)
- **Consumer & Watch** → tetap menggunakan `Consumer<TodayViewModel>` untuk rebuild saat tanggal berubah

### Flow Navigation:
```
Swipe Page → _onPageChanged → hitung tanggal → TodayViewModel.onDateSelected → Consumer rebuild → WeekStrip highlight berubah

Tap Tanggal → _onWeekDateSelected → TodayViewModel.onDateSelected → _swipeToDate → PageView.animateToPage
```

### Files Modified:
| File | Perubahan |
|------|-----------|
| `lib/main_screen.dart` | Refactor `_HomeScreenState`: hapus 7 ChatViewModels global, ganti jadi Map per tanggal |
| `lib/features/home/pages/chat_page.dart` | Terima `date` parameter + `chatVm` dari parent |
| `lib/features/today/widgets/week_strip_widget.dart` | Tetap sama (highlight berdasarkan `selectedDate`) |
| `lib/features/today/widgets/today_header_widget.dart` | Tetap sama (tap → buka calendar) |

### Trade-offs:
| Dihilangkan | Ditambahkan |
|-------------|-------------|
| Page titles (Today, Tasks, Habits, dll) | 7 pages = 7 tanggal |
| Dot page indicator | WeekStrip highlight = page aktif |
| Global ChatViewModel list | Map<date, ChatViewModel> (on-demand) |

### Yang Masih Perlu Diperbaiki:
- ⚠️ **Week navigation**: kalau user pilih tanggal di luar week ini, perlu regenerate pages
- ⚠️ **Chat persistence**: messages per tanggal harus disave ke storage (Hive/SQLite)
- ⚠️ **Bottom input**: `_onSend` masih pake `selectedDate`, harusnya ke page yang aktif

---

## Spreadsheet / To-Do Later

| # | Task | Priority | Status | Notes |
|---|------|----------|--------|-------|
| 1 | AlertBanner Widget (Calorie Goal Warning) | Medium | ⬜ | Yellow banner + ⚠️ icon, tap to update goal |
| 2 | User Splash Screen Update | Medium | ⬜ | Implement "Set Your Calorie Goal" flow |
| 3 | Firebase Auth Setup | High | ⬜ | Configure Firebase project, add Sign in with Apple & Google providers |
| 4 | Apple Sign In Integration | High | ⬜ | Implement Sign in with Apple for iPhone users |
| 5 | Google Sign In Integration | High | ⬜ | Implement Google Sign In for Android & iOS |
| 6 | **Fix Week Navigation** | High | ⬜ | Regenerate pages saat user pilih tanggal di luar week ini |
| 7 | **Chat Persistence** | High | ⬜ | Save messages per tanggal ke Hive/SQLite |
| 8 | **Fix Bottom Input** | Medium | ⬜ | `_onSend` harus kirim ke page yang aktif, bukan `selectedDate` |
