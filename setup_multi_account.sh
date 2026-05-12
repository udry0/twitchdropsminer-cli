#!/usr/bin/env bash
set -euo pipefail

DIRPATH=$(dirname "$(readlink -f "$0")")
ACCOUNT_ROOT="${1:-$DIRPATH/accounts}"
ACCOUNT_COUNT="${2:-2}"

if ! [[ "$ACCOUNT_COUNT" =~ ^[0-9]+$ ]]; then
  echo "ACCOUNT_COUNT harus angka." >&2
  exit 1
fi

if (( ACCOUNT_COUNT < 1 || ACCOUNT_COUNT > 20 )); then
  echo "ACCOUNT_COUNT harus di range 1..20." >&2
  exit 1
fi

mkdir -p "$ACCOUNT_ROOT"

for i in $(seq 1 "$ACCOUNT_COUNT"); do
  ACCOUNT_NAME="acc$i"
  ACCOUNT_DIR="$ACCOUNT_ROOT/$ACCOUNT_NAME"
  ENV_FILE="$ACCOUNT_DIR/.env"
  mkdir -p "$ACCOUNT_DIR"
  if [[ ! -f "$ENV_FILE" ]]; then
    cat > "$ENV_FILE" <<EOF
# Konfigurasi akun $ACCOUNT_NAME
TDM_ACCOUNT_NAME=$ACCOUNT_NAME
TDM_PRIORITY=
TDM_EXCLUDE=
TDM_PRIORITY_MODE=priority-only
TDM_CONNECTION_QUALITY=3
TDM_AVAILABLE_DROPS_CHECK=0
TDM_FORCE_DISABLE_DROPS_CHECK=1
TDM_VERBOSE=-vv
TDM_EXTRA_ARGS=
EOF
  fi
  : > "$ACCOUNT_DIR/.gitkeep"
  echo "Siap: $ACCOUNT_DIR"
done

echo
echo "Selesai. Default bikin $ACCOUNT_COUNT akun di: $ACCOUNT_ROOT"
echo "Edit file .env per akun, lalu login per akun dengan:"
echo "  TDM_ACCOUNT_NAME=acc1 $DIRPATH/run_headless.sh"
