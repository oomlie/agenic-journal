# Agenic Journal - Usage Guide

Full documentation for all scripts and workflows.

## Table of Contents

- [Daily Workflow](#daily-workflow)
- [Scripts Reference](#scripts-reference)
- [Git Hooks](#git-hooks)
- [Habit Tracking](#habit-tracking)
- [Weekly Review](#weekly-review)
- [Sunday Ritual](#sunday-ritual)
- [Tips](#tips)

---

## Daily Workflow

### Morning: Create Your Entry

```bash
./scripts/new-day
```

This scaffolds a new entry from `templates/daily.md` with today's date and day
name filled in. The template includes:

- Morning energy/mood/intention check-in
- 3 time-block sections with priorities
- Log section for quick notes
- Habits checklist
- Evening reflection (wins, struggles, gratitude, tomorrow setup)

### Throughout the Day: Log Notes

```bash
./scripts/log "meeting with sarah about the api"
./scripts/log "finally fixed the bug" -t win
./scripts/log "feeling overwhelmed by scope" -t struggle
```

Each log entry is automatically timestamped and appended to today's Log section.
Tags (with `#tag`) are optional and help with later filtering.

### End of Day: Roll Tasks

```bash
./scripts/rollover
```

Unchecked `[ ]` tasks from your Top 3 Priorities and Tomorrow's Setup are
carried forward to today. Old tasks are marked `[>]` (carried) so you can track
what travelled.

---

## Scripts Reference

### `scripts/new-day [YYYY-MM-DD]`

Create a new journal entry. Without arguments, uses today. Refuses to overwrite
existing entries.

**Output:**
```
+---------------------------------------------------+
|                  NEW DAY CREATED                   |
+---------------------------------------------------+
|  2026-07-13 -- Monday
|  2026/07-july/2026-07-13.md
+---------------------------------------------------+
```

### `scripts/log "NOTE" [-d DATE] [-t TAG]`

Append a timestamped note to an entry's Log section.

| Option | Description |
|--------|-------------|
| `-d DATE` | Target date (default: today) |
| `-t TAG`  | Add a hashtag (e.g., `-t win`) |

The log line format is: `- HH:MM -- your note #tag`

**Output:**
```
+---------------------------------------------------+
|                     LOGGED                         |
+---------------------------------------------------+
|  - 14:32 -- meeting with sarah about the api
+---------------------------------------------------+
```

### `scripts/rollover [YYYY-MM-DD]`

Carry unchecked tasks from the previous day (or specified date) forward.

- Source day: tasks marked `[ ]` become `[>]` (carried)
- Target day: carried tasks inserted as "Rolled Over" block

**Output:**
```
+---------------------------------------------------+
|              TASKS ROLLED OVER                     |
+---------------------------------------------------+
|  3 task(s) from 2026-07-12 -> 2026-07-13
|                                                   |
|  Run 'git commit' when ready.                     |
|  Hooks will auto-message it.                      |
+---------------------------------------------------+
```

### `scripts/week-review [YYYY-MM-DD]`

Generate a weekly review markdown file in `reviews/`.

Aggregates across the 7 days ending on the specified date (default: today):
- Tasks completed vs rolled counts
- Average energy level
- Top tags with counts
- All wins and struggles
- Complete daily logs
- Habit check-in table

### `scripts/remember [MIN MAX | --today]`

Resurface a random past entry.

| Mode | Description |
|------|-------------|
| Default (no args) | Random entry from 30-90 days ago |
| `MIN MAX` | Custom day range |
| `--today` | Entry from exactly 1 year ago |

**Output:**
```
+---------------------------------------------------+
|         MEMORY FROM  45 DAYS AGO                  |
|              2026-05-28                           |
+---------------------------------------------------+
```

### `scripts/habits [YYYY MM | --fill]`

Tally habit completion from daily entries.

| Mode | Description |
|------|-------------|
| Default (no args) | Current month's habit table |
| `YYYY MM` | Specific month |
| `--fill` | Inject habit table into latest weekly review |

Habits are read from the `## Habits` section of each day's entry. The tracker
seeds streaks by walking backward from month start to handle month boundaries.

### `scripts/streak [--month | --year]`

Show journaling streak statistics.

| Mode | Description |
|------|-------------|
| Default | All-time stats |
| `--month` | Current month only |
| `--year` | Current year only |

The fire ASCII art scales with your streak:
- **0 days**: cold ashes
- **1-6 days**: small flame
- **7-29 days**: roaring fire
- **30+ days**: inferno

### `scripts/setup-hooks`

Enable the `.githooks/` directory for this repo (run once after clone).

---

## Git Hooks

### `prepare-commit-msg`

Auto-generates commit messages for journal entries by analyzing the diff:

```
2026-07-13 -- journal update (afternoon, 14:32)

Tasks: 2 completed, 1 added
```

### `post-commit`

Appends a lightweight entry to `.journal-log` after each journal commit:

```
[2026-07-13 14:32:05 +0000] a1b2c3d -- 2026-07-13 -- journal update (afternoon, 14:32)
```

This creates a rhythm log you can grep for journaling patterns.

---

## Habit Tracking

Each daily entry includes a Habits section:

```markdown
## Habits
- [ ] Exercise
- [ ] Read
- [ ] Meditate
- [ ] Deep Work
- [ ] Sleep 8h
```

Check them off as you complete them:
```markdown
- [x] Exercise
- [x] Read
- [ ] Meditate
```

Then run `./scripts/habits` to see your monthly tally. It writes a full table
to `<year>/<month>/habits.md` and prints a summary:

```
Habit tracker saved: 2026/07-july/habits.md

Summary for 2026-07:
  Exercise: 23 days, best streak: 12
  Read: 18 days, best streak: 6
  Meditate: 15 days, best streak: 4
  Deep Work: 20 days, best streak: 9
  Sleep 8h: 25 days, best streak: 14
```

`habits.md` itself starts with a `# Habit Tracker -- 2026-07` heading followed
by a markdown table with one column per day and a Total/Streak column per habit.

### Adding Custom Habits

Edit `templates/daily.md` to change the default habit list. Existing entries
keep their original habit list -- only new entries pick up the template changes.

---

## Weekly Review

Every Sunday (or whenever you run `./scripts/week-review`), a review file is
generated in `reviews/YYYY-W##.md`:

```markdown
# Week 28 Review -- 2026-07-06 to 2026-07-12

## Snapshot

| Metric | Value |
|--------|-------|
| Days Journaled | 7 / 7 |
| Tasks Completed | 12 / 15 (80%) |
| Tasks Rolled Over | 3 |
| Avg Energy | 6 / 10 |

### Top Tags
- #deepwork
- #win

---

## Wins This Week
**Monday**: 1. shipped the new feature

---

## Struggles / Patterns
**Wednesday**: scope creep on the api redesign

---

## Daily Logs
### Monday
- 09:15 -- meeting with sarah about the api

---

## Habit Check-In

*Run `./scripts/habits --fill` to auto-fill from daily entries.*

| Habit | Mon | Tue | Wed | Thu | Fri | Sat | Sun | Streak |
|-------|-----|-----|-----|-----|-----|-----|-----|--------|
| Exercise | | | | | | | | |

---

## Looking Ahead

- [ ] Priority for next week:
- [ ] Something to try differently:
- [ ] One thing to look forward to:
```

---

## Sunday Ritual

Run all three review commands in sequence:

```bash
./scripts/week-review && ./scripts/habits --fill && ./scripts/streak
```

This gives you:
1. A compiled weekly review
2. Habit check-in table appended to the review
3. Streak status with fire ASCII

---

## Tips

- **Commit often**: Every `./scripts/log` is worth committing. The hooks handle
  the message.
- **Tag everything**: Use consistent tags for filtering later (`#win`,
  `#struggle`, `#deepwork`)
- **Phone friendly**: Works great with Working Copy (iOS) or Termux (Android)
  plus a Bluetooth keyboard
- **Compact by design**: The template is scannable at a glance, without a lot
  of scrolling
- **All ASCII**: Every output is plain ASCII for universal terminal compatibility
- **Search with git**: `git log -S "keyword"` searches across all history
