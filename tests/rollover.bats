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
  # rollover's date argument names the SOURCE day being rolled from, not the
  # target -- pass 07-19 to roll 07-19 -> 07-20.
  run_script rollover 2026-07-19
  [ "$status" -eq 0 ]
  [[ "$output" == *"ROLLED OVER"* ]]

  # Old tasks marked as carried
  grep -q '\[>\]' "2026/07-july/2026-07-19.md"
  # New tasks in today's entry
  grep -q "unchecked task one" "2026/07-july/2026-07-20.md"
}

@test "rollover falls back safely when target has no Top 3 Priorities header (bug b regression)" {
  mkentry 2026-07-19 "# 2026-07-19 -- Saturday

### Top 3 Priorities
1. [ ] unchecked task one
2. [ ] unchecked task two
"
  # Target file deliberately lacks '### Top 3 Priorities' so rollover must
  # take the no-header fallback insertion path. Before the fix, this branch
  # used unquoted, word-splitting sed and would corrupt the file.
  mkentry 2026-07-20 "# 2026-07-20 -- Sunday

Some other content here.
"
  run_script rollover 2026-07-19
  [ "$status" -eq 0 ]
  [[ "$output" == *"ROLLED OVER"* ]]

  local target="2026/07-july/2026-07-20.md"
  # Task text must survive intact, on its own line, not word-split or mangled
  grep -qx -- '- \[ \] unchecked task one' "$target"
  grep -qx -- '- \[ \] unchecked task two' "$target"
  # Original content must still be present and the file must not have picked
  # up stray literal backslashes from a broken sed invocation
  grep -q "Some other content here." "$target"
  ! grep -q '\\\\' "$target"
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
  run_script rollover 2026-07-19
  [ "$status" -eq 0 ]
  [[ "$output" == *"You're all caught up"* ]]
}
