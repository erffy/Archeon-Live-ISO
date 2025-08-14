if type -q Hyprland && set -q AUTOLOGIN
    set -e AUTOLOGIN
    exec Hyprland
end

# Disable the default greeting
set fish_greeting ''

# Initialize starship prompt if available
if type -q starship
    starship init fish --print-full-init | source
end

# Initialize zoxide if available
if type -q zoxide
    zoxide init fish | source
    alias zd="z"
    alias cd="z"
end

# Display system info on startup if fastfetch available
if type -q fastfetch
    fastfetch
end

# =============================================================================
# CORE ALIASES
# =============================================================================

alias c="clear"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias df="df -h"
alias free="free -h"
alias grep="grep --color=auto"
alias ip="ip -c address"

# Process management
alias psg="ps aux | grep"
alias htop="htop -t" # tree view
alias killall="killall -i" # interactive

# =============================================================================
# TOOL REPLACEMENTS
# =============================================================================

# Replace cat with bat if available
if type -q bat
    alias cat="bat --style=plain --paging=never"
    alias batl="bat --style=numbers --paging=always" # with line numbers
end

# Replace ls with eza if available
if type -q eza
    alias ls="eza --icons"
    alias ll="eza -la --icons --git"
    alias la="eza -a --icons"
    alias lt="eza -T --icons"
    alias lsg="eza --git-ignore --icons"
    alias tree="eza -T --icons" # tree replacement
end

# Add yay aliases if available
if type -q yay
    alias yu="yay -Syu --noconfirm"
    alias y="yay"
    alias yc="yay -Yc" # clean cache
    alias ys="yay -Ss" # search
    alias yr="yay -Rns" # remove with deps
end

# Add aria2 alias if available
if type -q aria2c
    alias a2="aria2c -x 16 -s 16 -d '$HOME/Downloads'"
end

# =============================================================================
# DIRECTORY BOOKMARKS
# =============================================================================

function mark
    if test (count $argv) -eq 0
        echo "Usage: mark <bookmark_name>"
        return 1
    end
    set -U fish_mark_$argv[1] (pwd)
    echo "Marked (pwd) as '$argv[1]'"
end

function goto
    if test (count $argv) -eq 0
        marks
        return
    end
    if set -q fish_mark_$argv[1]
        cd $fish_mark_$argv[1]
    else
        echo "Bookmark '$argv[1]' not found"
        return 1
    end
end

function unmark
    if test (count $argv) -eq 0
        echo "Usage: unmark <bookmark_name>"
        return 1
    end
    if set -q fish_mark_$argv[1]
        set -e fish_mark_$argv[1]
        echo "Removed bookmark '$argv[1]'"
    else
        echo "Bookmark '$argv[1]' not found"
        return 1
    end
end

function marks
    set -l marks (set -n | grep ^fish_mark_)
    if test (count $marks) -eq 0
        echo "No bookmarks set"
        return
    end
    for mark in $marks
        set -l mark_name (string replace fish_mark_ '' $mark)
        set -l mark_path $$mark
        printf "%-15s -> %s\n" $mark_name $mark_path
    end
end

# =============================================================================
# KUBERNETES
# =============================================================================

if type -q kubectl
  alias k="kubectl"
end

if type -q kustomize
  alias ku="kustomize"
end

# =============================================================================
# GIT ALIASES
# =============================================================================

if type -q git
    alias gs="git status -s"
    alias ga="git add"
    alias gaa="git add -A"
    alias gc="git commit -m"
    alias gca="git commit -am"
    alias gp="git push"
    alias gpl="git pull"
    alias gd="git diff"
    alias gdc="git diff --cached"
    alias gco="git checkout"
    alias gcb="git checkout -b"
    alias gb="git branch"
    alias gbd="git branch -d"
    alias glog="git log --oneline --graph --decorate --all"
    alias gstash="git stash"
    alias gpop="git stash pop"
    alias gclean="git clean -fd"
    alias greset="git reset --hard HEAD"
end

# =============================================================================
# ENVIRONMENT VARIABLES & PATHS
# =============================================================================

# Use nvim as default editor if available, fallback to vim
if type -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    alias vi="nvim"
    alias vim="nvim"
    alias nano="nvim"
    alias v="nvim"
else if type -q vim
    set -gx EDITOR vim
    set -gx VISUAL vim
    alias vi="vim"
    alias nano="vim"
    alias nvim="vim"
    alias v="vim"
else if type -q vi
    set -gx EDITOR vi
    set -gx VISUAL vi
    alias vim="vi"
    alias nano="vi"
    alias nvim="vi"
    alias v="vi"
else if type -q nano
    set -gx EDITOR nano
    set -gx VISUAL nano
    alias vi="nano"
    alias nvim="nano"
    alias vim="nano"
    alias v="nano"
end

# Add pnpm home path if PNPM is installed
if type -q pnpm
    set -gx PNPM_HOME "$HOME/.local/share/pnpm"
    fish_add_path $PNPM_HOME
end

