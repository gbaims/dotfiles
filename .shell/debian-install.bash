#!/usr/bin/env bash

_dir="`pwd`"
_packages=(
    git

    xorg
    xserver-xorg-video-all

    bspwm
    xsettingsd
    sxhkd
    picom

    kitty
)

#
_echo() {
    echo -e "\n$1\n"
    if [[ -n "$2" ]]; then
        exit $2
    fi
}

## Perform system upgrade
upgrade_system() {
    sudo apt-get update --yes
    if [[ "$?" != '0' ]]; then
        _echo "[!] Failed to retrieve new lists of packages" 1  
    fi
    sudo apt-get upgrade --yes
    if [[ "$?" != '0' ]]; then
        _echo "[!] Failed to perform upgrade" 1
    fi
}

install_pkgs() {
    _echo "[*] Installing required packages..."
    for _pkg in "${_packages[@]}"; do
        _echo "[+] Installing package : $_pkg"
	sudo apt-get install "$_pkg" --yes
	if [[ "$?" != '0' ]]; then
            _echo "[!] Failed to install package: $_pkg"
            _failed_to_install+=("$_pkg")
	fi
    done

    # List failed packages
    echo
    for _failed in "${_failed_to_install[@]}"; do
        _echo "[!] Failed to install package: ${_failed}"
    done
    if [[ -n "${_failed_to_install}" ]]; then
        _echo "[!] Install these packages manually to continue, exiting..." 1
    fi
}

install_starship() {
    _echo "[*] Installing starship prompt"
    curl -sS https://starship.rs/install.sh  | sh -s -- --yes
    if [[ "$?" != '0' ]]; then
        _echo "[!] Failed to install Starship prompt" 1
    fi
}

upgrade_system
install_pkgs
install_starship
