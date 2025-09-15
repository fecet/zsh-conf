# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview
This is a personal ZSH configuration repository that manages dotfiles for ZSH shell setup. The repository uses a symlink-based installation approach to manage configuration files.

## Commands

### Installation
```bash
./install.sh  # Creates symlinks from zsh/* to ~/ 
```

## Architecture and Structure

### Core Components
- **install.sh**: Main installation script that creates symlinks from `zsh/` directory files to the home directory
- **zsh/.zshrc**: Main ZSH configuration file that sets up:
  - Powerlevel10k theme with instant prompt
  - History configuration (1M entries, deduplication)
  - Vi-mode keybindings
  - Dracula terminal colors for TTY
  - Zinit plugin manager
  - Various shell plugins and completions
  
- **zsh/.zshenv**: Environment variable configuration for:
  - PATH extensions for various tools (cargo, go, pnpm, pixi, etc.)
  - Editor configuration (nvim/nvr)
  - FZF default options
  
- **zsh/.aliases.sh**: Shell aliases and functions including:
  - Command shortcuts (j=just, v=nvim, lg=lazygit)
  - Utility functions (killx, yy for file management)
  - Git, Docker, and Kubernetes aliases

### Installation Behavior
The install script uses symlinks instead of copying files, with safety flags:
- Removes existing destination files before creating symlinks
- Uses `set -e` for error handling
- Processes all files in the `zsh/` directory