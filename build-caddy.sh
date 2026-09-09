#!/usr/bin/env bash

# Build the pinned Linux Caddy artifact used by the proxy role.
# The output path is required so the script never writes a binary into Git.

set -euo pipefail

if [[ $# -ne 1 ]]; then
  printf 'usage: %s OUTPUT_PATH\n' "$0" >&2
  exit 2
fi

output=$1
caddy_version='2.11.4'
cloudflare_version='0.2.4'
xcaddy_version='0.4.7'
required_go_version='go1.26.3'

if ! command -v go >/dev/null 2>&1; then
  echo 'Go is required' >&2
  exit 1
fi
if [[ "$(go version)" != *"${required_go_version}"* ]]; then
  printf 'required Go version: %s; found: %s\n' "$required_go_version" "$(go version)" >&2
  exit 1
fi

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
mkdir -p "$(dirname "$output")"

gobin="$workdir/bin"
GOBIN="$gobin" go install "github.com/caddyserver/xcaddy/cmd/xcaddy@v${xcaddy_version}"

export GOOS=linux
export GOARCH=amd64
export GOAMD64=v1
export XCADDY_GO_BUILD_FLAGS="-ldflags '-w -s' -trimpath -tags nobadger"
"$gobin/xcaddy" build "v${caddy_version}" \
  --with "github.com/caddy-dns/cloudflare@v${cloudflare_version}" \
  --output "$output"

build_info=$(go version -m "$output")
grep -E "github.com/caddyserver/caddy/v2[[:space:]]+v${caddy_version}" <<<"$build_info" >/dev/null
grep -E "github.com/caddy-dns/cloudflare[[:space:]]+v${cloudflare_version}" <<<"$build_info" >/dev/null
grep -F $'GOOS=linux' <<<"$build_info" >/dev/null
grep -F $'GOARCH=amd64' <<<"$build_info" >/dev/null

if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$output"
else
  shasum -a 256 "$output"
fi
printf 'artifact verified: Caddy %s with Cloudflare DNS module %s\n' \
  "$caddy_version" "$cloudflare_version"
