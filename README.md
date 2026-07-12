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
├── README.md
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

1. Each day gets its own file: `YYYY/MM-MONTH/YYYY-MM-DD.md`
2. Copy `templates/daily.md` to start your day
3. Fill it out as you go — check off tasks, jot reflections, log time blocks
4. Commit whenever you want a snapshot (morning plan, midday check-in, evening wrap)

## Journal as Calendar

Your Git history *is* your calendar. Each commit is a moment in time.

```bash
# View all journal days
git log --oneline --all

# See what you did on a specific week
git log --since="1 week ago" --oneline

# Find when you wrote about something
grep -r "keyword" 2026/
```

## Daily Entry Format

See [templates/daily.md](templates/daily.md) for the full template. Each day includes:

- **Morning**: Intentions, top 3 priorities, energy level
- **Time Blocks**: Chunked sessions with focus tasks
- **Log**: Stream-of-consciousness notes, distractions, wins
- **Evening**: Reflection, gratitude, tomorrow's setup

## Tips

- **Commit often**: Each commit is a save point. Don't overthink it.
- **Phone + keyboard**: Works great with a mobile Git client (Working Copy, Termux) + Bluetooth keyboard
- **A6 friendly**: The template is designed to feel like a pocket notebook — compact and scannable
- **Tag entries**: Use `#adhd`, `#deepwork`, `#win`, `#struggle` for later filtering
