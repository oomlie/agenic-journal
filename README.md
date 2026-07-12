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
│   └── log                 # One-liner quick log to today's entry
├── templates/
│   └── daily.md
├── 2026/
│   ├── 07-july/
│   │   ├── 2026-07-13.md
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

This enables automated commit messages with timestamps and a lightweight journaling rhythm log.

### 2. Create Today's Entry

```bash
./scripts/new-day           # Creates entry for today
./scripts/new-day 2026-07-15  # Creates entry for a specific date
```

This scaffolds a new file from the template at the correct path:
```
2026/07-july/2026-07-13.md
```

### 3. Log Quick Notes Throughout the Day

```bash
./scripts/log "got lunch at panda express"
./scripts/log "meeting running 20 min late"
./scripts.log "just shipped the feature" -t win
```

Each note gets timestamped and appended to today's Log section:
```markdown
## Log

- 12:34 — got lunch at panda express
- 14:52 — meeting running 20 min late
- 17:08 — just shipped the feature #win
```

Auto-commits with a short message: `[2026-07-13 17:08] just shipped the feature`

**Options:**
- `-d YYYY-MM-DD` — log to a specific date's entry
- `-t tag` — add a tag: `#win`, `#struggle`, `#adhd`, `#deepwork`, `#health`
- `-n` — append without committing (stage only, commit later)

### 4. Journal & Commit

Fill out the rest of your entry as you go. Commit whenever you want a snapshot:

```bash
git add .
git commit  # Message auto-generated: "2026-07-13 — journal update (afternoon, 14:32)"
```

The hooks detect journal files and auto-format your commit message with the date, time of day, and task progress.

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

## Daily Entry Format

See [templates/daily.md](templates/daily.md) for the full template. Each day includes:

- **Morning**: Intentions, top 3 priorities, energy level
- **Time Blocks**: Chunked sessions with focus tasks
- **Log**: Stream-of-consciousness notes, distractions, wins
- **Evening**: Reflection, gratitude, tomorrow's setup

## Git Hooks

### `prepare-commit-msg`
When you commit a journal entry, this hook auto-generates the commit message:

```
2026-07-13 — journal update (afternoon, 14:32)

Tasks: 2 completed, 1 added
```

It detects the time of day (morning/afternoon/evening), extracts the entry date from the filename, and counts your task progress.

### `post-commit`
After each journal commit, a lightweight entry is appended to `.journal-log`:

```
[2026-07-13 14:32:00 +0000] a1b2c3d — 2026-07-13 — journal update (afternoon, 14:32)
```

This lets you track your journaling rhythm over time without heavy analytics.

## Tips

- **Commit often**: Each commit is a save point. Don't overthink it.
- **Phone + keyboard**: Works great with a mobile Git client (Working Copy, Termux) + Bluetooth keyboard
- **A6 friendly**: The template is designed to feel like a pocket notebook — compact and scannable
- **Tag entries**: Use `#adhd`, `#deepwork`, `#win`, `#struggle` for later filtering
