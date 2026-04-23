#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq common-updater-scripts

set -eu -o pipefail

#page="$(curl -s https://www.ultimatepp.org/downloads/)"
version="$(curl -sIL https://sourceforge.net/projects/converseen/files/latest/download | grep -oE 'Converseen-[0-9.]+' | head -n1 | cut -d'-' -f2,2)"
URL="https://sourceforge.net/projects/converseen/files/Converseen/Converseen%200.15/conversee-${version}.tar.bz2"
hash=$(nix --extra-experimental-features nix-command hash convert --to sri --hash-algo sha256 $(nix-prefetch-url $URL))



sed -i default.nix \
    -e "/^  version =/ s|\".*\"|\"$version\"|" \
    -e "/sha256-/ s|\".*\"|\"$hash\"|" \

nix-build -E 'with import <nixpkgs> {}; libsForQt5.callPackage ./default.nix {  }'    
#update-source-version onlyoffice-desktopeditors "$version" $hash  --ignore-same-version --ignore-same-hash

