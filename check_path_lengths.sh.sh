#!/bin/bash

# -----------------------------------------------------------------------------
# Script per macOS: verifica la lunghezza dei percorsi dei file
#
# USO:
#   ./check_path_lengths.sh /percorso/da/scansionare
#
# FUNZIONALITÀ:
# - Scansiona ricorsivamente tutti i file sotto il path fornito.
# - Verifica se il percorso supera:
#     * 1024 caratteri (macOS)
#     * 260 caratteri (Windows)
# - Se il path iniziale è un link simbolico, sostituisce il path reale nei risultati
#   con il nome del link per chiarezza.
# - Stampa i file eccedenti con prefisso MAC-> o WIN->
# - Mostra il conteggio totale dei file eccedenti.
# -----------------------------------------------------------------------------

MAX_PATH_MAC=1024
MAX_PATH_WIN=260

if [ -z "$1" ]; then
  echo "Uso: $0 /percorso/da/scansionare"
  exit 1
fi

INPUT_PATH="$1"
if [ ! -e "$INPUT_PATH" ]; then
  echo "Errore: '$INPUT_PATH' non esiste."
  exit 2
fi

if [ -L "$INPUT_PATH" ]; then
  IS_SYMLINK=1
  REAL_PATH=$(readlink "$INPUT_PATH")
  # Rendi il path assoluto se necessario
  [[ "$REAL_PATH" != /* ]] && REAL_PATH="$(cd "$(dirname "$INPUT_PATH")" && pwd)/$REAL_PATH"
else
  IS_SYMLINK=0
  REAL_PATH="$INPUT_PATH"
fi

count_mac=0
count_win=0

while read -r filepath; do
  # Genera il path finale da stampare
  if [ "$IS_SYMLINK" -eq 1 ]; then
    # Sostituisci il prefisso del path reale con il path simbolico
    display_path="${filepath/$REAL_PATH/$INPUT_PATH}"
  else
    display_path="$filepath"
  fi

  path_length=${#filepath}
  if [ "$path_length" -gt "$MAX_PATH_MAC" ]; then
    echo "MAC-> [$path_length] $display_path"
    ((count_mac++))
  fi
  if [ "$path_length" -gt "$MAX_PATH_WIN" ]; then
    echo "WIN-> [$path_length] $display_path"
    ((count_win++))
  fi
done < <(find "$REAL_PATH" -type f)

echo
echo "---- RIEPILOGO ----"
echo "File oltre limite macOS : $count_mac"
echo "File oltre limite Windows: $count_win"