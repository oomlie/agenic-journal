#!/usr/bin/env bats

load test_helper

@test "log appends timestamped note to today's entry" {
  local today
  today="$(date +%Y-%m-%d)"
  mkentry "$today" "# $today -- Monday

## Log
"
  run_script log "test note"
  [ "$status" -eq 0 ]
  [[ "$output" == *"LOGGED"* ]]
}

@test "log appends to specific date" {
  mkentry 2026-07-20 "# 2026-07-20 -- Monday

## Log
"
  run_script log "old note" -d 2026-07-20
  [ "$status" -eq 0 ]
  grep -q "old note" "2026/07-july/2026-07-20.md"
}

@test "log adds tag" {
  local today
  today="$(date +%Y-%m-%d)"
  mkentry "$today" "# $today -- Monday

## Log
"
  run_script log "tagged note" -t win
  [ "$status" -eq 0 ]
  # The entry file should contain the log line
  local file
  file="$today"
  grep -q "tagged note" 20*/*-*/"$file".md 2>/dev/null
}

@test "log fails when entry does not exist" {
  run_script log "orphan note"
  [ "$status" -ne 0 ]
}
