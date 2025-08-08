#!/usr/bin/env bash
set -euo pipefail

# Resolve absolute dir of this script (so images work regardless of cwd)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"

IMG_MORNING="$SCRIPT_DIR/pines.jpg"
IMG_AFTERNOON="$SCRIPT_DIR/city.jpg"
IMG_EVENING="$SCRIPT_DIR/sunset.jpg"
IMG_NIGHT="$SCRIPT_DIR/stars.jpg"

# Only run inside a Wayland session (best-effort autodetect)
if [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
  if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
    for sock in "${XDG_RUNTIME_DIR}/wayland-1" "${XDG_RUNTIME_DIR}/wayland-0"; do
      [[ -S "$sock" ]] && export WAYLAND_DISPLAY="$(basename "$sock")" && break
    done
  fi
fi
[[ -z "${WAYLAND_DISPLAY:-}" ]] && exit 0

# Time bucket
hour=$(date +%H)
if   [ "$hour" -ge 6  ] && [ "$hour" -lt 11 ]; then block=morning
elif [ "$hour" -ge 11 ] && [ "$hour" -lt 17 ]; then block=afternoon
elif [ "$hour" -ge 17 ] && [ "$hour" -lt 21 ]; then block=evening
else block=night
fi

case "$block" in
  morning)   img="$IMG_MORNING";   mode=light ;;
  afternoon) img="$IMG_AFTERNOON"; mode=light ;;
  evening)   img="$IMG_EVENING";   mode=dark  ;;
  night)     img="$IMG_NIGHT";     mode=dark  ;;
esac

# Need swww
if ! command -v swww >/dev/null 2>&1; then
  echo "swww not found in PATH; skipping." >&2
  exit 0
fi

# Ensure swww-daemon is running
if ! pgrep -x swww-daemon >/dev/null 2>&1; then
  setsid swww-daemon >/dev/null 2>&1 &
  sleep 0.2
fi

# Wallpaper transition
swww img "$img" --transition-type grow --transition-duration 0.7 || exit 0

# Alacritty palette swap (Helix stays term16_* -> transparency via window.opacity)
colors_dir="$HOME/.config/alacritty"
mkdir -p "$colors_dir"

if [[ "$mode" == "light" ]]; then
  # DAY: lighter dark bg, **white text**
  cat > "${colors_dir}/colors.toml" <<'EOF'
[colors.primary]
background = "#1e222a"
foreground = "#ffffff"

[colors.normal]
black   = "#3b4048"
red     = "#cc342b"
green   = "#198844"
yellow  = "#fba922"
blue    = "#3971ed"
magenta = "#a36ac7"
cyan    = "#2aa1b3"
white   = "#e6e6e6"

[colors.bright]
black   = "#4a505a"
red     = "#d6493f"
green   = "#23a456"
yellow  = "#ffb63a"
blue    = "#4a85ff"
magenta = "#b97ae0"
cyan    = "#39b8c7"
white   = "#ffffff"
EOF
else
  # NIGHT: darker bg, **white text**
  cat > "${colors_dir}/colors.toml" <<'EOF'
[colors.primary]
background = "#0b0e14"
foreground = "#ffffff"

[colors.normal]
black   = "#2a2e36"
red     = "#e95678"
green   = "#29d398"
yellow  = "#fab795"
blue    = "#26bbd9"
magenta = "#ee64ac"
cyan    = "#59e1e3"
white   = "#d3d6db"

[colors.bright]
black   = "#3a3f4b"
red     = "#ec6a88"
green   = "#3fdaa4"
yellow  = "#fbc3a7"
blue    = "#3fc6de"
magenta = "#f075b7"
cyan    = "#6be4e6"
white   = "#ffffff"
EOF
fi

# Nudge Alacritty to live-reload (requires live_config_reload = true)
touch "${colors_dir}/colors.toml"

