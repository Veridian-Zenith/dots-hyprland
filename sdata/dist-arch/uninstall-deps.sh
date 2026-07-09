# This script is meant to be sourced.
# It's not for directly running.

# Auto-detect AUR helper
if command -v yay >/dev/null 2>&1; then
  AUR_HELPER="yay"
elif command -v paru >/dev/null 2>&1; then
  AUR_HELPER="paru"
else
  printf "${STY_RED}[$0]: No AUR helper found. Cannot uninstall.${STY_RST}\n"
  return 1 2>/dev/null || exit 1
fi

for i in illogical-impulse-{audio,backlight,basic,oreo-cursors-bin,fonts-themes,hyprland,portal,python,screencapture,toolkit,widgets}; do
  v $AUR_HELPER -Rns $i
done
