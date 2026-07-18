This file contains information about the dependencies.

It mainly describes about `sdata/dist-arch` which is actively maintained by the devs.

Tips:
- The packages which name has prefix `illogical-impulse-` are defined with local files `PKGBUILD`. There're two types:
  - **Meta packages**, which do not have actual content but only include other packages specified in the array `depends`.
  - **Actual packages**, which not only install dependencies listed in `depends`, but also build packages which have actual content to be installed later.
- For each package included in the local `PKGBUILD`s which name does **not** have prefix `illogical-impulse-`, for example `rsync`, it's either from [Arch Linux Packages](https://archlinux.org/packages) or the [AUR](https://aur.archlinux.org/packages). Search the package name on them to get the info (e.g. what executable(s) the package provides).

# Meta packages
## illogical-impulse-audio
- `cava`
  - Used in Quickshell config.
- `pavucontrol-qt`
  - Used in Hyprland and Quickshell config.
- `wireplumber`
  - Not explicitly used.
- `pipewire-pulse`
  - Not explicitly used.
- `libdbusmenu-gtk3`
  - Not explicitly used.
- `playerctl`
  - Used in Hyprland and Quickshell config.

## illogical-impulse-backlight
- `geoclue`
  - Which demo agent used in Quickshell config.
- `brightnessctl`
  - Used in Hyprland and Quickshell config.
- `ddcutil`
  - Used in Quickshell config.

## illogical-impulse-basic
- `bc`
  - Used in `quickshell/ii/scripts/colors/switchwall.sh` for example.
- `coreutils`
  - Too many executables involved, not sure where been used.
- `cliphist`
  - Used in Hyprland and Quickshell config.
- `curl`
  - Used in Quickshell config.
- `wget`
  - Used in Quickshell config.
- `ripgrep`
  - Not sure where been used.
- `jq`
  - Widely used.
- `xdg-user-dirs`
  - Used in Hyprland and Quickshell config.
- `rsync`
  - Used in install script.
- `go-yq`
  - Used in install script.

