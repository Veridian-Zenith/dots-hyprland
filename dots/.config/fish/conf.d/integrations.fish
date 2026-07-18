# =============================================================================
# User-friendly shell integrations
# =============================================================================

# Window title: directory + the command currently running
function fish_title
    echo -s (prompt_pwd) ' '(status current-command)
end

# Directory shortcuts
abbr -a --position anywhere ..  'cd ..'
abbr -a --position anywhere ... 'cd ../..'
abbr -a --position anywhere .... 'cd ../../..'

# Git abbreviations (fish-native, no plugins needed)
abbr -a g   'git'
abbr -a ga  'git add'
abbr -a gaa 'git add --all'
abbr -a gc  'git commit'
abbr -a gcm 'git commit -m'
abbr -a gst 'git status'
abbr -a gd  'git diff'
abbr -a gds 'git diff --staged'
abbr -a gp  'git push'
abbr -a gpl 'git pull'
abbr -a gl  'git log --oneline --graph --decorate -15'
abbr -a gco 'git checkout'
abbr -a gb  'git branch'
abbr -a gf  'git fetch'

# mkcd: create a directory and cd into it
function mkcd --description "Create a directory and enter it"
    mkdir -p $argv; and cd $argv
end

# z: smart directory jumping (if zoxide is installed)
if type -q zoxide
    zoxide init fish | source
end
