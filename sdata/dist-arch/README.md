# Install scripts for Arch Linux

- See also [Install scripts | illogical-impulse](https://ii.clsty.link/en/dev/inst-script/)

## Current Dependency Installation
Local PKGBUILDs under `./sdata/dist-arch/` define meta-packages that group dependencies by category (audio, backlight, basic, fonts-themes, hyprland, portal, python, screencapture, toolkit, widgets).

The meta-packages are installed via `./sdata/dist-arch/install-deps.sh` which:
1. Removes deprecated packages from older versions
2. Runs `pacman -Syu` for system update
3. Installs yay (AUR helper) if not present
4. Installs each meta-package's dependencies via the AUR helper
5. Installs `quickshell` from repos

## Package Categories
- **audio**: cava, pavucontrol-qt, wireplumber, pipewire-pulse, playerctl
- **backlight**: geoclue, brightnessctl, ddcutil
- **basic**: bc, coreutils, cliphist, curl, wget, ripgrep, jq, xdg-user-dirs, rsync, go-yq
- **fonts-themes**: adw-gtk-theme, eza, fish, fontconfig, kitty, otf-space-grotesk, starship, ttf-jetbrains-mono-nerd, ttf-material-symbols-variable, ttf-readex-pro, ttf-rubik-vf, ttf-twemoji
- **hyprland**: bluez, hyprland, hyprland-protocols, hyprwayland-scanner, hyprutils, hyprgraphics, hyprlang, hyprcursor, aquamarine, xdg-desktop-portal-hyprland, hyprwire, hyprtoolkit, hyprland-qt-support, wl-clipboard
- **kde**: bluedevil, gnome-keyring, networkmanager, plasma-nm, polkit-kde-agent, dolphin, systemsettings
- **portal**: xdg-desktop-portal, xdg-desktop-portal-gtk, xdg-desktop-portal-hyprland
- **python**: clang, uv, gtk4, libadwaita, libsoup3, libportal-gtk4, gobject-introspection
- **screencapture**: hyprshot, slurp, swappy, tesseract, tesseract-data-eng, wf-recorder
- **toolkit**: dgop, upower, wtype, ydotool
- **widgets**: fuzzel, glib2, imagemagick, hypridle, hyprlock, hyprpicker, songrec, translate-shell, wlogout, libqalculate

## Note
- All dependencies use binary packages from official repos or AUR (no `-git` packages built from source).
- `pkgver()` should be removed from `PKGBUILD` cuz it will modify the `PKGBUILD` which is tracked by Git and should not be modified during building.
