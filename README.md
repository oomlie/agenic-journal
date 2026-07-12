# Agenic Journal

A text-based calendar and journaling system powered by Git. Designed for low-friction daily tracking, reflection, and task management.

## Philosophy

- **Text-first**: Everything is plain text — portable, future-proof, searchable
- **Git-backed**: Every entry is versioned. Look back at any day, any moment
- **Low friction**: Minimal structure, maximum flexibility
- **ADHD-friendly**: Chunked, time-boxed, dopamine-paired

## Directory Structure

```
agenic-journal/
├── .githooks/              # Custom Git hooks (auto date-stamping)
├── .journal-log            # Lightweight commit rhythm tracker
├── scripts/
│   ├── setup-hooks         # Enable hooks after cloning
│   ├── new-day             # Scaffold a new daily entry
│   ├── log                 # One-liner quick log to today's entry
│   ├── rollover            # Carry unchecked tasks to today
│   ├── week-review         # Generate weekly summary (run Sundays)
│   ├── remember            # Resurface a random past entry
│   └── habits              # Tally habit streaks for the month
├── templates/
│   └── daily.md
├── reviews/                # Weekly review files
│   └── 2026-W28.md
├── 2026/
│   ├── 07-july/
│   │   ├── 2026-07-13.md
│   │   ├── habits.md
│   │   └── 2026-07-14.md
│   └── 08-august/
└── archive/
    └── old-notes.md
```

## Quick Start

### 1. Enable Git Hooks (one-time setup)

```bash
./scripts/setup-hooks
```

### 2. Create Today's Entry

```bash
./scripts/new-day           # Creates entry for today
./scripts/new-day 2026-07-15  # Creates entry for a specific date
```

### 3. Log Quick Notes Throughout the Day

```bash
./scripts/log "got lunch at panda express"
./scripts/log "just shipped the feature" -t win
```

Each note gets timestamped and appended to today's Log section:
```markdown
- 12:34 — got lunch at panda express
- 17:08 — just shipped the feature #win
```

### 4. Roll Over Yesterday's Tasks

```bash
./scripts/rollover          # Carry unchecked tasks → today
```

Yesterdays's `[ ]` tasks become today's "Rolled Over" priority block. The old tasks are marked `[>]` so you know they travelled.

### 5. Weekly Review (Sunday afternoons)

```bash
./scripts/week-review       # Summarize the past 7 days
```

Generates a review file in `reviews/2026-W28.md` with:
- Tasks completed/rolled stats
- Average energy level
- Top tags
- All wins and struggles aggregated
- Daily logs compiled
- Habit check-in table (fill after running `./scripts/habits`)

### 6. Memory Resurfacing

```bash
./scripts/remember          # Random entry from 30–90 days ago
./scripts/remember --today  # Entry from exactly 1 year ago
./scripts/remember 60 120   # Custom range (min max days back)
```

### 7. Habit Tracker

Daily entries include a **Habits** section:
```markdown
## Habits
- [ ] Exercise
- [ ] Read
- [ ] Meditate
- [ ] Deep Work
- [ ] Sleep 8h
```

Check them off as you go. Then tally:
```bash
./scripts/habits              # Current month's streaks
./scripts/habits 2026 07      # Specific month
./scripts/habits --fill       # Auto-fill latest weekly review table
```

## Journal as Calendar

Your Git history *is* your calendar. Each commit is a moment in time.

```bash
# View all journal days
git log --oneline --all

# See what you did on a specific week
git log --since="1 week ago" --oneline

# Find when you wrote about something
grep -r "keyword" 2026/

# Check your journaling rhythm
cat .journal-log
```

## Git Hooks

### `prepare-commit-msg`
Auto-generates commit messages for journal entries:
```
2026-07-13 — journal update (afternoon, 14:32)

Tasks: 2 completed, 1 added
```

### `post-commit`
Appends a lightweight entry to `.journal-log` after each journal commit for rhythm tracking.

## Tips

- **Commit often**: Each commit is a save point. Don't overthink it.
- **Phone + keyboard**: Works great with a mobile Git client (Working Copy, Termux) + Bluetooth keyboard
- **A6 friendly**: The template is designed to feel like a pocket notebook — compact and scannable
- **Tag entries**: Use `#adhd`, `#deepwork`, `#win`, `#struggle` for later filtering
- **Sunday ritual**: Run `week-review` + `habits --fill` for a clean weekly retrospective
