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
  [[ "$output" == *"HABIT TRACKER"* ]]
  [[ "$output" == *"Exercise"* ]]
  [[ "$output" == *"Read"* ]]
}

@test "habits seeds streaks across month boundary" {
  # June 30 has exercise checked
  mkentry 2026-06-30 "# 2026-06-30 -- Tuesday

## Habits
- [x] Exercise
"
  # July 1 also checked
  mkentry 2026-07-01 "# 2026-07-01 -- Wednesday

## Habits
- [x] Exercise
"
  run_script habits 2026 07
  [ "$status" -eq 0 ]
  [[ "$output" == *"Exercise"* ]]
}
