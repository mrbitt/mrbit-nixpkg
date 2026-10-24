#!/usr/bin/env bash

# 1. Estrae l'ultimo tag dalla pagina HTML dei tags
LATEST_TAG=$(curl -sL https://github.com/AkiZip/AkiZip/tags | grep -oP '(?<=/tags/)v?[0-9]+\.[0-9]+\.[0-9]+' | head -n1)

# Rimuove la 'v' per la variabile version
#VERSION=${LATEST_TAG#v}
VERSION=${LATEST_TAG#}

if [ -z "$VERSION" ]; then
    echo "Errore: Non riesco a trovare la versione nella pagina HTML."
    exit 1
fi

echo "Versione trovata: $VERSION (Tag: $LATEST_TAG)"

# 2. Scarica e calcola l'hash SRI (sha256-...)
echo "Calcolo dell'hash in corso..."
RAW_HASH=$(nix-prefetch-url --unpack "https://github.com/AkiZip/AkiZip/archive/refs/tags/$VERSION.tar.gz")
SRI_HASH=$(nix hash convert --hash-algo sha256 --to sri "$RAW_HASH")

# 3. Aggiorna il file default.nix
sed -i "s/version = \".*\";/version = \"$VERSION\";/" default.nix
sed -i "s/hash = \".*\";/hash = \"$SRI_HASH\";/" default.nix

echo "---------------------------------------"
echo "Aggiornamento completato con successo!"
echo "Versione: $VERSION"
echo "Hash:     $SRI_HASH"
nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {  }
