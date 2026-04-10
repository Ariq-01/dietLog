# AI Prompt Engineering Guide — Senior Engineer Style

**For: Qwen AI / Any LLM Code Assistant**  
**Created: April 10, 2026**  
**Purpose: Eliminate repeated mistakes, improve output quality**

---

## Problem yang Sering Terjadi

| Kesalahan Berulang | Penyebab |
|-------------------|----------|
| AI misunderstanding | Prompt terlalu vague, gak ada context boundary |
| Over-engineering | AI gak dikasih constraint yang jelas |
| Wrong assumptions | AI gak disuruh verify dulu sebelum implement |
| Inconsistent output | AI gak dikasih explicit structure expectation |
| Code breaks other features | AI tidak disuruh cek side effects |
| Wrong architecture pattern | AI tidak dikasih tahu existing patterns di project |

---

## Framework Prompting yang Bekerja

### 1. C.A.R.E. Framework

```
Context → Action → Result → Example
```

#### ❌ **Bad Prompt:**
```
"Fix the navigation bug"
```

#### ✅ **Good Prompt (C.A.R.E.):**
```
Context: "App date-centric, 7 pages = 7 dates in current week"
Action: "When user swipes to page 3, highlight date at position 3 in WeekStrip"
Result: "WeekStrip highlight always matches active page"
Example: "Swipe → page 2 → Wednesday highlight. Tap Thursday → swipe to page 3"
```

---

### 2. Senior Engineer Pattern

#### **Template:**
```
I need you to [VERB: design/implement/debug/refactor] [COMPONENT] 

CONSTRAINTS:
- [Hard limit: no new dependencies, must use existing X]
- [Performance: must not rebuild Y]
- [Architecture: must follow pattern Z]

CURRENT STATE:
- [What exists now]
- [What's broken]

EXPECTED STATE:
- [What should happen]
- [What should NOT happen]

THINKING PROCESS:
1. First, verify you understand the architecture
2. Then, identify the minimal change needed
3. Then, implement with zero side effects

DELIVERABLES:
- [ ] Code change in file X
- [ ] Explanation of WHY this approach
- [ ] Trade-offs considered
```

---

### 3. Qwen-Specific Prompting (How Qwen AI Thinks)

#### **Qwen's Internal Process:**
```
User prompt → Pattern match → Generate solution → Output
```

**Yang Qwen butuhkan:**
- **Explicit pattern** (jangan suruh AI "figure it out")
- **Boundary yang jelas** (apa yang BOLEH dan TIDAK BOLEH diubah)
- **Verification step** (suruh AI cek dulu sebelum implement)

#### ❌ **Prompt yang Gagal:**
```
"Make the week strip better"
```

#### ✅ **Prompt yang Bekerja:**
```
"Refactor WeekStripWidget to:
- Accept `currentPageIndex` instead of `selectedDate`
- Highlight logic: `index == currentPageIndex`
- DO NOT change: visual style, tap callback signature
- VERIFY: WeekModel still used for date labels

Before implementing, confirm you understand:
1. What WeekModel provides
2. What will break if we remove selectedDate
3. How PageView builder works with this
```

---

## 4. Sample Prompts (Copy-Paste Ready)

### **For Architecture Design:**
```
I need you to DESIGN a navigation system for a date-centric Flutter app.

CONSTRAINTS:
- 7 pages = 7 dates in current week (NOT categories)
- Must use Provider<TodayViewModel> for state
- Must NOT rebuild entire screen on date change
- Swipe page ↔ tap date must stay synced

THINKING PROCESS:
1. First, explain the data flow (user action → state change → UI update)
2. Then, identify which widgets need Consumer vs ValueListenableBuilder
3. Then, propose the minimal change to main_screen.dart

DELIVERABLE:
- Architecture diagram (text-based)
- Code structure proposal
- Trade-offs: what gets simpler, what gets more complex
```

### **For Debugging:**
```
DEBUG this navigation bug:

CURRENT BEHAVIOR:
- User swipes to page 3 → WeekStrip highlight doesn't update
- User taps date → PageView doesn't swipe

EXPECTED BEHAVIOR:
- Swipe page → WeekStrip highlight matches page
- Tap date → PageView animates to that page

CONSTRAINTS:
- DO NOT change WeekStripWidget implementation
- DO NOT add new state variables
- MUST use existing _currentPageNotifier

DEBUG PROCESS:
1. Trace the data flow from swipe → highlight
2. Identify where the signal is lost
3. Propose minimal fix

DELIVERABLE:
- Root cause explanation
- Code fix (1-3 lines max)
- Why this fix doesn't break other things
```

