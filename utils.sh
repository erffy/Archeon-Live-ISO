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

check_root() {
    (( EUID == 0 )) && return 0

    local helpers=("sudo-rs" "sudo" "doas" "su")
    local cmd

    for cmd in "${helpers[@]}"; do
      command -v $cmd &>/dev/null && exec $cmd $0 $@
    done

    echo "This script requires root privileges but no helper found."
    exit 1
}

check_requirements() {
    local packages=("archiso" "squashfs-tools")
    local helpers=("yay" "paru" "trizen")

    for package in "${packages[@]}"; do
        if pacman -Qi $package &>/dev/null; then
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

create_checksums() {
  local file="$1"

  log_note "creating checksums for [$file]"
  
  sha256sum $file > $file.sha256
  md5sum $file > $file.md5
}

buildiso() {
  log_info "Profile: [$BUILD_PROFILE]"

  local sddm_path="/usr/lib/systemd/system/sddm.service"
  local sddm_target="${BASE_DIR}/archeoniso/airootfs/etc/systemd/system/display-manager.service"

  rm -f $sddm_path
  [[ "$BUILD_PROFILE" = "desktop" ]] && ln -sf $sddm_path $sddm_target || fatal_error "Unknown profile: [$BUILD_PROFILE]"

  log_success "Prepare [Build: ${BUILD_DIR}, Dist: ${DIST_DIR}]"

  [[ "$VERBOSE" = true ]] && {
    log_note "Making mkarchiso verbose"
    sed -i 's/quiet="y"/quiet="n"/g' /usr/bin/mkarchiso
  }

  [[ "$CLEAN_BUILD" = true ]] && {
    log_note "Deleting the build folder"
    [[ -d $BUILD_DIR ]] && rm -rf $BUILD_DIR
  }

  log_note "Copying Archeon folder to build dir"
  mkdir -p $BUILD_DIR
  cp -r ${BASE_DIR}/archeoniso ${BUILD_DIR}/archeoniso

  log_success "Start Build"

  local _is_hack_applied="$(grep -q 'archlinux-keyring-wkd-sync.timer' /usr/bin/mkarchiso; echo $?)"
  if [ $_is_hack_applied -ne 0 ]; then
    log_success "Patching mkarchiso with disabled arch keyrings timer..."
    sed 's/_run_once _make_customize_airootfs/_run_once _make_customize_airootfs\n\trm -f "${pacstrap_dir}\/usr\/lib\/systemd\/system\/timers.target.wants\/archlinux-keyring-wkd-sync.timer"\n/' -i /usr/bin/mkarchiso
  fi

  [[ -d $DIST_DIR/$BUILD_PROFILE ]] || mkdir -p $DIST_DIR/$BUILD_PROFILE

  cd $BUILD_DIR/archeoniso

  mkarchiso -v -w $BUILD_DIR -o $DIST_DIR/$BUILD_PROFILE $BUILD_DIR/archeoniso
  chown -R $USER:$USER $DIST_DIR

  cp $BUILD_DIR/iso/arch/pkglist* $DIST_DIR/$BUILD_PROFILE/packages.txt

  log_success "Done [Build ISO]"

  cd $DIST_DIR/$BUILD_PROFILE
  create_checksums *.iso
}
