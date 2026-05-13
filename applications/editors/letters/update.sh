#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq pup common-updater-scripts

set -eu -o pipefail

# Configurazione
VERSION="0.2.0"
URL="https://codeberg.org/eyekay/letters/archive/${VERSION}.tar.gz"
FILE="letters.nix"

echo "🔍 Recupero l'hash per la versione $VERSION..."

# Calcola l'hash usando nix-prefetch-url
NEW_HASH=$(nix-prefetch-url --unpack "$URL" 2>/dev/null)

if [ -z "$NEW_HASH" ]; then
    echo "❌ Errore: Impossibile recuperare l'hash."
    exit 1
fi

# Converte l'hash nel formato SRI (sha256-...) richiesto dalle versioni recenti di Nix
SRI_HASH=$(nix hash convert --hash-algo sha256 --to sri "$NEW_HASH")

echo "✅ Nuovo hash trovato: $SRI_HASH"

# Sostituisce l'hash nel file .nix (cerca la riga con sha256 =)
sed -i "s|sha256 = \".*\";|sha256 = \"$SRI_HASH\";|" "$FILE"

echo "🚀 File $FILE aggiornato con successo!"


nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {  }'    


