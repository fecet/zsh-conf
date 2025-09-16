# Repository Guidelines

## Project Structure & Module Organization
This repo manages ZSH dotfiles through symlinks. Key items:
- `install.sh` links everything in `zsh/` into the home directory.
- `zsh/` holds user-facing configs (`.zshrc`, `.zshenv`, `.aliases.sh`, `.p10k.zsh`).
- `scripts/` contains helper utilities such as `pixi-global.py` for Pixi manifest generation.
- `pixi.toml` declares the reproducible toolchain used to run Python helpers and CLI utilities.
Keep personal secrets or host-specific overrides outside the tracked tree.

## Build, Test, and Development Commands
- `./install.sh` — recreate symlinks; run after editing any file in `zsh/`.
- `pixi shell` — spawn the managed environment with all declared CLI tools.
- `pixi run python scripts/pixi-global.py shell` — rebuild the default Pixi manifest; swap `shell` for `devops` or `all` as needed.
- `bash -n install.sh` — quick syntax check before committing shell changes.
Always verify new aliases or functions in a fresh shell session (`exec -l $SHELL`).

## Coding Style & Naming Conventions
Shell scripts target Bash with `set -e`; prefer lowercase, hyphenated filenames and snake_case function names. Indent with two spaces inside loops and conditionals, mirroring `install.sh`. Python utilities follow PEP 8: four-space indentation, type hints, and dataclasses where state is grouped. Keep comments concise and in English.

## Testing Guidelines
No formal test harness exists. Validate shell edits via `bash -n` plus manual execution. For Python, run `pixi run python scripts/pixi-global.py --help` and generate a manifest into a temp path to ensure serialization succeeds. When changing symlink logic, test against a disposable directory using `HOME=$(mktemp -d) ./install.sh`.

## Commit & Pull Request Guidelines
Git history favors focused commits with conventional prefixes such as `feat(scope):`, `docs:`, or `pixi-global:`. Use imperative mood and keep the subject under ~70 characters. For pull requests, include: purpose, affected components (e.g., `zsh/.zshrc`), manual verification notes, and any follow-up tasks. Link issues when available and attach terminal snippets if behavior changed.

## Configuration & Safety Tips
Symlink installs overwrite targets, so confirm backups before running `install.sh` on a new host. Keep `$ZINIT_HOME` and `$PIXI_HOME` configurable via environment vars in `.zshenv`. Document host-specific steps in a separate, ignored file to avoid leaking secrets while keeping onboarding smooth.