### **For Refactoring:**
```
REFACTOR main_screen.dart to be date-centric.

BEFORE:
- 7 pages = categories (Today, Tasks, Habits, etc)
- PageViewIndicator shows dots
- Global List<ChatViewModel>

AFTER:
- 7 pages = dates in current week
- No page indicator needed
- Map<date, ChatViewModel> created on-demand

HARD CONSTRAINTS:
- DO NOT change: TodayHeaderWidget, WeekStripWidget, CalendarWidget
- DO NOT add: new dependencies, new providers
- MUST keep: Consumer<TodayViewModel> pattern
- MUST preserve: calendar overlay behavior

VERIFICATION STEPS:
1. Confirm WeekModel still generates correct dates
2. Confirm swipe animation still smooth
3. Confirm date selection still works via calendar

DELIVERABLE:
- Step-by-step refactor plan
- Code changes (show before/after)
- Test checklist
```

### **For Implementing New Feature:**
```
IMPLEMENT a new feature: [feature name]

CONTEXT:
- App purpose: [what does this app do]
- Current architecture: [brief description]
- Related files: [list files]

REQUIREMENTS:
- Must do: [functional requirements]
- Must not do: [anti-requirements]
- Performance: [constraints]

ARCHITECTURE DECISIONS:
- Where does this fit in existing structure?
- What existing patterns should be reused?
- What new state management is needed?

THINKING PROCESS:
1. Analyze existing similar features
2. Identify reusable components
3. Design minimal implementation
4. Consider edge cases

DELIVERABLE:
- Implementation plan (numbered steps)
- Code changes per file
- How to test manually
- What could break and how to prevent it
```

### **For Code Review:**
```
REVIEW this code: [paste code or file path]

REVIEW CRITERIA:
- Correctness: does it work as intended?
- Performance: any unnecessary rebuilds?
- Architecture: follows existing patterns?
- Maintainability: easy to understand and modify?
- Edge cases: what happens when [edge case]?

REVIEW PROCESS:
1. First, explain what the code does
2. Identify potential issues
3. Suggest improvements with reasoning
4. Rate severity: Critical / Warning / Suggestion

DELIVERABLE:
- Summary of issues found
- Specific line references
- Suggested fixes with code
- Risk assessment of not fixing
```

---

## 5. Qwen-Specific Tips

| Technique | Why It Works | Example |
|-----------|-------------|---------|
| **Number lists** | Qwen processes structured data better | `1. First do X, 2. Then do Y, 3. Finally Z` |
| **Explicit DO NOT** | Prevents over-engineering | `DO NOT add new dependencies` |
| **Before/After** | Forces AI to understand delta | `BEFORE: X exists, AFTER: Y should exist` |
| **Verification steps** | Catches errors before output | `Verify that Z still works after change` |
| **Constraint first** | Bounds the solution space | `CONSTRAINTS: [list]` before asking for solution |
| **Explain WHY** | Forces deeper reasoning | `Explain WHY this approach over alternatives` |
| **File paths explicit** | Prevents wrong file edits | `Edit: lib/main_screen.dart, NOT lib/home_screen.dart` |
| **State what NOT to touch** | Prevents scope creep | `DO NOT modify: widgets/calendar_widget.dart` |

### **Qwen Strengths:**
- ✅ Good at following structured templates
- ✅ Good at explaining reasoning when asked
- ✅ Good at identifying trade-offs
- ✅ Good at step-by-step implementation

### **Qwen Weaknesses (Watch Out):**
- ❌ Tends to over-engineer if constraints not explicit
- ❌ May assume patterns without verifying existing code
- ❌ Can miss edge cases if not told to check them
- ❌ Sometimes summarizes when user wants full detail

### **How to Compensate Weaknesses:**
- Add: `"DO NOT over-engineer, minimal change only"`
- Add: `"First read existing files before proposing"`
- Add: `"List all edge cases you can think of"`
- Add: `"Do NOT summarize, show full implementation"`