## illogical-impulse-fonts-themes
- `adw-gtk-theme`
  - [source](https://github.com/lassekongo83/adw-gtk3)
  - Used in Quickshell config.
- `breeze`
  - Used in kdeglobals config.
- `breeze-plus`
  - [source](https://github.com/mjkim0727/breeze-plus)
  - Used in kde-material-you-colors config.
- `darkly-bin`
  - `darkly` is supposed to be set as the theme for Qt apps, just have not figured out how to properly set it yet.
- `eza`
  - Used in Fish config: `alias ls 'eza --icons'`
- `fish`
  - Widely used.
- `fontconfig`
  - Basic component which is nearly a must.
- `kitty`
  - Used in fuzzel, Hyprland, kdeglobals and Quickshell config; kitty config is also included as dots.
- `otf-atkinson-hyperlegible-next`
  - Font name: `Atkinson Hyperlegible Next`
  - System-wide default sans-serif/serif font via fontconfig.
- `otf-space-grotesk`
  - [source](https://events.ccc.de/congress/2024/infos/styleguide.html)
  - Used in Quickshell config.
- `starship`
  - Used in Fish config.
- `ttf-firacode-nerd`
  - Font name: `FiraCode Nerd Font`
  - Used as monospace font in Quickshell config.
- `ttf-iosevkatermslab-nerd`
  - Font name: `IosevkaTermSlab Nerd Font`
  - Used as kitty terminal font.
- `ttf-jetbrains-mono-nerd`
  - Font name: `JetBrains Mono NF`, `JetBrainsMono Nerd Font`.
  - Used in foot, kdeglobals, kitty, qt5ct, qt6ct and Quickshell config.
- `ttf-material-symbols-variable`
  - Font name: `Material Symbols Rounded`, `Material Symbols Outlined`
  - Used in Hyprland, Quickshell and wlogout config.
- `ttf-readex-pro`
  - Font name: `Readex Pro`
  - Used in Quickshell config.
- `ttf-rubik-vf`
  - Font name: `Rubik`, `Rubik Light`
  - Used in Hyprland, kdeglobals, qt5ct, qt6ct and Quickshell config.
- `ttf-twemoji`
  - Not explicitly used, but it may help as fallback for displaying emoji characters.

### Bundled Fonts (installed from repo, not packages)
- **Google Sans Flex** - Variable font for UI numbers, hyprlock, fuzzel, digital clock. Bundled in `dots/.local/share/fonts/`.
- **Mikhak** - Variable font for primary UI/title/expressive font in Quickshell. Bundled in `dots/.local/share/fonts/mikhak/`.

## illogical-impulse-hyprland
- `bluez`
  - Bluetooth support.
- `hyprland`
  - Core compositor.
- `hyprland-protocols`
  - Hyprland protocol definitions.
- `hyprwayland-scanner`
  - Wayland protocol scanner for Hyprland.
- `hyprutils`
  - Hyprland utility library.
- `hyprgraphics`
  - Hyprland graphics library.
- `hyprlang`
  - Hyprland config language library.
- `hyprcursor`
  - Hyprland cursor library.
- `aquamarine`
  - Hyprland renderer backend.
- `xdg-desktop-portal-hyprland`
  - XDG desktop portal for Hyprland.
- `hyprwire`
  - Hyprland screen sharing.
- `hyprtoolkit`
  - Hyprland toolkit library.
- `hyprland-qt-support`
  - Qt support for Hyprland.
- `wl-clipboard`
  - Wayland clipboard utilities.

## illogical-impulse-kde
- `bluedevil`
  - Provide command `kcmshell6 kcm_bluetooth` used by Quickshell bluetooth functionality.
- `gnome-keyring`
  - Provide executable `gnome-keyring-daemon`, used in Hyprland and Quickshell config.
- `networkmanager`
  - Basic component.
- `plasma-nm`
  - Provide command `kcmshell6 kcm_networkmanagement` used by Quickshell network functionality.
- `polkit-kde-agent`
  - Basic component.
- `dolphin`
  - Used in Hyprland and Quickshell config.
- `systemsettings`
  - Used in Hyprland keybinds.

## illogical-impulse-portal
- `xdg-desktop-portal`
  - Basic component.
- `xdg-desktop-portal-kde`
  - Basic component.
- `xdg-desktop-portal-gtk`
  - Basic component.
- `xdg-desktop-portal-hyprland`
  - Basic component.

## illogical-impulse-python
- `clang`
  - Some python package may need this to be built, e.g. #1235. This may varies on different distros though.
- `uv`
  - Used for python venv.
- `gtk4`
  - Not explicitly used.
- `libadwaita`
  - Not explicitly used.
- `libsoup3`
  - Not explicitly used.
- `libportal-gtk4`
  - Not explicitly used.
- `gobject-introspection`
  - Not explicitly used.

## illogical-impulse-screencapture
- `hyprshot`
  - Used in Hyprland keybinds as fallback.
- `slurp`
  - Used in Hyprland and Quickshell config.
- `swappy`
  - Used in Quickshell config.
- `tesseract`
  - Used in Quickshell and Hyprland config.
- `tesseract-data-eng`
  - Used as data for tesseract.
- `wf-recorder`
  - Used in Quickshell config.

## illogical-impulse-toolkit
- `upower`
  - Used in Quickshell config.
- `wtype`
  - Used in Hyprland `scripts/fuzzel-emoji.sh`
- `ydotool`
  - Used in Quickshell config.

## illogical-impulse-widgets
- `fuzzel`
  - Used in Hyprland and Quickshell config; its config is also included.
- `glib2`
  - Provides executable `gsettings`
  - Used in install script and quickshell config.
- `imagemagick`
  - Provides executable: `magick`
  - Used in Quickshell config.
- `hypridle`
  - Used for loginctl to lock session.
- `hyprlock`
  - Installed as fallback; its config is also included.
- `hyprpicker`
  - Used in Hyprland and Quickshell config.
- `songrec`
  - Used in Quickshell config.
- `translate-shell`
  - Used in Quickshell config.
- `wlogout`
  - Used in Hyprland config.
- `libqalculate`
  - Used in Quickshell config, providing math ability in searchbar.
  - Note that `qalc` is the needed executable. In Arch Linux [libqalculate](https://archlinux.org/packages/extra/x86_64/libqalculate) provides it.

# Actual packages
## illogical-impulse-oreo-cursors-bin
- Pre-built cursor theme package.
