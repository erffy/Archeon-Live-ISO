#!/usr/bin/env bash

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

src_dir=$(pwd)
[[ -r ${src_dir}/util-msg.sh ]] && source ${src_dir}/util-msg.sh
import ${src_dir}/util.sh

work_dir="${src_dir}/build"
outFolder="${src_dir}/out"

build_list_iso="desktop"
clean_first=true
verbose=false

usage() {
    echo "Usage: ${0##*/} [options]"
    echo '    -c, --no-clean         Disable clean work dir'
    echo "    -p, --build-list <profile>  Buildset or profile [default: ${build_list_iso}]"
    echo '    -v, --verbose          Verbose output to log file, show profile detail (-q)'
    echo '    -h, --help             This help'
    echo ''
    exit $1
}

orig_argv=("$@")

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--no-clean)
            clean_first=false
            shift
            ;;
        -p|--build-list)
            if [[ -n $2 && $2 != -* ]]; then
                build_list_iso="$2"
                shift 2
            else
                echo "Error: --build-list requires an argument"
                usage 1
            fi
            ;;
        -v|--verbose)
            verbose=true
            shift
            ;;
        -h|--help)
            usage 0
            ;;
        *)
            echo "Invalid argument: $1"
            usage 1
            ;;
    esac
done

timer_start=$(get_timer)

prepare_dir $work_dir

import ${src_dir}/util-iso.sh
import ${src_dir}/util-iso-mount.sh

check_requirements

for sig in TERM HUP QUIT; do
    trap "trap_exit $sig \"$(gettext "%s signal caught. Exiting...")\" \"$sig\"" "$sig"
done
trap 'trap_exit INT "$(gettext "Aborted by user! Exiting...")"' INT
trap 'trap_exit USR1 "$(gettext "An unknown error has occurred. Exiting...")"' ERR

run_build "${build_list_iso}"