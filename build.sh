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

BASE_DIR="$(pwd)"
BASE_NAME="$(basename $BASE_DIR)"

BUILD_DIR="$BASE_DIR/build"
DIST_DIR="$BASE_DIR/dist"

# Default Settings
CLEAN_BUILD=true
BUILD_PROFILE="desktop"
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--no-clean)
            CLEAN_BUILD=false
            shift
            ;;
        -p|--profile)
            if [[ -n $2 && $2 != -* ]]; then
                BUILD_PROFILE="$2"
                shift 2
            else
                echo "Error: --profile requires an argument"
                usage 1
            fi
            ;;
        -v|--verbose)
            VERBOSE=true
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

source $BASE_DIR/log.sh
source $BASE_DIR/utils.sh

check_root $@

check_requirements

buildiso