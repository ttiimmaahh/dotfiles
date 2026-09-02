# dotfiles

Public, portable configuration files.

## Included

- [Ghostty](https://ghostty.org/) configuration
- Optional Ghostty macropad key mappings
- Optional per-project Ghostty themes for Zsh
- [Neovim](https://neovim.io/) configuration managed with lazy.nvim
- [Herdr](https://herdr.dev/) UI and theme configuration

## Install

```sh
./apply
```

The script creates symlinks in `~/.config`. Existing files are never overwritten: conflicting paths are backed up under `~/.dotfiles-backup/<timestamp>/` first.

To preview changes without modifying your system:

```sh
./apply --dry-run
```

The first Neovim launch bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim), which then installs the plugins pinned in `nvim/lazy-lock.json`. External formatters, linters, and language servers are installed through Mason where configured.

Herdr runtime state, logs, downloaded plugins, and generated plugin metadata are intentionally excluded. Install optional plugins separately with `herdr plugin install`.

The Ghostty project-theme helper is installed but not automatically sourced. To enable it, add this to your Zsh configuration:

```zsh
source ~/.config/ghostty/project-themes.zsh
```

Place a `.ghostty-theme` file in a project directory (or one of its parents), using a preset from `~/.config/ghostty/theme-presets` as a starting point.

## Privacy

This repository is intended to remain public. Do not commit secrets, credentials, machine-specific identifiers, private hostnames, personal email addresses, or absolute home-directory paths. Put local-only data in files matching `*.local`, `*.private`, or `*.secret`; these are ignored by Git.