---

## 6. Anti-Patterns (JANGAN Pakai)

### ❌ Vague Prompts:
```
"Make it better"
"Fix the bug"
"Improve performance"
"Refactor this"
"What do you think?"
```

### ❌ Missing Context:
```
"Add a new feature"
"Change the navigation"
"Update the UI"
```

### ❌ No Constraints:
```
"Implement X"
"Redesign Y"
"Make Z faster"
```

### ❌ No Expected State:
```
"Change the week strip"
"Update the page view"
"Fix the state management"
```

### ❌ Why These Fail:

| Anti-Pattern | What AI Does | Result |
|--------------|--------------|--------|
| "Make it better" | Guesses what "better" means | Wrong changes |
| "Fix the bug" | No context on expected behavior | Fixes wrong thing |
| "Improve performance" | No baseline, no target | Unnecessary optimization |
| "Refactor this" | No target architecture | Messier code |
| "What do you think?" | No direction, rambling | Wastes tokens, no value |

---

## 7. Real Project Examples (dietLog)

### ✅ **Good Prompt — Date-Centric Refactor:**
```
REFACTOR lib/main_screen.dart to be date-centric.

CONTEXT:
- App is a diet/health tracker with chat interface
- 7 swipeable pages, each representing a day in current week
- TodayViewModel manages selectedDate and WeekModel
- ChatViewModel manages messages per page

CURRENT STATE (BROKEN):
- 7 pages are hardcoded as categories (Today, Tasks, Habits, Notes, Stats, Goals, Settings)
- PageViewIndicator shows dots for categories
- List<ChatViewModel> created in initState, one per category
- Swiping pages doesn't update date selection

EXPECTED STATE:
- 7 pages = 7 dates in current week (Monday-Sunday)
- Swipe page → updates selectedDate in TodayViewModel
- Tap date in WeekStrip → updates selectedDate + swipes to that page
- ChatViewModel created on-demand per date, cached in Map<date, ChatViewModel>
- No page indicator needed (WeekStrip serves as visual indicator)

HARD CONSTRAINTS:
- DO NOT change: TodayHeaderWidget, WeekStripWidget, CalendarWidget implementations
- DO NOT add: new dependencies, new providers, new state classes
- MUST keep: Consumer<TodayViewModel> pattern for rebuilds
- MUST preserve: calendar overlay behavior
- MUST use: existing WeekModel.fromDate() for date generation

VERIFICATION STEPS:
1. Confirm WeekModel still generates correct Monday-Sunday dates
2. Confirm swipe animation still smooth (300ms easeInOut)
3. Confirm date selection still works via calendar tap
4. Confirm WeekStrip highlight matches active page

DELIVERABLE:
- Step-by-step refactor plan (numbered list)
- Code changes per file (show before/after blocks)
- Explanation of WHY this approach over alternatives
- Test checklist for manual verification
```

### ✅ **Good Prompt — Debug Navigation:**
```
DEBUG this navigation sync issue:

CONTEXT:
- App has 7 pages = 7 dates in current week
- Consumer<TodayViewModel> wraps header + week strip
- PageView.builder creates ChatPage per date
- _chatVmsByDate Map caches ChatViewModel per date

CURRENT BEHAVIOR (BUGGY):
- User swipes to page 3 → WeekStrip highlight updates correctly
- User taps date in WeekStrip → selectedDate updates but PageView doesn't swipe
- User picks date from calendar → sometimes swipes to wrong page

EXPECTED BEHAVIOR:
- Swipe page → WeekStrip highlight matches page index
- Tap date → PageView.animateToPage to that date's position
- Calendar pick → same as tap date

CONSTRAINTS:
- DO NOT change WeekStripWidget or CalendarWidget implementations
- DO NOT add new state variables
- MUST use existing _pageController and _swipeToDate method
- MUST keep Consumer<TodayViewModel> pattern

DEBUG PROCESS:
1. Trace data flow from each user action to UI update
2. Identify where the signal gets lost or miscalculated
3. Check _swipeToDate logic for edge cases
4. Verify date calculations are correct

DELIVERABLE:
- Root cause explanation (what, why, where)
- Code fix (show exact lines to change)
- Why this fix doesn't break other things
- Edge cases to watch for
```