# Add cargo bin path if Rust is installed
if test -d $HOME/.cargo/bin
    fish_add_path $HOME/.cargo/bin
end

# Add go bin path if Go is installed
if test -d $HOME/go/bin
    fish_add_path $HOME/go/bin
end

# Add bun bin path if Bun is installed
if test -d $XDG_CACHE_HOME/.bun/bin
    fish_add_path $XDG_CACHE_HOME/.bun/bin
end

# Add local bin paths
if test -d $HOME/.local/bin
    fish_add_path $HOME/.local/bin
end

# =============================================================================
# ZIG-SPECIFIC SETTINGS
# =============================================================================

if type -q zig
    # Set Zig cache directory
    set -gx ZIG_CACHE_DIR "$HOME/.cache/zig"

    # Zig aliases
    alias zb="zig build"
    alias zbr="zig build run"
    alias zbt="zig build test"
    alias zr="zig run"
    alias zt="zig test"
    alias zfmt="zig fmt"
    alias zcheck="zig ast-check"
    alias zversion="zig version"

    function zbuild-release
        zig build -Doptimize=ReleaseFast
    end

    function zclean
        if test -d zig-cache
            rm -rf zig-cache
            echo "Cleaned zig-cache"
        end
        if test -d zig-out
            rm -rf zig-out
            echo "Cleaned zig-out"
        end
    end
end

# =============================================================================
# DEVELOPMENT HELPERS
# =============================================================================

# Make and change to directory
function mkcd
    if test (count $argv) -eq 0
        echo "Usage: mkcd <directory_name>"
        return 1
    end
    mkdir -p $argv[1] && cd $argv[1]
end

# Find and kill process by name
function killp
    if test (count $argv) -eq 0
        echo "Usage: killp <process_name>"
        return 1
    end
    ps aux | grep $argv[1] | grep -v grep | awk '{print $2}' | xargs kill -9
end

# checksum
function checksum
    set type ""
    set file ""
    set expected ""

    for i in (seq 1 (count $argv))
        switch $argv[$i]
            case --type -t
                set type $argv[(math $i + 1)]
            case --file -f
                set file $argv[(math $i + 1)]
            case --sum -s
                set expected $argv[(math $i + 1)]
        end
    end

    if test -z "$type" -o -z "$file" -o -z "$expected"
        echo "Usage: checksum --type <md5|sha1|sha256|sha512> --file <file> --sum <expected_checksum>"
        return 1
    end

    if not test -f "$file"
        echo "Error: File '$file' not found."
        return 1
    end

    switch $type
        case md5
            set actual (md5sum $file | awk '{print $1}')
        case sha1
            set actual (sha1sum $file | awk '{print $1}')
        case sha256
            set actual (sha256sum $file | awk '{print $1}')
        case sha512
            set actual (sha512sum $file | awk '{print $1}')
        case '*'
            echo "Unsupported hash type: $type"
            return 1
    end

    if test "$actual" = "$expected"
        echo "$type checksum matches."
        return 0
    else
        echo "$type checksum does not match."
        echo "Expected: $expected"
        echo "Actual:   $actual"
        return 2
    end
end

# =============================================================================
# ARCHIVE FUNCTIONS
# =============================================================================

function extract
    if test (count $argv) -eq 0
        echo "Usage: extract <archive-file>"
        return 1
    end

    if not test -f $argv[1]
        echo "Error: '$argv[1]' is not a valid file"
        return 1
    end

    set fullpath (realpath $argv[1])
    set filename (basename $fullpath)
    set -l known_exts tar.bz2 tar.gz tar.xz tbz2 tgz tar bz2 gz xz rar zip Z 7z

    set name $filename
    for ext in $known_exts
        if string match -q "*.$ext" $filename
            set name (string replace ".$ext" '' $filename)
            break
        end
    end

    if test -z "$name"
        echo "Error: Could not determine base filename for '$filename'"
        return 1
    end

    set target_dir "$name"
    if not mkdir -p "$target_dir"
        echo "Error: Could not create target directory '$target_dir'"
        return 1
    end

    switch $filename
        case '*.tar.bz2'
            tar xjf "$fullpath" -C "$target_dir" || return 1
        case '*.tar.gz'
            tar xzf "$fullpath" -C "$target_dir" || return 1
        case '*.tar.xz'
            tar xJf "$fullpath" -C "$target_dir" || return 1
        case '*.tbz2'
            tar xjf "$fullpath" -C "$target_dir" || return 1
        case '*.tgz'
            tar xzf "$fullpath" -C "$target_dir" || return 1
        case '*.tar'
            tar xf "$fullpath" -C "$target_dir" || return 1
        case '*.bz2'
            bunzip2 -kc "$fullpath" > "$target_dir"/(string replace '.bz2' '' $filename) || return 1
        case '*.gz'
            gunzip -kc "$fullpath" > "$target_dir"/(string replace '.gz' '' $filename) || return 1
        case '*.xz'
            xz -dkc "$fullpath" > "$target_dir"/(string replace '.xz' '' $filename) || return 1
        case '*.rar'
            unrar x -o+ "$fullpath" "$target_dir"/ || return 1
        case '*.zip'
            unzip -d "$target_dir" "$fullpath" || return 1
        case '*.Z'
            uncompress -c "$fullpath" > "$target_dir"/(string replace '.Z' '' $filename) || return 1
        case '*.7z'
            7z x -o"$target_dir" "$fullpath" || return 1
        case '*'
            echo "Error: '$filename' cannot be extracted via extract"
            return 1
    end

    echo "Extracted to: $target_dir"
