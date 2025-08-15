#!/usr/bin/env bash

# This file is copied and modified from CachyOS-Live-ISO.

# SPDX-License-Identifier: GPL-3.0-only
#
# This file is part of Archeon-Live-ISO.
#
# Copyright (c) 2025 erffy
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https:#www.gnu.org/licenses/>.

export LC_MESSAGES=C
export LANG=C

disable_colors() {
    unset COLOR_RESET COLOR_BOLD COLOR_RED COLOR_GREEN COLOR_YELLOW COLOR_BLUE
}

enable_colors() {
    if command -v tput &>/dev/null && tput setaf 0 &>/dev/null; then
        COLOR_RESET="$(tput sgr0)"
        COLOR_BOLD="$(tput bold)"
        COLOR_RED="${COLOR_BOLD}$(tput setaf 1)"
        COLOR_GREEN="${COLOR_BOLD}$(tput setaf 2)"
        COLOR_YELLOW="${COLOR_BOLD}$(tput setaf 3)"
        COLOR_BLUE="${COLOR_BOLD}$(tput setaf 4)"
    else
        COLOR_RESET="\e[0m"
        COLOR_BOLD="\e[1m"
        COLOR_RED="${COLOR_BOLD}\e[31m"
        COLOR_GREEN="${COLOR_BOLD}\e[32m"
        COLOR_YELLOW="${COLOR_BOLD}\e[33m"
        COLOR_BLUE="${COLOR_BOLD}\e[34m"
    fi
    readonly COLOR_RESET COLOR_BOLD COLOR_RED COLOR_GREEN COLOR_YELLOW COLOR_BLUE
}

[[ -t 2 ]] && enable_colors || disable_colors

log_plain()   { printf "%b\n" "${COLOR_BOLD}    $*${COLOR_RESET}" >&2; }
log_success() { printf "%b\n" "${COLOR_GREEN}==>${COLOR_RESET}${COLOR_BOLD} $*${COLOR_RESET}" >&2; }
log_note()    { printf "%b\n" "${COLOR_BLUE}  ->${COLOR_RESET}${COLOR_BOLD} $*${COLOR_RESET}" >&2; }
log_info()    { printf "%b\n" "${COLOR_YELLOW} -->${COLOR_RESET}${COLOR_BOLD} $*${COLOR_RESET}" >&2; }
log_warning() { printf "%b\n" "${COLOR_YELLOW}==> WARNING:${COLOR_RESET}${COLOR_BOLD} $*${COLOR_RESET}" >&2; }
log_error()   { printf "%b\n" "${COLOR_RED}==> ERROR:${COLOR_RESET}${COLOR_BOLD} $*${COLOR_RESET}" >&2; }
status_start() { printf "%b" "${COLOR_GREEN}==>${COLOR_RESET}${COLOR_BOLD} $*...${COLOR_RESET}" >&2; }
status_done()  { printf "%b\n" "${COLOR_BOLD}done${COLOR_RESET}" >&2; }

exit_cleanup() { exit "${1:-0}"; }

abort_script() {
    log_error 'Aborting...'
    exit_cleanup 255
}

fatal_error() {
    (( $# )) && log_error "$*"
    exit_cleanup 255
}

import() {
    local file="$1"
    if [[ -r "$file" ]]; then
        source $file
    else
        fatal_error "Could not import '$file'"
    fi
}