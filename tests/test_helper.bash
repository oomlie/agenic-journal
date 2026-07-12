#!/usr/bin/env bash
# Test helper for agenic-journal bats test suite

# Directory where the real repo scripts live
SCRIPT_SOURCE=""

setup() {
  # Create isolated temp repo for each test
  TEST_DIR="$(mktemp -d)"
  cd "$TEST_DIR" || exit 1

  git init -q
  git config user.email "test@example.com"
  git config user.name "Test User"

  # Create directory structure
  mkdir -p scripts/lib templates .githooks

  # Resolve script source relative to test_helper.bash location
  SCRIPT_SOURCE="${BATS_TEST_DIRNAME}/../scripts"

  # Copy the real scripts into the test repo
  cp "$SCRIPT_SOURCE/lib/common.sh" scripts/lib/common.sh
  for script in "$SCRIPT_SOURCE"/new-day "$SCRIPT_SOURCE"/log "$SCRIPT_SOURCE"/rollover \
                "$SCRIPT_SOURCE"/week-review "$SCRIPT_SOURCE"/remember \
                "$SCRIPT_SOURCE"/habits "$SCRIPT_SOURCE"/streak "$SCRIPT_SOURCE"/setup-hooks; do
    [ -f "$script" ] && cp "$script" scripts/ 2>/dev/null || true
  done

  # Copy template
  cp "$SCRIPT_SOURCE/../templates/daily.md" templates/daily.md 2>/dev/null || true

  # Make scripts executable
  chmod +x scripts/* 2>/dev/null || true
}

teardown() {
  rm -rf "$TEST_DIR"
}

# Run a script by name with arguments
run_script() {
  local script_name="$1"
  shift
  run bash "scripts/$script_name" "$@"
}

# Create a journal entry for a specific date with optional content
mkentry() {
  local date_str="$1"
  local content=""
  if [ $# -gt 1 ]; then
    content="${2}"
  fi

  local year="${date_str:0:4}"
  local month_num="${date_str:5:2}"

  # Get month name from common.sh
  local month_name
  month_name="$(bash -c "source scripts/lib/common.sh; journal_month_name $month_num")"

  local dir="$year/$month_num-$month_name"
  mkdir -p "$dir"

  if [ -n "$content" ]; then
    printf '%s\n' "$content" > "$dir/$date_str.md"
  else
    # Generate from template
    local day_name
    day_name="$(bash -c "source scripts/lib/common.sh; journal_day_name $date_str")"
    sed "s/YYYY-MM-DD/$date_str/g; s/Day Name/$day_name/g" templates/daily.md > "$dir/$date_str.md"
  fi

  git add -A && git commit -q -m "$date_str -- journal entry" 2>/dev/null || true
}
