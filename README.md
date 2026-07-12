#Agenic-Journal

A text-based calendar and journaling system powered by Git. Designed for
low-friction daily tracking, reflection, and task management.

## Philosophy

- **Text-first**: Everything is plain text -- portable, future-proof, searchable
- **Git-backed**: Every entry is versioned. Look back at any day, any moment
- **Low friction**: Minimal structure, maximum flexibility
- **ADHD-friendly**: Chunked, time-boxed, dopamine-paired

## Directory Structure

```
agenic-journal/
|-- .githooks/              # Custom Git hooks (auto date-stamping)
|-- .journal-log            # Lightweight commit rhythm tracker
|-- scripts/
|   |-- journal              # Unified CLI (all commands)
|-- templates/
|   |-- daily.md
|-- reviews/                # Weekly review files
|   |-- 2026-W28.md
|-- 2026/
|   |-- 07-july/
|   |   |-- 2026-07-13.md
|   |   |-- habits.md
|   |   |-- 2026-07-14.md
|   |-- 08-august/
|-- archive/
    |-- old-notes.md
```

## Quick Start

### 1. Enable Git Hooks (one-time setup)

```bash
./scripts/journal setup
```

### 2. Create Today's Entry

```bash
./scripts/journal new           # Creates entry for today
./scripts/journal new 2026-07-15  # Creates entry for a specific date
```

Output:
```
+---------------------------------------------------+
|                  NEW DAY CREATED                   |
+---------------------------------------------------+
|  2026-07-13 -- Monday
|  /path/to/2026/07-july/2026-07-13.md
+---------------------------------------------------+
```

### 3. Log Quick Notes Throughout the Day

```bash
./scripts/journal log "got lunch at panda express"
./scripts/journal log "just shipped the feature" -t win
```

Each note gets timestamped and appended to today's Log section:
```markdown
## Log

- 12:34 -- got lunch at panda express
- 17:08 -- just shipped the feature #win
```

Output:
```
+---------------------------------------------------+
|                     LOGGED                         |
+---------------------------------------------------+
|  - 12:34 -- got lunch at panda express
+---------------------------------------------------+
```

### 4. Roll Over Yesterday's Tasks

```bash
./scripts/journal rollover          # Carry unchecked tasks -> today
```

Output:
```
+---------------------------------------------------+
|              TASKS ROLLED OVER                     |
+---------------------------------------------------+
|  3 task(s) from 2026-07-12 -> 2026-07-13          |
|                                                   |
|  Run 'git commit' when ready.                     |
|  Hooks will auto-message it.                      |
+---------------------------------------------------+
```

Yesterday's `[ ]` tasks become today's "Rolled Over" priority block.
The old tasks are marked `[>]` so you know they travelled.

### 5. Weekly Review (Sunday afternoons)

```bash
./scripts/journal review       # Summarize the past 7 days
```

Generates a review file in `reviews/2026-W28.md` with:
- Tasks completed/rolled stats
- Average energy level
- Top tags
- All wins and struggles aggregated
- Daily logs compiled
- ASCII art habit check-in table

### 6. Memory Resurfacing

```bash
./scripts/journal remember          # Random entry from 30-90 days ago
./scripts/journal remember --today  # Entry from exactly 1 year ago
./scripts/journal remember 60 120   # Custom range (min max days back)
```

Output:
```
+---------------------------------------------------+
|         MEMORY FROM  45 DAYS AGO                  |
|              2026-05-28                           |
+---------------------------------------------------+
```

### 7. Habit Tracker

Daily entries include a Habits section:
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
./scripts/journal habits              # Current month's full habit table
./scripts/journal habits 2026 07      # Specific month
./scripts/journal habits --fill       # Inject into latest weekly review
```

### 8. Streak Counter

```bash
./scripts/journal streak              # All-time stats
./scripts/journal streak --month      # This month only
./scripts/journal streak --year       # This year only
```

Output:
```
         )
        (  )
       .'  '.
      / ~  ~ \
     |        |
      \      /
       '....'
      /      \
     '________'
+---------------------------------------------------+
|                 JOURNAL STREAKS                    |
+---------------------------------------------------+
|  All Time                                         |
|                                                   |
|  Current Streak : 12 days
|  Longest Streak : 23 days
|  Total Entries  : 89
|  First Entry    : 2026-04-15
|                                                   |
|  Milestones:                                      |
|    7-day streak  [*]
|    30-day streak [ ]
|    100-day streak [ ]
|                                                   |
|  This Week      : 5 / 7 days
+---------------------------------------------------+
```

The fire ASCII grows as your streak does:
- **0 days**: cold ashes
- **1-6 days**: small flame
- **7-29 days**: roaring fire
- **30+ days**: inferno

## Full Command Reference

Run `./scripts/journal help` to see all commands at any time.

```
COMMANDS
  new [YYYY-MM-DD]              Create today's entry (or specific date)
  log "NOTE" [-d DATE] [-t TAG] [-n]  Append a timestamped note
  rollover [YYYY-MM-DD]         Roll unchecked tasks from yesterday (or date)
  review [YYYY-MM-DD]           Generate weekly review (current or from date)
  habits [YYYY MM | --fill]     Tally habit streaks (monthly) or fill review
  remember [MIN MAX | --today]  Resurface random entry (30-90 days default)
  streak [--month | --year]     Show journaling streak stats
  setup                         Enable Git hooks (run once after clone)
  help                          Show this help
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

### prepare-commit-msg
Auto-generates commit messages for journal entries:
```
2026-07-13 -- journal update (afternoon, 14:32)

Tasks: 2 completed, 1 added
```

### post-commit
Appends a lightweight entry to `.journal-log` after each journal commit for
rhythm tracking.

## Sunday Ritual

```bash
./scripts/journal review && ./scripts/journal habits --fill && ./scripts/journal streak
```

One command, full weekly retrospective + habit check-in + streak check.

## Tips

- **Commit often**: Each commit is a save point. Don't overthink it.
- **Phone + keyboard**: Works great with a mobile Git client (Working Copy,
  Termux) + Bluetooth keyboard
- **A6 friendly**: The template is designed to feel like a pocket notebook --
  compact and scannable
- **Tag entries**: Use `#adhd`, `#deepwork`, `#win`, `#struggle` for later
  filtering
- **All ASCII**: Every output is plain ASCII -- renders cleanly in any terminal,
  editor, or pager
