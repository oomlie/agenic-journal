#!/usr/bin/env bats

load test_helper

@test "remember shows memory from past" {
  mkentry 2026-05-01 "# 2026-05-01 -- Thursday

Old memory from the past
"
  # Use wide range to ensure the entry is caught
  run_script remember 30 120
  [ "$status" -eq 0 ]
  [[ "$output" == *"MEMORY"* ]]
}
