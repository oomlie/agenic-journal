#!/usr/bin/env bats

load test_helper

@test "week-review aggregates real log lines into Daily Logs section (bug a regression)" {
  local today
  today="$(date +%Y-%m-%d)"
  mkentry "$today" "# $today -- Monday

## Log
"
  # Use the real producer (scripts/log) rather than hand-crafting the line,
  # so this test fails if log's format and week-review's extraction regex
  # ever drift apart again (the original bug: ASCII '--' vs Unicode '--').
  run_script log "checked the api docs"
  [ "$status" -eq 0 ]

  run_script week-review
  [ "$status" -eq 0 ]

  local review_file
  review_file="$(find reviews -name '*.md' | head -n1)"
  [ -n "$review_file" ]

  run cat "$review_file"
  [[ "$output" == *"## Daily Logs"* ]]
  [[ "$output" == *"checked the api docs"* ]]
}
