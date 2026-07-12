# Agenic Journal

A text-based calendar and journaling system powered by Git. Designed for
low-friction daily tracking, reflection, and task management.

## Philosophy

- **Text-first**: Everything is plain text -- portable, future-proof, searchable
- **Git-backed**: Every entry is versioned. Look back at any day, any moment
- **Low friction**: Minimal structure, maximum flexibility
- **Structured but flexible**: Templated sections with room to deviate

## Directory Structure

```
agenic-journal/
|-- .githooks/              # Custom Git hooks (auto date-stamping)
|-- .shellcheckrc           # Shellcheck configuration
|-- .github/workflows/ci.yml # CI pipeline
|-- flake.nix               # Nix development environment
|-- scripts/
|   |-- lib/
|   |   |-- common.sh       # Shared library (15 helper functions)
|   |-- new-day             # Create daily entries
|   |-- log                 # Append timestamped notes
|   |-- rollover            # Carry unchecked tasks forward
|   |-- week-review         # Generate weekly review
|   |-- remember            # Resurface random past entries
|   |-- habits              # Tally habit streaks
|   |-- streak              # Show journaling streaks
|   |-- setup-hooks         # Enable Git hooks (one-time)
|-- templates/
|   |-- daily.md            # Entry template with Habits section
|-- reviews/                # Weekly review files
|   |-- 2026-W28.md
|-- 2026/
|   |-- 07-july/
|   |   |-- 2026-07-13.md
|   |   |-- 2026-07-14.md
|   |-- 08-august/
|-- tests/                  # bats-core test suite
|   |-- test_helper.bash
|   |-- new-day.bats
|   |-- log.bats
|   |-- rollover.bats
|   |-- week_review.bats
|   |-- habits.bats
|   |-- remember.bats
|   |-- streak.bats
|-- docs/
|   |-- USAGE.md
|-- LICENSE
```

## Quick Start

### 1. Enable Git Hooks (one-time setup)

```bash
./scripts/setup-hooks
```

### 2. Create Today's Entry

```bash
./scripts/new-day
./scripts/new-day 2026-07-15  # specific date
```

Output:
```
+---------------------------------------------------+
|                  NEW DAY CREATED                   |
+---------------------------------------------------+
|  2026-07-13 -- Monday
|  2026/07-july/2026-07-13.md
+---------------------------------------------------+
```

### 3. Log Quick Notes Throughout the Day

```bash
./scripts/log "got lunch at panda express"
./scripts/log "just shipped the feature" -t win
```

Each note gets timestamped and appended to today's Log section:
```markdown
## Log

- 12:34 -- got lunch at panda express
- 17:08 -- just shipped the feature #win
```

### 4. Roll Over Yesterday's Tasks

```bash
./scripts/rollover          # from yesterday -> today
./scripts/rollover 2026-07-13  # from specific date
```

Yesterday's `[ ]` tasks become today's "Rolled Over" priority block.
Old tasks are marked `[>]` so you know they travelled.

### 5. Weekly Review (Sunday afternoons)

```bash
./scripts/week-review       # summarize past 7 days
```

Generates a review file in `reviews/2026-W28.md` with tasks completed/rolled
stats, average energy, top tags, wins/struggles aggregated, daily logs
compiled, and ASCII habit check-in table.

### 6. Memory Resurfacing

```bash
./scripts/remember              # random entry from 30-90 days ago
./scripts/remember --today      # entry from exactly 1 year ago
./scripts/remember 60 120       # custom range (min max days)
```

### 7. Habit Tracker

Daily entries include a Habits section. Check them off as you go, then tally:

```bash
./scripts/habits              # current month's full habit table
./scripts/habits 2026 07      # specific month
./scripts/habits --fill       # inject into latest weekly review
```

### 8. Streak Counter

```bash
./scripts/streak              # all-time stats
./scripts/streak --month      # this month only
./scripts/streak --year       # this year only
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

## Scripts Architecture

All scripts source `scripts/lib/common.sh`, which provides:

| Function | Purpose |
|---|---|
| `journal_require_repo_root` | Ensure CWD is a Git repo |
| `journal_validate_date` | Validate `YYYY-MM-DD` format |
| `journal_month_name` | Convert `01-12` to month name |
| `journal_month_name_from_date` | Extract month name from date |
| `journal_day_name` | Get day name for a date |
| `journal_add_days` | Add/subtract days from a date |
| `journal_days_in_month` | Days in a given month/year |
| `journal_epoch` | Convert date to Unix epoch |
| `journal_day_of_week` | Numeric day of week (0=Sun) |
| `journal_iso_week` | ISO week number for a date |
| `journal_entry_path` | Resolve filepath for a date |
| `journal_month_dir` | Resolve directory for a date |
| `journal_insert_after_line` | Safe multi-line file insertion |
| `journal_date_from_filename` | Extract date from filepath |

**Shared constant:** `JOURNAL_LOG_LINE_REGEX='^- [0-9]{2}:[0-9]{2} --'` -- used
by both `log` (producer) and `week-review` (consumer) so formats never drift.

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
./scripts/week-review && ./scripts/habits --fill && ./scripts/streak
```

One command, full weekly retrospective + habit check-in + streak check.

## Development

### With Nix

```bash
nix develop          # Enter dev shell with shellcheck + bats
nix build            # Build the package
nix flake check      # Run shellcheck + bats tests
```

### Without Nix

```bash
# Install test dependencies
sudo apt-get install shellcheck bats

# Run linter
shellcheck scripts/lib/common.sh scripts/*

# Run tests
bats tests/
```

### CI

`.github/workflows/ci.yml` runs `nix flake check` on every push/PR, which in
turn runs both the shellcheck and bats-core checks defined in `flake.nix`.

## Tips

- **Commit often**: Each commit is a save point. Don't overthink it.
- **Phone + keyboard**: Works great with a mobile Git client (Working Copy,
  Termux) + Bluetooth keyboard
- **Compact by design**: The template is scannable at a glance, without a lot
  of scrolling
- **Tag entries**: Use `#deepwork`, `#win`, `#struggle` for later filtering
- **All ASCII**: Every output is plain ASCII -- renders cleanly in any terminal,
  editor, or pager
