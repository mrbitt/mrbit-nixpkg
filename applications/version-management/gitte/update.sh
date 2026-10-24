##!/usr/bin/env bash

FILE="default.nix"
REPO_URL="https://codeberg.org"

echo "🔍 Richiesta download e calcolo hash nativo da Codeberg..."

# Usiamo nix-prefetch-url pulito per gli archivi scompattati
HEX_HASH=$(nix-prefetch-url --unpack "$URL" 2>/dev/null)

if [ -z "$HEX_HASH" ]; then
    echo "❌ Errore: Impossibile scaricare l'archivio. Verifica la rete o l'URL."
    exit 1
fi

# Converte l'hash esadecimale in formato SRI
SRC_HASH=$(nix hash convert --hash-algo sha256 --to sri "$HEX_HASH")
echo "✅ Hash sorgente trovato: $SRC_HASH"

# Sostituisce l'hash nel file di destinazione
sed -i "s|hash = \"sha256-.*\";|hash = \"$SRC_HASH\";|g" "$FILE"

echo "⏳ Reset del cargoHash..."
sed -i 's|cargoHash = "sha256-.*";|cargoHash = "";|g' "$FILE"

echo "⚙️  Esecuzione build simulata per estrarre il cargoHash reale..."
# Avviamo la build catturando l'errore standard dove Nix descrive lo sbilanciamento dell'hash di Cargo
BUILD_LOG=$(nix build .# --no-link 2>&1)

# Estrae l'hash effettivo generato (valore "got:") o qualunque stringa sha256 valida dall'errore
CARGO_HASH=$(echo "$BUILD_LOG" | grep -A 2 "specified:" | grep "got:" | awk '{print $2}')

if [ -z "$CARGO_HASH" ]; then
    CARGO_HASH=$(echo "$BUILD_LOG" | grep -oE 'sha256-[A-Za-z0-9+/=]{44}' | head -n 1)
fi

if [ -n "$CARGO_HASH" ] && [ "$CARGO_HASH" != "$SRC_HASH" ]; then
    echo "✅ cargoHash trovato: $CARGO_HASH"
    sed -i "s|cargoHash = \"\";|cargoHash = \"$CARGO_HASH\";|g" "$FILE"
    echo "🚀 Configurazione completata con successo!"
else
    echo "⚠️  Impossibile estrarre automaticamente il cargoHash."
    echo "Esegui manualmente 'nix build .#' e copia il valore 'got:' dentro cargoHash nel file $FILE."
fi
