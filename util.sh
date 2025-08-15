#!/bin/bash
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

get_timer(){
    echo $(date +%s)
}

# $1: start timer
elapsed_time(){
    echo $(echo $1 $(get_timer) | awk '{ printf "%0.2f",($2-$1)/60 }')
}

show_elapsed_time(){
    log_info "Time %s: %s minutes" "$1" "$(elapsed_time $2)"
}

check_root(){
    (( EUID == 0 )) && return
    if type -P sudo >/dev/null; then
        exec sudo -- "$@"
    else
        exec su root -c "$(printf ' %q' "$@")"
    fi
}

check_requirements() {
    local packages=("archiso" "squashfs-tools")
    local helpers=("yay" "paru" "trizen")

    for package in "${packages[@]}"; do
        if pacman -Qi "$package" &>/dev/null; then
            log_info "'$package' is already installed."
            continue
        fi

        local installed=false
        for helper in "${helpers[@]}"; do
            if pacman -Qi $helper &>/dev/null; then
                log_note "Installing '$package' using: $helper"
                case "$helper" in
                    yay|paru) $helper -S --noconfirm --needed $package ;;
                    trizen)   $helper -S --noconfirm --needed --noedit $package ;;
                esac
                installed=true
                break
            fi
        done

        if pacman -Qi $package &>/dev/null; then
            log_info "Successfully installed '$package'."
        else
            log_error "Failed to install '$package'."
            exit 1
        fi
    done
}

prepare_dir() {
    local dir="$1"
    [[ ! -d $dir ]] && mkdir -p $dir
}

load_vars() {
    [[ -f $1 ]] || return 1

    local var
    for var in {SRC,SRCPKG,PKG,LOG}DEST MAKEFLAGS PACKAGER CARCH GPGKEY; do
        [[ -z ${!var} ]] && eval $(grep -a "^${var}=" "$1")
    done

    return 0
}

create_checksums() {
    log_note "creating checksums for [$1]"
    sha256sum $1 > $1.sha256
    md5sum $1 > $1.md5
}

sign_with_key() {
    load_vars "$HOME/.makepkg.conf"
    load_vars /etc/makepkg.conf

    if [ ! -e "$1" ]; then
        log_error "%s does not exist!" "$1"
        exit 1
    fi

    log_note "signing [%s] with key %s" "${1##*/}" "${GPGKEY}"
    [[ -e "$1".sig ]] && rm "$1".sig

    local SIGNWITHKEY=()
    if [[ -n $GPGKEY ]]; then
        SIGNWITHKEY=(-u "${GPGKEY}")
    fi
    gpg --detach-sign --use-agent "${SIGNWITHKEY[@]}" "$1"
}