### ✅ **Good Prompt — Implement Chat Persistence:**
```
IMPLEMENT chat message persistence per date.

CONTEXT:
- Each ChatViewModel holds messages for one date
- Messages currently live in memory only (lost on app restart)
- Need to persist messages to local storage (Hive)
- Map<date, ChatViewModel> already exists in main_screen.dart

REQUIREMENTS:
Must do:
- Save messages when user sends new message
- Load messages when ChatViewModel created
- Messages scoped to specific date (YYYY-MM-DD)
- Handle empty state gracefully

Must not do:
- Change ChatViewModel public API (sendMessage, messages list)
- Block UI during save/load operations
- Create multiple Hive boxes
- Change date key format

ARCHITECTURE:
- Hive box: "chat_messages"
- Key format: "YYYY-MM-DD" (same as _dateKey in main_screen.dart)
- Value: List<Message> serialized to JSON
- Load on ChatViewModel creation
- Save on every message add (debounced if needed)

THINKING PROCESS:
1. Review existing ChatViewModel structure
2. Design storage schema
3. Implement save/load methods
4. Integrate with existing ChatViewModel lifecycle
5. Handle errors (storage full, corrupted data)

DELIVERABLE:
- Hive storage service class
- Changes to ChatViewModel (constructor, sendMessage)
- Changes to main_screen.dart (_getChatVmForDate)
- Error handling strategy
- How to test (manual steps)
```

---

## 8. Quick Reference Card

### **GOOD PROMPT FORMULA:**
```
VERB + COMPONENT + CONTEXT + CONSTRAINTS + EXPECTED STATE + VERIFICATION

Example:
"Refactor WeekStripWidget (VERB + COMPONENT)
 for date-centric navigation (CONTEXT)
 - Must not change visual style (CONSTRAINT)
 - Must highlight based on page index (EXPECTED)
 - Verify WeekModel still works (VERIFICATION)"
```

### **Checklist Before Sending Prompt:**

