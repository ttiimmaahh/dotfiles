# dotfiles

Public, portable configuration files.

## Included

- [Ghostty](https://ghostty.org/) configuration
- Optional Ghostty macropad key mappings
- Optional per-project Ghostty themes for Zsh
- [Neovim](https://neovim.io/) configuration managed with lazy.nvim
- [Herdr](https://herdr.dev/) UI and theme configuration
- Herdr app keys, settings and personal mods (a command palette that starts agents)
- `customize-herdr`, an agent skill that customizes the Herdr app from a plain request
- Portable Zsh configuration and a compact Powerlevel10k prompt

## Install

```sh
./apply
```

The script creates symlinks in `~/.config`. For the Herdr app, see [Herdr app](#herdr-app). Existing files are never overwritten: conflicting paths are backed up under `~/.dotfiles-backup/<timestamp>/` first.

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

### Neovim

The first Neovim launch bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim), which then installs the plugins pinned in `nvim/lazy-lock.json`. External formatters, linters, and language servers are installed through Mason where configured.

Herdr runtime state, logs, downloaded plugins, and generated plugin metadata are intentionally excluded. Install optional plugins separately with `herdr plugin install`.

The Ghostty project-theme helper is installed but not automatically sourced. To enable it, add this to your Zsh configuration:

```zsh
source ~/.config/ghostty/project-themes.zsh
```

Place a `.ghostty-theme` file in a project directory (or one of its parents), using a preset from `~/.config/ghostty/theme-presets` as a starting point.

## Herdr app

Personal customizations for the [Herdr](https://herdr.dev/) desktop app live in `herdr-app/`:

- `mods/my-palette`: Herdr's command palette plus a "New agent: <name>" entry for each installed agent (Claude Code, Pi, Codex, ...). Pick one to start it as a new tab in the current space.
- `mods/my-status` and `layouts/my-main.json`: the default layout, with a status bar hint that shows and opens `my-palette`.
- `mods/my-spaces` and `mods/my-agents`: Herdr's spaces and agents sidebar lists with taller, touch-friendly rows.
- `mods/my-tabs`: Herdr's tab bar with larger, touch-friendly tabs and buttons (`my-main` makes its bar 56px tall).
- `keys/<platform>.json`: the keymap, with the palette key (`ctrl-shift-p` on Linux) opening `my-palette`.
- `settings.json`: zoom, sounds and other personal settings.

### Customize it with an agent

`agents/skills/customize-herdr` is an [Agent Skill](https://agentskills.io) that takes a request ("move the agents list to the right", "bind alt-p to the palette", "a sidebar of my PRs") and carries it through: it reads Herdr's own `AGENTS.md`, picks the smallest file to change, cloning shipped layouts and mods when it has to, verifies with `herdr-app status`, `herdr-app check` and a screenshot, then reports. New files go into this repo when Herdr's folder links here. Agents also reach it on their own when asked to change Herdr.

Apply links it into `~/.agents/skills` (Codex, pi and other agents) and `~/.claude/skills` (Claude Code), including with `--herdr-app-only` and on Windows. Invoke it by name, for example `/customize-herdr make the tab bar taller` in Claude Code or `$customize-herdr ...` in Codex.

### Set up a new machine

1. Install Herdr and start it once, so it creates its folder (`~/.config/herdr-app`) and writes its default keymap for this platform.
2. Link the files:
   - Linux and macOS: `./apply --herdr-app-only` (or `./apply` for every dotfile).
   - Windows: `powershell -ExecutionPolicy Bypass -File .\apply.ps1`. It needs Developer Mode (Settings > System > For developers) or an elevated shell to create symbolic links.
3. Switch to the layout once; Herdr remembers the shown layout per machine:

   ```sh
   herdr-app do layout.switch --name my-main
   ```

   Or press `ctrl-shift-l` until the status bar shows the palette key.
4. If this is the first machine of its platform (no `herdr-app/keys/<platform>.json` yet), apply adopted Herdr's keymap into the repo with the palette key pointed at `my-palette`. Commit and push the new file.

Check it worked: the palette key opens the palette with "New agent" entries, and `herdr-app status` lists no errors.

### How it works

Only personal files from Herdr's folder (`~/.config/herdr-app`, or `$HERDR_APP_HOME`) are in the repo. Everything else there is written by Herdr itself (shipped mods and layouts, type files, state). Apply links each personal file or mod folder individually, so new mods, layouts and themes added under `herdr-app/` are picked up on the next run. Herdr writes through the symlinks: zoom changes, for example, land in `herdr-app/settings.json`. It doesn't notice edits made to the files in the repo, though: after editing one, run `touch -h` on its link in Herdr's folder to make Herdr reload it.

Herdr's default keys differ per platform (macOS uses cmd where Linux uses ctrl), so each platform has its own keymap. Key changes made on one platform don't carry over to the others; copy them across by hand.

`my-main` and `my-status` are clones of Herdr's `main` layout and `workspace-status` mod, so they don't receive Herdr's updates to those. `herdr-app do layout.switch --name main` goes back to Herdr's layout.

## Privacy

This repository is intended to remain public. Do not commit secrets, credentials, machine-specific identifiers, private hostnames, personal email addresses, or absolute home-directory paths. Put local-only data in files matching `*.local`, `*.private`, or `*.secret`; these are ignored by Git.

Pushes to `main` and pull requests run Gitleaks against Git history plus repository-specific PII checks. Run the latter locally with:

```sh
./scripts/check-public-safety.sh
```
