# Caddy custom builds

Reproducible Linux amd64 Caddy binaries with explicitly pinned DNS plugins.

## Published build

Release `caddy-v2.11.4-cloudflare-v0.2.4` contains:

- Caddy `v2.11.4`;
- `github.com/caddy-dns/cloudflare` `v0.2.4`;
- xcaddy `v0.4.7`;
- Go `1.26.3`;
- Linux amd64 (`GOAMD64=v1`);
- build flags `-ldflags '-w -s' -trimpath -tags nobadger`.

The expected SHA-256 for `caddy-linux-amd64` is:

```text
8cee4dd190bb24865c7e2e5b12ec93941fd3cf2eb2e9b7c7a6aa84121a8f67dd
```

Always verify the checksum before installation. Release tags and checksums are
versioned, but GitHub release assets can be administratively replaced; checksum
verification is therefore mandatory.

## Build

Install or select Go `1.26.3`, then run:

```bash
GOTOOLCHAIN=go1.26.3 ./build-caddy.sh ./caddy-linux-amd64
```

Build a second time and compare both files to verify reproducibility in the
same toolchain environment.
