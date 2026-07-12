#!/usr/bin/env bash
#
# common.sh -- Shared library for agenic-journal scripts.
# Sourced (not executed) by individual command scripts.
#

set -euo pipefail

# ---------------------------------------------------------------------------
# Single source of truth: the log-line timestamp format.
# Both the producer (log) and the consumer (week-review) must use this.
# ---------------------------------------------------------------------------
readonly JOURNAL_LOG_LINE_REGEX='^- [0-9]{2}:[0-9]{2} --'

# ---------------------------------------------------------------------------
# Repo root
# ---------------------------------------------------------------------------

journal_require_repo_root() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null) || true
    if [ -z "${root:-}" ]; then
        echo "Error: Not inside a Git repository." >&2
        return 1
    fi
    printf '%s\n' "$root"
}

# ---------------------------------------------------------------------------
# Date validation
# ---------------------------------------------------------------------------

journal_validate_date() {
    local d="$1"
    if ! [[ "$d" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "Error: Date must be YYYY-MM-DD format." >&2
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Date helpers with unified BSD/GNU fallbacks
# ---------------------------------------------------------------------------

journal_month_name() {
    local num="${1#0}"
    case "$num" in
        1)  echo "January"   ;; 2)  echo "February"  ;; 3)  echo "March"     ;;
        4)  echo "April"     ;; 5)  echo "May"       ;; 6)  echo "June"      ;;
        7)  echo "July"      ;; 8)  echo "August"    ;; 9)  echo "September" ;;
        10) echo "October"   ;; 11) echo "November"  ;; 12) echo "December"  ;;
    esac
}

journal_month_name_from_date() {
    local d="$1"
    local m
    m=$(date -d "$d" '+%B' 2>/dev/null) || \
    m=$(date -j -f '%Y-%m-%d' "$d" '+%B' 2>/dev/null) || \
    m=$(journal_month_name "$(echo "$d" | cut -d'-' -f2)")
    printf '%s\n' "$m"
}

journal_day_name() {
    local d="$1"
    local dn
    dn=$(date -d "$d" '+%A' 2>/dev/null) || \
    dn=$(date -j -f '%Y-%m-%d' "$d" '+%A' 2>/dev/null) || \
    dn=$(python3 -c "import datetime; print(datetime.datetime.strptime('$d', '%Y-%m-%d').strftime('%A'))" 2>/dev/null) || \
    dn="Day"
    printf '%s\n' "$dn"
}

journal_add_days() {
    local d="$1" n="$2"
    local result
    result=$(date -d "$d $n days" '+%Y-%m-%d' 2>/dev/null) || \
    result=$(date -v "${n}d" -j -f '%Y-%m-%d' "$d" '+%Y-%m-%d' 2>/dev/null) || \
    result=$(python3 -c "import datetime, sys; print((datetime.datetime.strptime('$d', '%Y-%m-%d') + datetime.timedelta(days=$n)).strftime('%Y-%m-%d'))" 2>/dev/null)
    if [ -z "${result:-}" ]; then
        echo "Error: Cannot add $n days to $d" >&2
        return 1
    fi
    printf '%s\n' "$result"
}

journal_days_in_month() {
    local year="$1" month="$2"
    local result
    result=$(date -d "$year-$month-01 + 1 month - 1 day" '+%d' 2>/dev/null) || \
    result=$(date -v+1m -v-1d -j -f '%Y-%m-%d' "$year-$month-01" '+%d' 2>/dev/null) || \
    result=$(python3 -c "import calendar, sys; print(calendar.monthrange($year, int('$month'))[1])" 2>/dev/null)
    if [ -z "${result:-}" ]; then
        case "$month" in
            01|03|05|07|08|10|12) result=31 ;;
            04|06|09|11) result=30 ;;
            02)
                if [ "$((year % 4))" -eq 0 ] && { [ "$((year % 100))" -ne 0 ] || [ "$((year % 400))" -eq 0 ]; }; then
                    result=29
                else
                    result=28
                fi
                ;;
        esac
    fi
    printf '%s\n' "$result"
}

journal_epoch() {
    local d="$1"
    local result
    result=$(date -d "$d" '+%s' 2>/dev/null) || \
    result=$(date -j -f '%Y-%m-%d' "$d" '+%s' 2>/dev/null) || \
    result=$(python3 -c "import datetime, time; print(int(time.mktime(datetime.datetime.strptime('$d', '%Y-%m-%d').timetuple())))" 2>/dev/null)
    if [ -z "${result:-}" ]; then
        echo "Error: Cannot compute epoch for $d" >&2
        return 1
    fi
    printf '%s\n' "$result"
}

journal_day_of_week() {
    local d="$1"
    local result
    result=$(date -d "$d" '+%u' 2>/dev/null) || \
    result=$(date -j -f '%Y-%m-%d' "$d" '+%u' 2>/dev/null) || \
    result=$(python3 -c "import datetime; print(datetime.datetime.strptime('$d', '%Y-%m-%d').isoweekday())" 2>/dev/null)
    if [ -z "${result:-}" ]; then
        echo "Error: Cannot get day of week for $d" >&2
        return 1
    fi
    printf '%s\n' "$result"
}

journal_iso_week() {
    local d="$1"
    local result
    result=$(date -d "$d" '+%V' 2>/dev/null) || \
    result=$(date -j -f '%Y-%m-%d' "$d" '+%V' 2>/dev/null) || \
    result=$(python3 -c "import datetime; print(datetime.datetime.strptime('$d', '%Y-%m-%d').isocalendar()[1])" 2>/dev/null)
    if [ -z "${result:-}" ]; then
        echo "Error: Cannot get ISO week for $d" >&2
        return 1
    fi
    printf '%s\n' "$result"
}

# ---------------------------------------------------------------------------
# Path resolution
# ---------------------------------------------------------------------------

journal_entry_path() {
    local repo_root="$1" d="$2"
    local y m month_name
    y=$(echo "$d" | cut -d'-' -f1)
    m=$(echo "$d" | cut -d'-' -f2)
    month_name=$(journal_month_name_from_date "$d")
    printf '%s\n' "$repo_root/$y/$m-$(echo "$month_name" | tr '[:upper:]' '[:lower:]')/$d.md"
}

journal_month_dir() {
    local repo_root="$1" year="$2" month="$3"
    local month_name
    month_name=$(journal_month_name "$month")
    printf '%s\n' "$repo_root/$year/$month-$(echo "$month_name" | tr '[:upper:]' '[:lower:]')"
}

# ---------------------------------------------------------------------------
# Safe multi-line file insertion (replaces all dual-sed patterns)
# ---------------------------------------------------------------------------

journal_insert_after_line() {
    local file="$1" line_no="$2" text_block="$3"
    awk -v n="$line_no" -v txt="$text_block" '
        NR == n { print; print txt; next }
        { print }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

# ---------------------------------------------------------------------------
# Date parsing from entry filename
# ---------------------------------------------------------------------------

journal_date_from_filename() {
    local f="$1"
    basename "$f" .md | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}'
}
