# Personal Scripts

A collection of utility scripts for development workflows and automation tasks.

## Overview

This repository contains various scripts organized by category to help streamline common development tasks, git operations, and workflow automation.

## Scripts

### Git Scripts

Utilities for git repository management and history manipulation.

- **[update-commit-dates.sh](./git-scripts/README.md)** - Update git commit timestamps and distribute them across date ranges
  - Useful for backdating commits and managing GitHub contribution graphs
  - Supports single dates or date ranges with flexible distribution
  - See [git-scripts/README.md](./git-scripts/README.md) for detailed documentation

## Repository Structure

```
personal-scripts/
├── git-scripts/          # Git-related utilities
│   ├── update-commit-dates.sh
│   └── README.md
└── README.md            # This file
```

## Requirements

- Git
- Bash (Git Bash on Windows, native on macOS/Linux)

## Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd personal-scripts
   ```

2. Make scripts executable:
   ```bash
   chmod +x git-scripts/*.sh
   ```

3. (Optional) Add to PATH for global access:
   ```bash
   export PATH="$PATH:/path/to/personal-scripts/git-scripts"
   ```

## Usage

Navigate to the specific script directory and refer to its README for detailed usage instructions.

## Contributing

These are personal utility scripts. Feel free to fork and adapt for your own use.

## License

Personal use only. Use responsibly and ethically.
