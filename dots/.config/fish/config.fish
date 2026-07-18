# =============================================================================
# 1. CORE ENVIRONMENT & SHELL OPTIONS
# =============================================================================
set -gx CLICOLOR 1
set -gx COLORTERM truecolor
set -gx MANPAGER "less -R"
set -gx SUDO_EDITOR kwrite
set -gx EDITOR nano
set -gx VISUAL nano

# Amoled Warm Palette
set -g fish_color_command brmagenta
set -g fish_color_keyword brpurple
set -g fish_color_param    yellow
set -g fish_color_error    red
set -g fish_color_comment brblack

# =============================================================================
# 2. FILE PATHS
# =============================================================================
set -l system_paths \
    /usr/lib/ccache/bin \
    $HOME/.local/bin \
    $HOME/.local/share/fish/site_functions

fish_add_path $system_paths

if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

# =============================================================================
# 3. WAYLAND / ELECTRON
# =============================================================================
set -gx ELECTRON_OZONE_PLATFORM_HINT wayland

# =============================================================================
# 4. ALIASES & TOOLS
# =============================================================================
if type -q uu-cat
    for tool in cat cp mkdir mv rm touch chmod chown
        alias $tool "uu-$tool"
    end
end

alias ls     "eza -lh --icons --group-directories-first"
alias ll     "eza -lah --icons --group-directories-first --git"
alias tree   "eza --tree --icons"
alias grep   "grep --color=auto"
alias trim   "sudo fstrim -av"
alias tar    "bsdtar"
alias cls    "clear"
alias upd    'paru -Syu --noconfirm; flatpak update -y; rustup update'
alias add    'paru -S'
alias del    'paru -Rns --noconfirm'
alias purge  'paru -Rns; paru -Qtdq | paru -Rns -'
alias list   'paru -Qe'
alias search 'paru -Ss'
alias cclean 'sudo paccache -rk0; sudo rm -rf /var/cache/pacman/pkg/download-*; rm -rf ~/.cache/paru/clone/*; paru -Sc --noconfirm'

# =============================================================================
# 5. USEFUL FUNCTIONS
# =============================================================================
function cmem --description "Memory Purge & Zram Reset"
    sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
    free -h
end

# =============================================================================
# 6. INITIALIZATION
# =============================================================================
starship init fish | source

# bun
if test -d "$HOME/.bun"
    set --export BUN_INSTALL "$HOME/.bun"
    set --export PATH $BUN_INSTALL/bin $PATH
end
