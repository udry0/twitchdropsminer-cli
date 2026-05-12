#!/usr/bin/env bash
set -euo pipefail

DIRPATH=$(dirname "$(readlink -f "$0")")
VENV_PYTHON="$DIRPATH/env/bin/python"
SYSTEM_PYTHON="${PYTHON:-python3}"

if [[ -x "$VENV_PYTHON" ]]; then
  PYTHON_BIN="$VENV_PYTHON"
else
  PYTHON_BIN="$SYSTEM_PYTHON"
fi

ACCOUNT_NAME="${TDM_ACCOUNT_NAME:-default}"
ACCOUNT_ROOT="${TDM_ACCOUNT_ROOT:-$DIRPATH/accounts}"
ACCOUNT_DIR="${TDM_ACCOUNT_DIR:-$ACCOUNT_ROOT/$ACCOUNT_NAME}"
ENV_FILE="${TDM_ENV_FILE:-$ACCOUNT_DIR/.env}"

mkdir -p "$ACCOUNT_DIR"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  set -a; source "$ENV_FILE"; set +a
fi

: "${TDM_PRIORITY:=}"
: "${TDM_EXCLUDE:=}"
: "${TDM_PRIORITY_MODE:=}"
: "${TDM_CONNECTION_QUALITY:=}"
: "${TDM_EXTRA_ARGS:=}"

ARGS=("$DIRPATH/main.py" "--cli" "--log")

if [[ -n "$TDM_PRIORITY" ]]; then
  ARGS+=("--priority" "$TDM_PRIORITY")
fi
if [[ -n "$TDM_EXCLUDE" ]]; then
  ARGS+=("--exclude" "$TDM_EXCLUDE")
fi
if [[ -n "$TDM_PRIORITY_MODE" ]]; then
  ARGS+=("--priority-mode" "$TDM_PRIORITY_MODE")
fi
if [[ -n "$TDM_CONNECTION_QUALITY" ]]; then
  ARGS+=("--connection-quality" "$TDM_CONNECTION_QUALITY")
fi
if [[ "${TDM_AVAILABLE_DROPS_CHECK:-0}" == "1" ]]; then
  ARGS+=("--available-drops-check")
fi
if [[ "${TDM_AVAILABLE_DROPS_CHECK:-0}" == "0" && -n "${TDM_FORCE_DISABLE_DROPS_CHECK:-}" ]]; then
  ARGS+=("--no-available-drops-check")
fi
if [[ -n "${TDM_VERBOSE:-}" ]]; then
  ARGS+=("${TDM_VERBOSE}")
fi
if [[ -n "$TDM_EXTRA_ARGS" ]]; then
  # shellcheck disable=SC2206
  EXTRA_ARGS=( $TDM_EXTRA_ARGS )
  ARGS+=("${EXTRA_ARGS[@]}")
fi

cd "$ACCOUNT_DIR"
exec "$PYTHON_BIN" "${ARGS[@]}"
