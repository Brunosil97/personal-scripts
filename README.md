# Personal Scripts

A collection of utility scripts for development workflows.

## Git Commit Date Updater

### Overview

A Bash script to update git commit timestamps and spread them across specified dates. Useful for retroactively adjusting commit dates to appear on GitHub's contribution graph.

### Usage

```bash
./update-commit-dates.sh <start-date> <num-commits|end-date> [num-commits]
```

**Date Format:** DD-MM-YYYY (UK format)

### Examples

**Single Date:**

```bash
# Update last 3 commits to October 4, 2025
./update-commit-dates.sh 04-10-2025 3
```

**Date Range:**

```bash
# Spread 5 commits evenly across October 4-8, 2025
./update-commit-dates.sh 04-10-2025 08-10-2025 5
```

**Default (1 commit):**

```bash
# Update last commit to October 4, 2025
./update-commit-dates.sh 04-10-2025
```

### Features

- **UK Date Format** - DD-MM-YYYY
- **Smart Parameter Detection** - Automatically detects if second parameter is a date or number
- **Even Distribution** - Spreads commits evenly across date range
- **Random Times** - Assigns random work hours (9 AM - 5 PM)
- **Preview Mode** - Shows changes before applying
- **Automatic Backup** - Creates backup branch before changes
- **Safe Execution** - Requires confirmation before proceeding

### How It Works

1. **Preview:** Shows which commits will be updated and their new dates
2. **Confirmation:** Asks for user confirmation (y/N)
3. **Backup:** Creates a timestamped backup branch
4. **Update:** Uses `git filter-branch` to update both author and committer dates
5. **Complete:** Provides instructions for force push and undo

### Important Notes

⚠️ **This rewrites git history!**

- If commits were already pushed, you'll need to force push:

  ```bash
  git push --force
  ```

- To undo changes:

  ```bash
  git reset --hard backup-<timestamp>
  ```

- The backup branch name is shown after creation

### Parameters

| Parameter                   | Description                                | Required        | Example             |
| --------------------------- | ------------------------------------------ | --------------- | ------------------- |
| `start-date`                | Starting date in DD-MM-YYYY format         | Yes             | `04-10-2025`        |
| `num-commits` or `end-date` | Number of commits OR end date              | No (default: 1) | `3` or `08-10-2025` |
| `num-commits`               | Number of commits (when end-date provided) | No (default: 1) | `5`                 |

### Technical Details

- **Time Range:** Random times between 09:00:00 and 17:59:59
- **Distribution:** Commits spread evenly across the date range
- **Both Dates Updated:** Sets both `GIT_AUTHOR_DATE` and `GIT_COMMITTER_DATE`
- **Validation:** Checks for valid git repository and date formats

### Requirements

- Git
- Bash (Git Bash on Windows)
- `date` command (supports `-d` flag)

### Use Cases

- Backdating commits for GitHub contribution graph
- Spreading project work across realistic timeframes
- Adjusting commit dates after offline development
- Creating consistent commit history timelines

---

## Installation

1. Make script executable:

   ```bash
   chmod +x update-commit-dates.sh
   ```

2. Run from anywhere by adding to PATH or use relative path

---

## License

Personal use only. Use responsibly and ethically.
