# dotfiles

Public, portable configuration files.

## Included

- [Ghostty](https://ghostty.org/) configuration
- Optional Ghostty macropad key mappings
- Optional per-project Ghostty themes for Zsh
- [Neovim](https://neovim.io/) configuration managed with lazy.nvim
- [Herdr](https://herdr.dev/) UI and theme configuration
- Herdr app keys, settings and personal mods (a command palette that starts agents)
- Portable Zsh configuration and a compact Powerlevel10k prompt

## Install

```sh
./apply
```

The script creates symlinks in `~/.config`. Existing files are never overwritten: conflicting paths are backed up under `~/.dotfiles-backup/<timestamp>/` first.

To preview changes without modifying your system:

```sh
./apply --dry-run
```

### Zsh

The shell configuration works without optional tools. For the complete experience on macOS:

```sh
brew install powerlevel10k zsh-autosuggestions zsh-syntax-highlighting eza
```

Powerlevel10k is the only prompt dependency. Its compact configuration preserves the rainbow-style directory, Git status, execution-time, runtime-version, and clock segments. A Nerd Font is required for prompt icons; the Ghostty configuration already selects `MesloLGS Nerd Font Mono`.

Put credentials, employer-specific aliases, and machine-only paths in `~/.zshrc.local`. The public `.zshrc` loads that file when present, while Git ignores it.

### Herdr app

Only personal files from Herdr's folder (`~/.config/herdr-app`, or `$HERDR_APP_HOME`) live in `herdr-app/`: the keymap, `settings.json`, and anything under `mods/`, `layouts/` and `themes/`. Everything else there is written by Herdr itself (shipped mods and layouts, type files, state) and stays out of the repo. Each personal file or mod folder is linked individually, so new mods, layouts and themes added here are picked up on the next run. Herdr writes through the symlinks (for example, zoom changes land in `herdr-app/settings.json`).

Herdr's default keys differ per platform (macOS uses cmd where Linux uses ctrl), so the keymap is per platform: `herdr-app/keys/<linux|macos|windows>.json`. On a platform without one yet, start Herdr once, then apply: it adopts the keymap Herdr wrote there, rebinds its palette key to `my-palette`, and links it. Commit the new file. Key changes made later on one platform don't carry over to the others; copy them across by hand.

- Linux and macOS: `./apply` (everything) or `./apply --herdr-app-only`.
- Windows: `powershell -ExecutionPolicy Bypass -File .\apply.ps1` (Herdr app files only; needs Developer Mode or an elevated shell for symbolic links).

`mods/my-palette` is a copy of Herdr's command palette with a "New agent: <name>" entry for each installed agent; each platform's keymap binds the palette key (`ctrl-shift-p` on Linux) to it.

### Neovim

The first Neovim launch bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim), which then installs the plugins pinned in `nvim/lazy-lock.json`. External formatters, linters, and language servers are installed through Mason where configured.

Herdr runtime state, logs, downloaded plugins, and generated plugin metadata are intentionally excluded. Install optional plugins separately with `herdr plugin install`.

The Ghostty project-theme helper is installed but not automatically sourced. To enable it, add this to your Zsh configuration:

```zsh
source ~/.config/ghostty/project-themes.zsh
```

Place a `.ghostty-theme` file in a project directory (or one of its parents), using a preset from `~/.config/ghostty/theme-presets` as a starting point.

## Privacy

This repository is intended to remain public. Do not commit secrets, credentials, machine-specific identifiers, private hostnames, personal email addresses, or absolute home-directory paths. Put local-only data in files matching `*.local`, `*.private`, or `*.secret`; these are ignored by Git.

Pushes to `main` and pull requests run Gitleaks against Git history plus repository-specific PII checks. Run the latter locally with:

```sh
./scripts/check-public-safety.sh
```
