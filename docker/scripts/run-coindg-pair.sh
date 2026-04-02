#!/usr/bin/env bash
set -euo pipefail

# Invoked from GNU screen; PAIR must be set (wrapper sets export PAIR=...).

PAIR="${PAIR:?PAIR is required}"
WORKDIR="${WORKDIR:-/data}"
REPODIR="${REPODIR:-}"

duration="${COINDG_DURATION:-0}"
http_timeout="${HTTP_TIMEOUT:-10s}"
commit_every="${GIT_COMMIT_EVERY:-10m}"
commit_prefix="${GIT_COMMIT_PREFIX:-data:}"
remote="${GIT_REMOTE:-origin}"
branch="${GIT_BRANCH:-}"
binance_base="${BINANCE_BASE_URL:-}"

args=(
  --pairs "$PAIR"
  --workdir "$WORKDIR"
  --duration "$duration"
  --http-timeout "$http_timeout"
  --git-commit-every "$commit_every"
  --git-commit-prefix "$commit_prefix"
  --git-remote "$remote"
)

if [[ -n "$REPODIR" ]]; then
  args+=(--repodir "$REPODIR")
fi
if [[ -n "$branch" ]]; then
  args+=(--git-branch "$branch")
fi
if [[ -n "$binance_base" ]]; then
  args+=(--binance-base-url "$binance_base")
fi

if [[ "${GIT_AUTO:-1}" != "0" && "${GIT_AUTO:-1}" != "false" ]]; then
  args+=(--git-auto)
fi

exec coindg "${args[@]}"
