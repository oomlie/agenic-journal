#!/usr/bin/env bats

load test_helper

@test "rollover carries unchecked tasks forward" {
  mkentry 2026-07-19 "# 2026-07-19 -- Saturday

### Top 3 Priorities
1. [ ] unchecked task one
2. [x] done task
3. [ ] unchecked task two
"
  mkentry 2026-07-20 "# 2026-07-20 -- Sunday

### Top 3 Priorities
1. [ ] today's task
"
  run_script rollover 2026-07-20
  [ "$status" -eq 0 ]
  [[ "$output" == *"ROLLED OVER"* ]]

  # Old tasks marked as carried
  grep -q '\[>\]' "2026/07-july/2026-07-19.md"
  # New tasks in today's entry
  grep -q "unchecked task one" "2026/07-july/2026-07-20.md"
}

@test "rollover with no unchecked tasks reports nothing to roll" {
  mkentry 2026-07-19 "# 2026-07-19 -- Saturday

### Top 3 Priorities
1. [x] all done
"
  mkentry 2026-07-20 "# 2026-07-20 -- Sunday

### Top 3 Priorities
1. [ ] today's task
"
  run_script rollover 2026-07-20
  [ "$status" -eq 0 ]
  [[ "$output" == *"0"* ]] || [[ "$output" == *"nothing"* ]]
}
