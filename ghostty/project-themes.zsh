# Ghostty per-project theme switching
# Sources a .ghostty-theme file from the nearest parent directory
# and applies colors via OSC escape sequences.
#
# Setup: add `source ~/.config/ghostty/project-themes.zsh` to your .zshrc

# -- Default theme (your Tokyo Night config) ----------------------------------
# These are used when no .ghostty-theme file is found.
__ghostty_default_bg="#1a1b26"
__ghostty_default_fg="#c0caf5"
__ghostty_default_cursor="#c0caf5"
__ghostty_default_palette=(
  "#15161e" "#f7768e" "#9ece6a" "#e0af68"
  "#7aa2f7" "#bb9af7" "#7dcfff" "#a9b1d6"
  "#414868" "#f7768e" "#9ece6a" "#e0af68"
  "#7aa2f7" "#bb9af7" "#7dcfff" "#c0caf5"
)

# Track which theme file is active to avoid redundant repaints
__ghostty_active_theme_file=""

# -- Core: send OSC escape sequences ------------------------------------------

__ghostty_set_color() {
  # $1 = OSC code, $2 = color value
  printf '\033]%s;%s\007' "$1" "$2"
}

__ghostty_apply_theme() {
  local bg="$1" fg="$2" cursor="$3"
  shift 3
  local -a palette=("$@")

  __ghostty_set_color 11 "$bg"
  __ghostty_set_color 10 "$fg"
  __ghostty_set_color 12 "$cursor"

  for i in {0..15}; do
    if [[ -n "${palette[$((i+1))]}" ]]; then
      __ghostty_set_color "4;$i" "${palette[$((i+1))]}"
    fi
  done
}

# -- Parse a .ghostty-theme file ----------------------------------------------

__ghostty_parse_and_apply() {
  local theme_file="$1"
  local bg="" fg="" cursor=""
  local -a palette=()

  while IFS= read -r line; do
    # Strip leading/trailing whitespace
    line="${line## }"
    line="${line%% }"
    # Skip empty lines and comment lines (starting with #)
    [[ -z "$line" || "$line" == \#* ]] && continue

    local key="${line%%=*}"
    local val="${line#*=}"
    key="${key## }" ; key="${key%% }"
    val="${val## }" ; val="${val%% }"

    case "$key" in
      background)    bg="$val" ;;
      foreground)    fg="$val" ;;
      cursor-color)  cursor="$val" ;;
      palette)
        # Format: N=#color or N=color
        local idx="${val%%=*}"
        local color="${val#*=}"
        idx="${idx## }" ; idx="${idx%% }"
        color="${color## }" ; color="${color%% }"
        palette[$((idx+1))]="$color"
        ;;
    esac
  done < "$theme_file"

  # Fill in missing values with defaults
  [[ -z "$bg" ]]     && bg="$__ghostty_default_bg"
  [[ -z "$fg" ]]     && fg="$__ghostty_default_fg"
  [[ -z "$cursor" ]] && cursor="$__ghostty_default_cursor"

  for i in {0..15}; do
    [[ -z "${palette[$((i+1))]}" ]] && palette[$((i+1))]="${__ghostty_default_palette[$((i+1))]}"
  done

  __ghostty_apply_theme "$bg" "$fg" "$cursor" "${palette[@]}"
}

# -- Walk up directory tree to find .ghostty-theme -----------------------------

__ghostty_find_theme() {
  local dir="$1"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.ghostty-theme" ]]; then
      echo "$dir/.ghostty-theme"
      return 0
    fi
    dir="${dir:h}"
  done
  return 1
}

# -- Hook: runs on every directory change --------------------------------------

__ghostty_chpwd_hook() {
  local theme_file
  theme_file="$(__ghostty_find_theme "$PWD")"

  if [[ -n "$theme_file" ]]; then
    # Only repaint if we switched to a different theme file
    if [[ "$theme_file" != "$__ghostty_active_theme_file" ]]; then
      __ghostty_active_theme_file="$theme_file"
      __ghostty_parse_and_apply "$theme_file"
    fi
  else
    # No theme found — reset to default if we were in a themed project
    if [[ -n "$__ghostty_active_theme_file" ]]; then
      __ghostty_active_theme_file=""
      __ghostty_apply_theme \
        "$__ghostty_default_bg" "$__ghostty_default_fg" "$__ghostty_default_cursor" \
        "${__ghostty_default_palette[@]}"
    fi
  fi
}

# -- Manual helpers ------------------------------------------------------------

# Force-reset to default Tokyo Night theme
reset-theme() {
  __ghostty_active_theme_file=""
  __ghostty_apply_theme \
    "$__ghostty_default_bg" "$__ghostty_default_fg" "$__ghostty_default_cursor" \
    "${__ghostty_default_palette[@]}"
  echo "Theme reset to default (Tokyo Night)"
}

# Apply a .ghostty-theme file manually
set-project-theme() {
  local file="${1:-.ghostty-theme}"
  if [[ ! -f "$file" ]]; then
    echo "No theme file found: $file"
    return 1
  fi
  __ghostty_active_theme_file="$(realpath "$file")"
  __ghostty_parse_and_apply "$file"
  echo "Applied theme from $file"
}

# Preview: show what theme would be applied from current directory
theme-info() {
  local theme_file
  theme_file="$(__ghostty_find_theme "$PWD")"
  if [[ -n "$theme_file" ]]; then
    echo "Active theme: $theme_file"
    echo "---"
    command cat "$theme_file"
  else
    echo "No .ghostty-theme found — using default (Tokyo Night)"
  fi
}

# -- Register the hook ---------------------------------------------------------

autoload -Uz add-zsh-hook
add-zsh-hook chpwd __ghostty_chpwd_hook

# Apply on shell startup too (in case terminal opens in a themed project)
__ghostty_chpwd_hook
