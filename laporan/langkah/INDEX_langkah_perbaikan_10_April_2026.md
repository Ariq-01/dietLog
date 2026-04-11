# Index Langkah Perbaikan — dietLog Performans & Arsitektur
**Tanggal:** 10 April 2026  
**Source:** `laporan_performans_dan_arsitektur_10_April_2026.md` + `laporan_patterns_10_April_2026.md`

---

## Urutan Eksekusi (Wajib Ikuti)

Setiap langkah dirancang untuk diselesaikan secara berurutan. Langkah berikutnya TIDAK BOLEH dimulai sebelum langkah sebelumnya selesai dan terverifikasi.

```
┌─────────────────────────────────────────────────────────────┐
│  PRIORITY 1 — Foundation (Fix Sekarang)                    │
├─────────────────────────────────────────────────────────────┤
│  Step 01 → WeekStripWidget redundant WeekModel             │
│           Pattern: RedundantDataRecomputation               │
│           File: lib/features/today/widgets/week_strip...    │
│           Effort: 2 menit                                   │
│           └── Membuka jalan: Step 02                        │
├─────────────────────────────────────────────────────────────┤
│  Step 02 → TodayViewModel week field → getter              │
│           Pattern: RedundantDataRecomputation               │
│           File: lib/features/viewModels/today_viewmodel...  │
│           Effort: 5 menit                                   │
│           └── Memastikan date logic benar                   │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  PRIORITY 2 — Core Fixes (Setelah Foundation)              │
├─────────────────────────────────────────────────────────────┤
│  Step 03 → main_screen PageView Consumer terlalu luas      │
│           Pattern: OverlyBroadConsumer                      │
│           File: lib/main_screen.dart                        │
│           Effort: 15 menit                                  │
│           └── Mengurangi rebuild waste                      │
├─────────────────────────────────────────────────────────────┤
│  Step 04 → TodayScreen ChatViewModel terisolasi            │
│           Pattern: DisconnectedViewModel                    │
│           File: lib/features/today/today_screen.dart        │
│           Effort: 20 menit                                  │
│           └── Fix bug fungsional                            │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│  PRIORITY 3 — Optimization (Nice to Have)                  │
├─────────────────────────────────────────────────────────────┤
│  Step 05 → ChatBubble RichText parsing di build()          │
│           Pattern: ExpensiveBuildComputation                │
│           File: lib/features/chat/widgets/chat_bubble.dart  │
│           Effort: 30 menit                                  │
├─────────────────────────────────────────────────────────────┤
│  Step 06 → Provider di app root → screen level             │
│           Pattern: OverlyBroadConsumer (related)            │
│           File: lib/main.dart → lib/main_screen.dart        │
│           Effort: 5 menit                                   │
├─────────────────────────────────────────────────────────────┤
│  Step 07 → ChatPage AnimatedBuilder rebuild seluruh list   │
│           Pattern: ExpensiveBuildComputation (related)      │
│           File: lib/features/home/pages/chat_page.dart      │
│           Effort: 10 menit                                  │
├─────────────────────────────────────────────────────────────┤
│  Step 08 → Const Divider di dalam rebuild zone             │
│           Pattern: ConstInDynamicZone                       │
│           File: lib/main_screen.dart                        │
│           Effort: 2 menit                                   │
├─────────────────────────────────────────────────────────────┤
│  Step 09 → CalendarWidget tidak di-cache                   │
│           Pattern: ConstInDynamicZone (related)             │
│           File: lib/main_screen.dart                        │
│           Effort: 5 menit                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## Summary Per Step

| # | File | Masalah | Pattern | Impact | Effort |
|---|------|---------|---------|--------|--------|
| 01 | `week_strip_widget.dart` | WeekModel dibuat ulang | RedundantDataRecomputation | Medium | 2m |
| 02 | `today_viewmodel.dart` | Week field immutable | RedundantDataRecomputation | High | 5m |
| 03 | `main_screen.dart` | Consumer wrap PageView | OverlyBroadConsumer | High | 15m |
| 04 | `today_screen.dart` | ChatViewModel isolated | DisconnectedViewModel | High (bug) | 20m |
| 05 | `chat_bubble.dart` | Regex parsing di build | ExpensiveBuildComputation | Medium | 30m |
| 06 | `main.dart` → `main_screen.dart` | Provider app-wide | OverlyBroadConsumer | Low | 5m |
| 07 | `chat_page.dart` | AnimatedBuilder rebuild all | ExpensiveBuildComputation | Low | 10m |
| 08 | `main_screen.dart` | Const in dynamic zone | ConstInDynamicZone | Low | 2m |
| 09 | `main_screen.dart` | Calendar no cache | ConstInDynamicZone | Low | 5m |

---

## Expected Result Setelah Semua Step

| Metric | Before | After |
|--------|--------|-------|
| Widget rebuilds per swipe | 5+ | 2 |
| Memory allocation per swipe | ~6-8KB | ~2KB |
| ChatBubble build time (long msg) | 5-15ms | 1-3ms |
| Week correctness (cross-week) | ❌ Wrong | ✅ Correct |
| ViewModel scope | App-wide | Screen-level |
| **Overall optimization** | **~90%** | **~98%** |

---

## Rules Eksekusi

1. **JANGAN SKIP STEP** — Setiap step membuka jalan untuk step berikutnya
2. **VERIFIKASI SETIAP STEP** — Jangan lanjut sebelum step current terverifikasi ✅
3. **TEST SETIAP STEP** — Jalankan app setelah setiap fix
4. **JANGAN EDIT LAPORAN** — Laporan adalah source of truth, jangan diubah
5. **FOLLOW PATTERNS** — Setiap step berdasarkan pattern di `laporan_patterns_10_April_2026.md`

---

*Index ini dibuat untuk memberikan panduan step-by-step yang jelas dan terstruktur berdasarkan hasil analisis di laporan.*

## rules : anda diperolehkan menggunaka emulatos ynag sedang running saat ini jika apps tetsin dibutuhkan 