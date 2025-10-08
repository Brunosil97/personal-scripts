#!/bin/bash

# Git Commit Date Updater
# Updates git commit timestamps and spreads them across specified dates
# Usage: ./update-commit-dates.sh <start-date> <num-commits|end-date> [num-commits]

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}9${NC} $1"
}

print_success() {
    echo -e "${GREEN}${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}�${NC} $1"
}

print_error() {
    echo -e "${RED}${NC} $1"
}

# Function to display usage
usage() {
    cat << EOF
Usage: $0 <start-date> <num-commits|end-date> [num-commits]

Date Format: DD-MM-YYYY (UK format)

Examples:
  # Update last 3 commits to October 4, 2025
  $0 04-10-2025 3

  # Spread 5 commits evenly across October 4-8, 2025
  $0 04-10-2025 08-10-2025 5

  # Update last commit to October 4, 2025 (default)
  $0 04-10-2025

EOF
    exit 1
}

# Check if in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not a git repository!"
    exit 1
fi

# Check parameters
if [ $# -lt 1 ]; then
    print_error "Missing required parameter: start-date"
    usage
fi

START_DATE=$1
NUM_COMMITS=1
END_DATE=""

# Parse date from DD-MM-YYYY to YYYY-MM-DD
parse_date() {
    local input=$1
    if [[ $input =~ ^([0-9]{2})-([0-9]{2})-([0-9]{4})$ ]]; then
        echo "${BASH_REMATCH[3]}-${BASH_REMATCH[2]}-${BASH_REMATCH[1]}"
    else
        print_error "Invalid date format: $input (expected DD-MM-YYYY)"
        exit 1
    fi
}

# Check if parameter is a date (DD-MM-YYYY format)
is_date() {
    [[ $1 =~ ^[0-9]{2}-[0-9]{2}-[0-9]{4}$ ]]
}

# Parse parameters
START_DATE_ISO=$(parse_date "$START_DATE")

if [ $# -ge 2 ]; then
    if is_date "$2"; then
        # Second parameter is end date
        END_DATE=$2
        END_DATE_ISO=$(parse_date "$END_DATE")

        if [ $# -ge 3 ]; then
            NUM_COMMITS=$3
        fi
    else
        # Second parameter is number of commits
        NUM_COMMITS=$2
    fi
fi

# Validate number of commits
if ! [[ $NUM_COMMITS =~ ^[0-9]+$ ]] || [ $NUM_COMMITS -lt 1 ]; then
    print_error "Number of commits must be a positive integer"
    exit 1
fi

# Get the commits to update
COMMITS=$(git log --format="%H" -n $NUM_COMMITS)
if [ -z "$COMMITS" ]; then
    print_error "Not enough commits in repository"
    exit 1
fi

ACTUAL_COUNT=$(echo "$COMMITS" | wc -l)
if [ $ACTUAL_COUNT -lt $NUM_COMMITS ]; then
    print_warning "Only $ACTUAL_COUNT commits available (requested $NUM_COMMITS)"
    NUM_COMMITS=$ACTUAL_COUNT
fi

# Calculate date range
if [ -n "$END_DATE" ]; then
    # Calculate days between dates
    START_EPOCH=$(date -d "$START_DATE_ISO" +%s)
    END_EPOCH=$(date -d "$END_DATE_ISO" +%s)

    if [ $END_EPOCH -lt $START_EPOCH ]; then
        print_error "End date must be after start date"
        exit 1
    fi

    DAYS_DIFF=$(( (END_EPOCH - START_EPOCH) / 86400 ))
else
    # Single date
    END_DATE_ISO=$START_DATE_ISO
    DAYS_DIFF=0
fi

# Generate random time between 9 AM and 5:59 PM
random_time() {
    local hour=$(( RANDOM % 9 + 9 ))  # 9-17
    local minute=$(( RANDOM % 60 ))
    local second=$(( RANDOM % 60 ))
    printf "%02d:%02d:%02d" $hour $minute $second
}

# Generate array of dates and times
declare -a NEW_DATES
declare -a NEW_TIMES

if [ $NUM_COMMITS -eq 1 ]; then
    NEW_DATES[0]=$START_DATE_ISO
    NEW_TIMES[0]=$(random_time)
else
    if [ $DAYS_DIFF -eq 0 ]; then
        # All commits on the same day
        for i in $(seq 0 $(($NUM_COMMITS - 1))); do
            NEW_DATES[$i]=$START_DATE_ISO
            NEW_TIMES[$i]=$(random_time)
        done
    else
        # At least 1 commit per day distribution
        # If more commits than days, cycle back to start
        # If fewer commits than days, use sequential days
        TOTAL_DAYS=$(( DAYS_DIFF + 1 ))

        for i in $(seq 0 $(($NUM_COMMITS - 1))); do
            # Cycle through days: if we have more commits than days, wrap around
            DAY_INDEX=$(( i % TOTAL_DAYS ))
            COMMIT_EPOCH=$(( START_EPOCH + DAY_INDEX * 86400 ))
            NEW_DATES[$i]=$(date -d "@$COMMIT_EPOCH" +%Y-%m-%d)
            NEW_TIMES[$i]=$(random_time)
        done
    fi
fi

# Display preview
echo ""
print_info "Preview of changes:"
echo ""
printf "%-10s %-60s %s\n" "Date" "Commit" "Message"
printf "%s\n" "$(printf '%.0s-' {1..100})"

i=0
while IFS= read -r commit_hash; do
    commit_msg=$(git log --format=%s -n 1 $commit_hash)
    commit_short=$(echo $commit_hash | cut -c1-7)
    new_date="${NEW_DATES[$i]} ${NEW_TIMES[$i]}"
    printf "%-10s %-60s %s\n" "${NEW_DATES[$i]}" "$commit_short" "${commit_msg:0:45}"
    i=$((i+1))
done <<< "$COMMITS"

echo ""

if [ -n "$END_DATE" ]; then
    print_info "Will update $NUM_COMMITS commits from $START_DATE to $END_DATE"
else
    print_info "Will update $NUM_COMMITS commit(s) to $START_DATE"
fi

print_warning "This will rewrite git history!"
echo ""

# Ask for confirmation
read -p "Do you want to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Aborted by user"
    exit 0
fi

# Create backup branch
BACKUP_BRANCH="backup-$(date +%Y%m%d-%H%M%S)"
git branch $BACKUP_BRANCH
print_success "Created backup branch: $BACKUP_BRANCH"

# Build the filter-branch command
FILTER_SCRIPT=""
i=0
while IFS= read -r commit_hash; do
    new_datetime="${NEW_DATES[$i]} ${NEW_TIMES[$i]}"

    if [ $i -eq 0 ]; then
        FILTER_SCRIPT="if [ \"\$GIT_COMMIT\" = \"$commit_hash\" ]; then"
    else
        FILTER_SCRIPT="$FILTER_SCRIPT
    elif [ \"\$GIT_COMMIT\" = \"$commit_hash\" ]; then"
    fi

    FILTER_SCRIPT="$FILTER_SCRIPT
        export GIT_AUTHOR_DATE=\"$new_datetime\"
        export GIT_COMMITTER_DATE=\"$new_datetime\""

    i=$((i+1))
done <<< "$COMMITS"

FILTER_SCRIPT="$FILTER_SCRIPT
    fi"

# Get the oldest commit's parent
OLDEST_COMMIT=$(echo "$COMMITS" | tail -n 1)
OLDEST_PARENT=$(git log --format=%H -n 1 $OLDEST_COMMIT^)

# Execute filter-branch
print_info "Updating commit dates..."

FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --env-filter "$FILTER_SCRIPT" $OLDEST_PARENT..HEAD

print_success "Commit dates updated successfully!"
echo ""
print_info "Next steps:"
echo "  " To push changes: git push --force"
echo "  " To undo changes: git reset --hard $BACKUP_BRANCH"
echo ""
print_success "Done!"
