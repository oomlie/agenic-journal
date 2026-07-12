#!/usr/bin/env bats

load test_helper

@test "streak shows stats for consecutive days" {
  # Create 3 consecutive entries
  mkentry 2026-07-10 "# 2026-07-10 -- Friday"
  mkentry 2026-07-11 "# 2026-07-11 -- Saturday"
  mkentry 2026-07-12 "# 2026-07-12 -- Sunday"

  run_script streak
  [ "$status" -eq 0 ]
  [[ "$output" == *"STREAK"* ]]
}
