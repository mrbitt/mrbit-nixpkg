#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq common-updater-scripts

set -eu -o pipefail

version="$(curl -sL "https://api.github.com/repos/Huluti/Curtail/releases?per_page=1" | jq -r ".[0].tag_name" | sed 's/^v//')"
URL="https://github.com/Huluti/Curtail/archive/refs/tags/${version}.tar.gz"
hash=$(nix --extra-experimental-features nix-command hash convert --to sri --hash-algo sha256 $(nix-prefetch-url $URL))



sed -i default.nix \
    -e "/^  version =/ s|\".*\"|\"$version\"|" \
    -e "/sha256-/ s|\".*\"|\"$hash\"|" \

nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {  }'    
#update-source-version onlyoffice-desktopeditors "$version" $hash  --ignore-same-version --ignore-same-hash
