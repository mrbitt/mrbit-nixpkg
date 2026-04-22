#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq pup common-updater-scripts

set -eu -o pipefail


DOWNLOAD_PAGE='https://www.ultimatepp.org/www$uppweb$download$en-us.html'
version=$(curl -sL "$DOWNLOAD_PAGE" | grep -oP 'downloads/upp-posix-[0-9]+\.tar\.xz'| head -n 1 | awk -F'/' '{print $NF}' | tr -dc '0-9' )

URL="https://www.ultimatepp.org/downloads/upp-posix-${version}.tar.xz"
hash=$(nix --extra-experimental-features nix-command hash convert --to sri --hash-algo sha256 $(nix-prefetch-url $URL))



sed -i default.nix \
    -e "/^  version =/ s|\".*\"|\"$version\"|" \
    -e "/sha256-/ s|\".*\"|\"$hash\"|" \

nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {  }'    


