#!/usr/bin/env bash
set -euo pipefail

export TERM="${TERM:-xterm-256color}"

#tail -f /dev/null
DATA_ROOT="${DATA_ROOT:-/data}"
WORKDIR="${WORKDIR:-$DATA_ROOT}"
PAIRS_CSV="${PAIRS_CSV:-$DATA_ROOT/pairs.csv}"
PAIR_LIST="${PAIR_LIST:-}"
PAIR_QUOTE="${PAIR_QUOTE:-}"
# Default cap 50; set MAX_PAIRS=0 for no limit.
MAX_PAIRS="${MAX_PAIRS:-50}"
BINANCE_BASE_URL="${BINANCE_BASE_URL:-}"
PAIR_STATUS="${PAIR_STATUS:-TRADING}"
git config --global --add safe.directory /data
if ! git -C "$DATA_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: DATA_ROOT ($DATA_ROOT) is not a git working tree. Clone your data repo there (host mount) or init git." >&2
  exit 1
fi

collect_symbols() {
  if [[ -n "$PAIR_LIST" ]]; then
    IFS=',' read -ra raw <<<"$PAIR_LIST"
    for s in "${raw[@]}"; do
      s="$(echo "$s" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')"
      [[ -n "$s" ]] && echo "$s"
    done
    return 0
  fi

  local pairlist_args=( -status "$PAIR_STATUS" -o "$PAIRS_CSV" )
  if [[ -n "$BINANCE_BASE_URL" ]]; then
    pairlist_args+=( -binance-base-url "$BINANCE_BASE_URL" )
  fi
  echo "Refreshing pair list -> $PAIRS_CSV" >&2
  binancepairlist "${pairlist_args[@]}"

  local line sym quote
  tail -n +2 "$PAIRS_CSV" | while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "${line//[$'\r\n']/}" ]] && continue
    IFS=',' read -r sym _ quote _ <<<"$line"
    sym="$(echo "$sym" | tr -d '\r' | tr '[:lower:]' '[:upper:]')"
    quote="$(echo "$quote" | tr -d '\r')"
    [[ -z "$sym" ]] && continue
    if [[ -n "$PAIR_QUOTE" && "$quote" != "$PAIR_QUOTE" ]]; then
      continue
    fi
    echo "$sym"
  done
}

mapfile -t symbols < <(collect_symbols | awk '!seen[$0]++')

if [[ ${#symbols[@]} -eq 0 ]]; then
  echo "ERROR: no symbols to run (check PAIR_LIST, filters, or pairs.csv)." >&2
  exit 1
fi

if [[ "$MAX_PAIRS" =~ ^[0-9]+$ ]] && (( MAX_PAIRS > 0 && ${#symbols[@]} > MAX_PAIRS )); then
  echo "Limiting to first MAX_PAIRS=$MAX_PAIRS (had ${#symbols[@]})." >&2
  symbols=( "${symbols[@]:0:$MAX_PAIRS}" )
fi

echo "Starting ${#symbols[@]} coindg screen session(s)." >&2

for sym in "${symbols[@]}"; do
  wrap="/tmp/gatherscan-${sym}.sh"
  {
    echo '#!/usr/bin/env bash'
    echo "export PAIR=$(printf '%q' "$sym")"
    echo 'exec /opt/gatherscan/run-coindg-pair.sh'
  } >"$wrap"
  chmod +x "$wrap"

  session="coindg_${sym}"
  screening start --force --name "$session" "$wrap"
done

echo "All sessions started. Holding container (Ctrl+C or docker stop to exit)." >&2
exec tail -f /dev/null
