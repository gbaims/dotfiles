#!/usr/bin/env bash

_dir="`pwd`"
_packages=(
    build-essential
    git
    ripgrep

    xorg
    xserver-xorg-video-all

    bspwm
    xsettingsd
    sxhkd
    picom

    kitty
)
_unstable_packages=(
    neovim
)

#
_echo() {
    echo -e "\n$1\n"
    if [[ -n "$2" ]]; then
        exit $2
    fi
}

config_repositories() {
    _echo "[*] Adding 'testing' and 'unstable' apt sources"
    sudo tee "/etc/apt/sources.list.d/20-newer-packages.list" > /dev/null <<- EOF
		deb http://deb.debian.org/debian testing main contrib
		deb http://deb.debian.org/debian unstable main contrib
	EOF

    sudo tee "/etc/apt/preferences.d/20-newer-packages" > /dev/null <<- EOF
		Package: *
		Pin: release a=testing
		Pin-Priority: -10

		Package: *
		Pin: release a=unstable
		Pin-Priority: -20
	EOF
}

## Perform system upgrade
upgrade_system() {
    _echo "[*] Performing system upgrade"
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

install_unstable_pkgs() {
    _echo "[*] Installing required unstable packages..."
    for _pkg in "${_unstable_packages[@]}"; do
        _echo "[+] Installing package : $_pkg"
        sudo apt-get install "$_pkg"/unstable --yes
        if [[ "$?" != '0' ]]; then
            _echo "[!] Failed to install package: $_pkg"
            _failed_to_install+=("$_pkg")
        fi
    done

    # List failed packages
    echo
    for _failed in "${_failed_to_install[@]}"; do
        _echo "[!] Failed to install unstable package: ${_failed}"
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

config_repositories
upgrade_system
install_pkgs
install_unstable_pkgs
install_starship
