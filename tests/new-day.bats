#!/usr/bin/env bats

load test_helper

@test "new-day creates entry for today by default" {
  run_script new-day
  [ "$status" -eq 0 ]
  [[ "$output" == *"NEW DAY CREATED"* ]]
}

@test "new-day creates entry for specific date" {
  run_script new-day 2026-07-20
  [ "$status" -eq 0 ]
  [ -f "2026/07-july/2026-07-20.md" ]
}

@test "new-day refuses invalid date format" {
  run_script new-day not-a-date
  [ "$status" -ne 0 ]
}

@test "new-day refuses to overwrite existing entry" {
  mkentry 2026-07-20 "existing entry"
  run_script new-day 2026-07-20
  [ "$status" -eq 0 ]
  [[ "$output" == *"already exists"* ]]
  # Original content must be untouched
  grep -qx "existing entry" "2026/07-july/2026-07-20.md"
}