- [ ] Did I include CONTEXT (what app does, current architecture)?
- [ ] Did I list CONSTRAINTS (what NOT to change, hard limits)?
- [ ] Did I describe CURRENT STATE (what exists, what's broken)?
- [ ] Did I describe EXPECTED STATE (what should happen)?
- [ ] Did I include VERIFICATION STEPS?
- [ ] Did I specify DELIVERABLES (what output I want)?
- [ ] Did I say what NOT to do (anti-requirements)?
- [ ] Is it specific enough (no vague words)?

### **When AI Makes Mistakes:**

```
"STOP. You made these mistakes:
1. [Specific mistake]
2. [Specific mistake]

CORRECT APPROACH:
- [What should have been done]
- [Why the current approach is wrong]

RETRY with these additional constraints:
- [New constraint to prevent same mistake]"
```

---

## 9. Flutter-Specific Prompting Tips

### **State Management:**
```
When asking about state:
- Specify WHICH state management (Provider, Riverpod, setState, etc)
- Specify what triggers rebuild
- Specify what should NOT rebuild

Example:
"Using Provider<TodayViewModel>:
- Consumer rebuilds when notifyListeners called
- context.read() does NOT subscribe to changes
- context.watch() DOES subscribe to changes
- Only wrap widgets that need to rebuild"
```

### **Widget Structure:**
```
When asking about widgets:
- Provide full widget tree if possible
- Specify which parts are fixed vs can change
- Mention existing patterns in project

Example:
"Current widget tree:
Scaffold
 └─ SafeArea
      └─ Column
           ├─ Consumer<TodayViewModel>  ← can change
           │    └─ TodayHeaderWidget    ← DO NOT change
           ├─ WeekStripWidget           ← can change
           └─ PageView                  ← DO NOT change

Refactor ONLY Consumer block to..."
```

### **Performance:**
```
When asking about performance:
- Specify the bottleneck
- Provide current behavior (what rebuilds when)
- Specify target behavior (what should/shouldn't rebuild)

Example:
"Performance issue:
- CURRENT: Entire HomeScreen rebuilds when selectedDate changes
- TARGET: Only WeekStripWidget rebuilds, header stays fixed
- CONSTRAINT: Cannot split TodayViewModel into multiple providers
- PATTERN: Use selector or separate Consumer blocks"
```

---

## 10. Advanced Techniques

### **Chain Prompting (Multi-Step Tasks):**
```
STEP 1: "Analyze this architecture and identify issues"
         → Wait for response, review

STEP 2: "Based on your analysis, propose refactor plan"
         → Wait for response, review

STEP 3: "Implement step 1 of refactor plan"
         → Wait for response, test

STEP 4: "Implement step 2 of refactor plan"
         → Continue until done
```

### **Socratic Prompting (Make AI Think Deeper):**
```
"Before implementing, answer these questions:
1. What assumptions are you making about the architecture?
2. What could go wrong with this approach?
3. What are 3 alternative approaches and why did you reject them?
4. What existing patterns in the codebase support your approach?
5. How would you test this works correctly?"
```

### **Constraint Stacking (For Complex Tasks):**
```
"Implement X with these constraints:
1. Must use existing Y pattern
2. Must not add new dependencies
3. Must not change Z file's public API
4. Must handle [edge case 1] and [edge case 2]
5. Must be testable with [specific test approach]
6. Must not increase rebuild frequency
7. Must preserve [specific behavior]

If any constraint is impossible, state which one and propose alternative."
```

---

## 11. Common Mistakes AI Makes & How to Prevent Them

| AI Mistake | Why It Happens | Prevention Prompt |
|------------|----------------|-------------------|
| Over-engineering | No constraints given | `"Minimal change only, DO NOT add abstractions"` |
| Wrong file paths | Didn't read project structure | `"First list all files you'll modify, verify paths exist"` |
| Breaking existing features | Didn't check dependencies | `"List all widgets that use this, verify they still work"` |
| Memory leaks | Forgot dispose | `"Show dispose logic, verify all controllers disposed"` |
| Rebuild loops | Wrong state management pattern | `"Explain when each widget rebuilds, verify no infinite loops"` |
| Type errors | Didn't check existing types | `"Verify types match existing API, show type signatures"` |
| Race conditions | Async not handled | `"Show async flow, verify no race conditions"` |

---

## 12. Template Library (Copy-Paste)

### **Template: Bug Fix**
```
FIX BUG in [component/file]

SYMPTOMS:
- What user sees: [description]
- When it happens: [steps to reproduce]
- Expected behavior: [what should happen]

CONTEXT:
- Architecture: [brief description]
- Related files: [list files]
- Recent changes: [what changed before bug appeared]

CONSTRAINTS:
- DO NOT change: [files/patterns to preserve]
- MUST keep: [behaviors that work]
- MUST fix: [specific issue]

DEBUG PROCESS:
1. Reproduce the bug mentally
2. Trace data flow from user action to UI
3. Identify where state diverges from expected
4. Propose minimal fix

DELIVERABLE:
- Root cause (1-2 sentences)
- Code fix (exact lines)
- Why fix works
- How to prevent recurrence
```

### **Template: New Feature**
```
IMPLEMENT [feature name]

PURPOSE:
- User problem solved: [what pain point]
- Business value: [why do this]

REQUIREMENTS:
Functional:
- [ ] Must do X when user does Y
- [ ] Must show Z state when empty
- [ ] Must handle error case E

Non-functional:
- [ ] Must not block UI
- [ ] Must persist across restarts
- [ ] Must follow existing design system

ARCHITECTURE:
- Where it fits: [location in codebase]
- Patterns to reuse: [existing similar features]
- State management: [how state flows]

THINKING PROCESS:
1. Analyze 2-3 similar existing features
2. Extract reusable components/patterns
3. Design minimal implementation
4. Consider edge cases and error states
5. Plan testing approach

DELIVERABLE:
- Implementation plan (numbered steps)
- Code changes per file
- New files created (if any)
- Manual test checklist
- Known limitations
```

### **Template: Refactor**
```
REFACTOR [component/file]

WHY REFACTOR:
- Current problem: [what's wrong]
- Pain point: [why change now]
- Goal: [what success looks like]

BEFORE:
- Current architecture: [description]
- What works: [keep these]
- What's broken: [fix these]
- What's messy: [clean these]

AFTER:
- Target architecture: [description]
- What stays same: [preserve these]
- What changes: [modify these]
- What gets simpler: [improve these]

CONSTRAINTS:
- DO NOT break: [behaviors that must work]
- DO NOT change: [files/APIs to preserve]
- MUST maintain: [patterns/contracts]
- MUST improve: [metrics that get better]

VERIFICATION:
- [ ] Test 1: [specific behavior]
- [ ] Test 2: [specific behavior]
- [ ] Test 3: [specific behavior]

DELIVERABLE:
- Step-by-step plan (do these in order)
- Code changes per step
- How to verify each step works
- Rollback plan if something breaks
```

### **Template: Code Review**
```
REVIEW [file/PR/component]

REVIEW SCOPE:
- What to review: [specific code]
- What NOT to review: [out of scope]
- Review depth: [surface / detailed]

REVIEW CRITERIA:
Correctness:
- Does it work as intended?
- Edge cases handled?
- Error states covered?

Performance:
- Unnecessary rebuilds?
- Memory leaks?
- N+1 queries or loops?

Architecture:
- Follows existing patterns?
- Proper separation of concerns?
- State management correct?

Maintainability:
- Clear and readable?
- Future changes easy?
- Tests adequate?

SECURITY:
- User input sanitized?
- Sensitive data protected?
- Auth checks in place?

DELIVERABLE:
- Summary (1 paragraph)
- Issues by severity (Critical/Warning/Suggestion)
- Specific line references
- Suggested fixes with code
- Risk if not fixed
```

---

## 13. When Things Go Wrong (Recovery Prompts)

### **AI Implemented Wrong Thing:**
```
STOP. You implemented the wrong thing.

WHAT YOU DID:
- [Describe what AI did]

WHAT I ACTUALLY WANTED:
- [Describe what you wanted]

WHY THE MISMATCH:
- [Identify what was unclear in prompt]

RETRY WITH THIS ADDITIONAL CONTEXT:
- [Clarify ambiguity]
- [Add missing constraint]
- [Specify expected behavior more clearly]

DO NOT:
- [What AI should avoid]
```

### **AI Broke Existing Feature:**
```
YOUR CHANGE BROKE [feature].

WHAT BROKE:
- [Describe broken behavior]
- [Steps to reproduce]

WHAT SHOULD BE PRESERVED:
- [Describe working behavior before change]
- [Constraint that was violated]

FIX THIS BY:
- [Guidance on how to fix]
- [What to check before implementing]
- [Test to run after fix]

BEFORE SUBMITTING FIX:
- Verify [feature] still works
- Verify [new feature] works
- Run [specific test]
```

### **AI Over-Engineered:**
```
YOU OVER-ENGINEERED THE SOLUTION.

WHAT YOU DID:
- [List unnecessary abstractions/complexity]

WHAT I WANTED:
- Minimal change to [specific file/component]
- Reuse existing [pattern/widget]
- Do NOT add [abstractions]

SIMPLIFY TO:
- [Describe minimal solution]
- [Maximum N lines of code]
- [Only change X, Y, Z]

CONSTRAINT: Simplest thing that works, nothing more.
```

---

## 14. Final Checklist — Before Sending Any Prompt

### **Essential Elements:**
- [ ] **VERB** clearly stated (Design/Implement/Debug/Refactor/Review)
- [ ] **COMPONENT** specified (file path, widget name, function)
- [ ] **CONTEXT** provided (app purpose, architecture, related features)
- [ ] **CURRENT STATE** described (what exists, what's broken)
- [ ] **EXPECTED STATE** described (what should happen)
- [ ] **CONSTRAINTS** listed (what NOT to change, hard limits)
- [ ] **VERIFICATION** steps included (how to check it works)
- [ ] **DELIVERABLES** specified (what output format you want)

### **Quality Checks:**
- [ ] No vague words ("better", "fix", "improve" without context)
- [ ] No assumptions left unstated
- [ ] File paths verified to exist
- [ ] Existing patterns mentioned
- [ ] Edge cases called out
- [ ] Anti-requirements included (what NOT to do)
- [ ] Success criteria defined

### **If Prompt is Too Long:**
- Split into multiple chained prompts
- Use STEP 1, STEP 2, STEP 3 approach
- Wait for response after each step
- Build on previous responses

---

**END OF GUIDE**

*Remember: AI is only as good as the prompt. Garbage in, garbage out. Be specific, be explicit, be structured.*
