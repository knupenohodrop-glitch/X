### Docker image + compose for Gathering and publishing

- Docker image building storage and composer
- It takes ( binaries for amd linux) to build Docker image that generates binance pairs.csv + makes for each pair seperated coinDataGatherer in single container - and stores them each in screen using ScreeningGo utility . coinDataGatherer storaes data in workdir + pushes it to repo
- docker-compose must define path of workdir , define local ssh keys for git repository access

### Layout

| Path | Purpose |
|------|---------|
| [Dockerfile](Dockerfile) | Debian slim + `screen`, `bash`, `git`, OpenSSH client; copies `dist/` binaries and `scripts/` |
| [docker-compose.yml](docker-compose.yml) | Binds host workdir to `/data`, read-only SSH dir to `/root/.ssh` |
| [scripts/docker-entrypoint.sh](scripts/docker-entrypoint.sh) | Refreshes `pairs.csv` (unless `PAIR_LIST` is set), starts one GNU screen per pair via `screening start --force` |
| [scripts/run-coindg-pair.sh](scripts/run-coindg-pair.sh) | Runs `coindg` for a single `PAIR` |

### Build linux/amd64 binaries

From each repo (same machine as `GOOS=linux GOARCH=amd64` or `build.sh` where applicable):

- **BinancePairList**: `go build -o binancepairlist ./cmd/binancepairlist`
- **coinDataGatherer**: `go build -o coindg ./cmd/coindg`
- **screeningGo**: build `screening-linux-amd64`, then rename to `screening`

Place the three files under [dist/](dist/README.txt) (see `dist/README.txt`).

### Image build

```bash
cd gatherScanPush
docker compose build
```

### Run with compose

1. Copy `.env.example` to `.env` and set `WORKDIR_HOST` (git repo root on the host) and `SSH_DIR` (SSH keys + `known_hosts` for push).
2. Ensure the host directory is a git clone with `origin` set for `git push`.
3. `docker compose up -d` (or `up` for foreground logs).

Environment variables are read from `.env` via `env_file` (see `.env.example`). Important ones:

| Variable | Meaning |
|----------|---------|
| `PAIR_LIST` | If set (comma-separated), skip Binance fetch and use this list |
| `PAIR_QUOTE` | e.g. `USDT` — keep only CSV rows with that quote asset |
| `MAX_PAIRS` | Default `50`; cap screen sessions. `0` = no limit |
| `GIT_AUTO` | `1` / `0` — enable `coindg --git-auto` |
| `GIT_COMMIT_EVERY`, `GIT_REMOTE`, `GIT_BRANCH` | Passed to `coindg` |
| `COINDG_DURATION` | `0` = run until stopped |
| `BINANCE_BASE_URL` | Optional; passed to `binancepairlist` and `coindg` |

The container keeps running after starting screens (`tail -f /dev/null`); use `docker compose stop` to stop.

### SSH / Git

- Mount SSH keys read-only at `/root/.ssh` (see compose). Keys must be readable by the container user; include `known_hosts` for the git host.
- For SSH agent forwarding on Linux, you can mount a socket and set `SSH_AUTH_SOCK` in `.env` instead of mounting keys (not covered in compose by default).

### Optional

- `tty: true` is set in compose for compatibility with some `screen` setups.
- If `screen` misbehaves, try `docker compose run` with `-it` or attach a TTY.
