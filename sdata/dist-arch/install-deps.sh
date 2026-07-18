# This script is meant to be sourced.
# It's not for directly running.

install-yay(){
  x sudo pacman -S --needed --noconfirm --overwrite '*' base-devel
  x git clone https://aur.archlinux.org/yay-bin.git /tmp/buildyay
  x cd /tmp/buildyay
  x makepkg -o
  x makepkg -se
  rm -f *.pkg.tar.zst
  x sudo pacman -U --needed --noconfirm --overwrite '*' *.pkg.tar.zst
  x cd ${REPO_ROOT}
  rm -rf /tmp/buildyay
}

remove_deprecated_dependencies(){
  printf "${STY_CYAN}[$0]: Removing deprecated dependencies:${STY_RST}\n"
  local list=()
  list+=(illogical-impulse-{microtex-git,quickshell-git,quickshell-git-bin,pymyc-aur,oneui4-icons-git})
  for i in ${list[@]};do try sudo pacman --noconfirm -Rdd $i;done
}

#####################################################################################
if ! command -v pacman >/dev/null 2>&1; then
  printf "${STY_RED}[$0]: pacman not found, it seems that the system is not ArchLinux or Arch-based distros. Aborting...${STY_RST}\n"
  exit 1
fi

# Keep makepkg from resetting sudo credentials
if [[ -z "${PACMAN_AUTH:-}" ]]; then
  export PACMAN_AUTH="sudo"
fi

showfun remove_deprecated_dependencies
v remove_deprecated_dependencies

# Issue #363
case $SKIP_SYSUPDATE in
  true) true;;
  *) v sudo pacman -Syu;;
esac

# Auto-detect AUR helper: prefer yay, fallback to paru
if command -v yay >/dev/null 2>&1; then
  AUR_HELPER="yay"
elif command -v paru >/dev/null 2>&1; then
  AUR_HELPER="paru"
else
  echo -e "${STY_YELLOW}[$0]: No AUR helper found. Installing yay...${STY_RST}"
  showfun install-yay
  v install-yay
  AUR_HELPER="yay"
fi
echo -e "${STY_BLUE}[$0]: Using AUR helper: ${AUR_HELPER}${STY_RST}"

install-local-pkgbuild() {
  local location=$1
  local installflags=$2

  x pushd $location

  source ./PKGBUILD
  x $AUR_HELPER -S --sudoloop --needed --overwrite '*' $installflags --asdeps "${depends[@]}"
  rm -f *.pkg.tar.zst
  x makepkg -Af
  x sudo pacman -U --needed --noconfirm --overwrite '*' *.pkg.tar.zst
  x popd
}

# Install core dependencies from the meta-packages
metapkgs=(./sdata/dist-arch/illogical-impulse-{audio,backlight,basic,fonts-themes,portal,python,screencapture,toolkit,widgets})
metapkgs+=(./sdata/dist-arch/illogical-impulse-hyprland)
metapkgs+=(./sdata/dist-arch/illogical-impulse-oreo-cursors-bin)

for i in "${metapkgs[@]}"; do
  metainstallflags="--needed"
  $ask && showfun install-local-pkgbuild || metainstallflags="$metainstallflags --noconfirm"
  v install-local-pkgbuild "$i" "$metainstallflags"
done

# Install quickshell from repos
v $AUR_HELPER -S --needed --noconfirm --overwrite '*' quickshell
