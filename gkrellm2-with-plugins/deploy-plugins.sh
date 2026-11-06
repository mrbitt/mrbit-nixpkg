#!/usr/bin/env bash

TARGET_DIR="$HOME/.gkrellm2/plugins"
echo "==========================================="
echo " Preparazione Installazione Plugin GKrellM"
echo " Destinazione: $TARGET_DIR"
echo "==========================================="

mkdir -p "$TARGET_DIR"

PLUGINS=(
  "gkleds" "gkrellAclock" "gkrellm-alltraxclock" "gkrellm-countdown"
  "gkrellm-hdplop" "gkrellmoon" "gkrellm-thinkbat" "gkrellm-timers"
  "gkrellm-volume" "gkrellm-xkb" "gkrellshoot"
)

for PLUGIN in "${PLUGINS[@]}"; do
  echo "🔨 Compilazione pacchetto: $PLUGIN..."
  
  # Forziamo il puntamento esplicito a default.nix
  OUT_PATH=$(nix-build default.nix -A "$PLUGIN" --no-out-link 2>&1)
  STATUS=$?
  
  if [ $STATUS -ne 0 ]; then
    echo "❌ Errore: Compilazione fallita per $PLUGIN."
    echo "--- Estratto Log di Errore ---"
    echo "$OUT_PATH" | tail -n 15
    echo "-------------------------"
    continue
  fi

  OUT_PATH=$(echo "$OUT_PATH" | tail -n 1)

  if [ -d "$OUT_PATH/gkrellm2/plugins" ]; then
    for SO_FILE in "$OUT_PATH/gkrellm2/plugins"/*.so; do
      if [ -f "$SO_FILE" ]; then
        FILENAME=$(basename "$SO_FILE")
        echo "   -> Copia di $FILENAME nel profilo utente..."
        rm -f "$TARGET_DIR/$FILENAME"
        cp "$SO_FILE" "$TARGET_DIR/$FILENAME"
        chmod u+w "$TARGET_DIR/$FILENAME"
      fi
    done
  else
    echo "⚠️ Avviso: Nessun file .so trovato in $OUT_PATH"
  fi
done

echo "==========================================="
echo " 🎉 Procedura Completata!"
echo "==========================================="