end

function compress
    if test (count $argv) -lt 2
        echo "Usage: compress [--add] <source1> [source2 ...] <archive-name.ext>"
        echo "  --add: Add to existing archive instead of creating new one"
        return 1
    end

    set -l add_mode false
    set -l sources

    if test $argv[1] = "--add"
        set add_mode true
        set sources $argv[2..-2]
        set archive $argv[-1]
    else
        set sources $argv[1..-2]
        set archive $argv[-1]
    end

    if test -z "$archive" || test -z "$sources"
        echo "Error: Invalid arguments"
        return 1
    end

    for source in $sources
        if not test -e $source
            echo "Error: Source '$source' does not exist"
            return 1
        end
    end

    set extension (string lower (string match -r '\.[^.]+$' $archive))

    if test $add_mode = true
        if not test -e $archive
            echo "Error: Archive '$archive' does not exist"
            return 1
        end

        switch $extension
            case '.tar.bz2'
                set temp_tar (string replace '.bz2' '' $archive)
                bunzip2 -k $archive && tar --append --file=$temp_tar $sources && bzip2 $temp_tar && mv $temp_tar.bz2 $archive || return 1
            case '.tar.gz'
                set temp_tar (string replace '.gz' '' $archive)
                gunzip -k $archive && tar --append --file=$temp_tar $sources && gzip $temp_tar && mv $temp_tar.gz $archive || return 1
            case '.tar.xz' '.tbz2' '.tgz'
                echo "Error: Cannot append to compressed $extension archives"
                return 1
            case '.tar'
                tar --append --file=$archive $sources || return 1
            case '.rar'
                rar a $archive $sources || return 1
            case '.zip'
                zip -ur $archive $sources || return 1
            case '.7z'
                7z a $archive $sources || return 1
            case '*'
                echo "Error: Unsupported archive type: $extension"
                return 1
        end
        echo "Added to archive: $archive"
    else
        switch $extension
            case '.tar.bz2'
                tar cjf $archive $sources || return 1
            case '.tar.gz'
                tar czf $archive $sources || return 1
            case '.tar.xz'
                tar cJf $archive $sources || return 1
            case '.tbz2'
                tar cjf $archive $sources || return 1
            case '.tgz'
                tar czf $archive $sources || return 1
            case '.tar'
                tar cf $archive $sources || return 1
            case '.bz2'
                if test (count $sources) -gt 1
                    echo "Error: Cannot compress multiple sources to .bz2 format"
                    return 1
                end
                bzip2 -k $sources[1] && mv $sources[1].bz2 $archive || return 1
            case '.gz'
                if test (count $sources) -gt 1
                    echo "Error: Cannot compress multiple sources to .gz format"
                    return 1
                end
                gzip -k $sources[1] && mv $sources[1].gz $archive || return 1
            case '.xz'
                if test (count $sources) -gt 1
                    echo "Error: Cannot compress multiple sources to .xz format"
                    return 1
                end
                xz -k $sources[1] && mv $sources[1].xz $archive || return 1
            case '.rar'
                rar a $archive $sources || return 1
            case '.zip'
                zip -r $archive $sources || return 1
            case '.7z'
                7z a $archive $sources || return 1
            case '*'
                echo "Error: Unknown or unsupported archive extension: $extension"
                return 1
        end
        echo "Compressed to: $archive"
    end
end

# =============================================================================
# KEY BINDINGS
# =============================================================================

# History navigation
bind \cp up-or-search # Ctrl+P for history search up
bind \cn down-or-search # Ctrl+N for history search down

# Cursor movement
bind \cf forward-char # Ctrl+F to move cursor forward
bind \cb backward-char # Ctrl+B to move cursor backward
bind \ca beginning-of-line # Ctrl+A to beginning of line
bind \ce end-of-line # Ctrl+E to end of line

# Word movement
bind \e\[1\;5D backward-word # Ctrl+Left to move back one word
bind \e\[1\;5C forward-word # Ctrl+Right to move forward one word

# Line editing
bind \ck kill-line # Ctrl+K to kill from cursor to end of line
bind \cu kill-whole-line # Ctrl+U to kill entire line
bind \cw backward-kill-word # Ctrl+W to kill previous word

# =============================================================================
# FISH-SPECIFIC SETTINGS
# =============================================================================

# Set fish color scheme (optional - uncomment if you like it)
# set -g fish_color_command blue
# set -g fish_color_param normal
# set -g fish_color_error red --bold
# set -g fish_color_comment brblack

# Enable vi mode (uncomment if you prefer vi keybindings)
# fish_vi_key_bindings
