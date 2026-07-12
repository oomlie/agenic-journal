#!/usr/bin/env bats

load test_helper

@test "habits shows current month table" {
  # Create entries with habits checked
  mkentry 2026-07-01 "# 2026-07-01 -- Wednesday

## Habits
- [x] Exercise
- [ ] Read
- [x] Meditate
"
  mkentry 2026-07-02 "# 2026-07-02 -- Thursday

## Habits
- [x] Exercise
- [x] Read
- [ ] Meditate
"
  run_script habits 2026 07
  [ "$status" -eq 0 ]
  [[ "$output" == *"Habit tracker saved"* ]]
  [[ "$output" == *"Exercise"* ]]
  [[ "$output" == *"Read"* ]]
  # The generated table file itself should carry the real heading
  grep -q "^# Habit Tracker -- 2026-07$" "2026/07-july/habits.md"
}

@test "habits seeds streaks across month boundary" {
  # June 30 has exercise checked
  mkentry 2026-06-30 "# 2026-06-30 -- Tuesday

## Habits
- [x] Exercise
"
  # July 1 also checked -- streak should span the boundary and read 2,
  # not reset to 1 as it did before the month-boundary seeding fix (bug c).
  mkentry 2026-07-01 "# 2026-07-01 -- Wednesday

## Habits
- [x] Exercise
"
  run_script habits 2026 07
  [ "$status" -eq 0 ]
  [[ "$output" == *"Exercise: 1 days, best streak: 2"* ]]
}
