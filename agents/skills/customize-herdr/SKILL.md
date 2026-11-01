---
name: customize-herdr
description: Customize the Herdr desktop app (herdr-app) by editing its config folder, carrying a request from idea to verified on-screen result. Use when the user wants Herdr to look or behave differently: theme, colors, fonts, zoom, sounds, key bindings, layout (move, hide, resize, add panels), pane frames, program icons, or a new or changed mod. For driving panes, tabs or agents at runtime, use the herdr skill instead.
---

# Customize Herdr

The request is the text passed with this skill, else the user's last message.
Carry it through every step below: the change is done only when it is
**green** (step 5) and reported (step 6).

Herdr redraws itself from its files within a second, so each edit is live the
moment it lands, and each edit can be checked the same way.

## 1. Load the manual

`herdr-app --help` prints Herdr's home folder (`$HERDR_APP_HOME` overrides
it; usually `~/.config/herdr-app`). Read the `AGENTS.md` in that folder end
to end. Herdr rewrites it on every start to match the installed version, so it
is the authority on file formats, commands, precedence and mod rules; this
skill only adds the workflow around it. Before writing mod code, also search
`herdr.d.ts` and `gpui-kit.d.ts` in the same folder for every function and
element you use. `gpui-kit.d.ts` is very large, so search it instead of
reading it whole.

If `herdr-app` is missing or the folder has no `AGENTS.md`, tell the user
that Herdr needs to be installed and started once, then stop.

Done when: you have read all of this session's `AGENTS.md`.

## 2. Survey

- `herdr-app status`: the shown layout and any errors. Record the errors as a
  **baseline** so that existing problems aren't counted for or against your change.
- `ls -la` the home folder and its `layouts/`, `mods/` and `themes/` folders.
- `herdr-app commands` when the change involves a command or key.
- Read every file you might edit.
- For a visible change, run `herdr-app shot <temp dir>/before.png`. Step 5
  compares against it.

Sort every file you might touch into one of these groups:

- **Shipped**: Herdr writes and overwrites these. This covers mods listed in
  `installed.json` (by name), layouts listed there as `layout:<name>`, plus
  `AGENTS.md`, `*.d.ts`, `frame/` and `icons/`. Read them and clone them,
  but never edit them.
- **State**: Herdr's bookkeeping, such as `view.json`, `shared.json`, `data/`
  and `layouts/.state/` (AGENTS.md lists them all). Leave them to Herdr.
- **Personal**: everything else, such as `settings.json`, `keys.json`,
  `programs.json`, clones, and the user's own layouts, themes and mods.
- **Linked**: personal files that are symlinks, usually into a dotfiles repo.
  Edit the link's resolved target (`realpath`) so that the link stays a link.
  Herdr notices changes to the link, not to its target, so after each edit,
  run `touch -h <link>` on Linux and macOS, or recreate the link on Windows.
  Create new files beside the existing targets in that repo, following its
  folder layout. Then link them into the home folder the same way the others
  are: if the repo has an install script, read its usage or README and run it.
  Leave committing to the user.

Done when: you can name the shown layout and every file the change will touch,
and each file is personal or linked.

## 3. Plan the smallest change

Choose the lowest rung on this ladder that does what the user asked:

1. `settings.json`: the person's look and behavior (theme, colors, fonts,
   zoom, sounds). It only shows where the shown layout leaves the field unset.
   Check the layout before relying on it.
2. `keys.json`: bindings, in the most specific section that should own them.
3. `programs.json`: program names, icons, tiles and agent launchers.
4. `themes/<name>.json`: a new color scheme.
5. The shown layout: structure, blocks, pane frames, floating blocks. If it is
   shipped, clone it with `layout.clone` and edit the clone. If it is already
   personal, edit it in place.
6. A mod: a new folder for a new panel or behavior. To change a shipped mod,
   clone it with `mod.clone`, then point the personal layout at the clone.

For keys, check what the key does now, and say what a new binding replaces. Pick
free keys. A key that AGENTS.md says programs rely on is used only when the user
names it; then tell them what it takes away from typing.

When two readings of the request would touch different files (which layout,
whether to replace a binding or add one), ask the user one question. Otherwise
choose the plain reading and say so in the report.

Done when: you have a list of every file to create or edit, and all of them are
personal or linked.

## 4. Change

Note each file's prior content, or confirm git already tracks it, so that you
can undo the change. Then make the edits, following AGENTS.md's rules for the
file type. Leave the user's running app and core running: use
`herdr-app do <command>` to act on the window, and never launch bare `herdr-app`.

## 5. Verify until green

The change is **green** when all of these hold:

- No `<name>.error` file (`layout.error`, `keys.error`, `settings.error`,
  `programs.error`) appeared or changed after your edit. Herdr keeps the last
  good version when a file is invalid, so a broken edit looks like "nothing
  happened".
- `herdr-app status` shows no errors beyond the baseline.
- Every mod you created or changed passes `herdr-app check <mod folder>`.
- The change is on screen. Switch to the affected layout if it isn't shown,
  then run `herdr-app shot <temp dir>/after.png`. If you can view images,
  compare it with the before shot and confirm it shows what the user asked
  for. For changes of a few pixels, compare pixel values (for example with
  ImageMagick) rather than judging by eye. If you can't view images, give the
  user both paths.
- For a key, the binding sits in the section that wins for the context the
  user wants (see AGENTS.md's Keys section). You can't press keys, so tell the
  user what to press to try it.

If any of these fail, read the error, fix the cause, and check again until all
of them pass.

## 6. Report

Tell the user:

- What changed, with every file path.
- What the shot shows.
- Any choices you made for them.
- How to undo it: revert the files. `ctrl-alt-shift-escape` brings back the
  default layout and keys if the window ever becomes unusable.
- For linked files, which repo files are new or changed and still need a commit.
- For a new clone, that it no longer receives Herdr's updates to the original.
