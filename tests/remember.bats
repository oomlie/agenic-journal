#!/usr/bin/env bats

load test_helper

@test "remember shows memory from past" {
  local target
  target="$(date -d '-45 days' +%Y-%m-%d 2>/dev/null || date -v-45d +%Y-%m-%d)"
  mkentry "$target" "# $target -- Thursday

Old memory from the past
"
  # min=max forces a deterministic target date instead of relying on
  # $RANDOM (unseeded) to happen to land on the single fixture day.
  run_script remember 45 45
  [ "$status" -eq 0 ]
  [[ "$output" == *"MEMORY"* ]]
  [[ "$output" == *"Old memory from the past"* ]]
}
