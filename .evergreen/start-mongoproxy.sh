#!/usr/bin/env bash
set -euo pipefail

GOVERSION="${GOVERESION:-1.24}"
GOPATH="${GOPATH:-$HOME/go}"

# Detect OS
OS="$(uname -s)"

# If GOROOT is not set, determine it based on the OS and user-provided
# GOVERSION.
if [[ -z "${GOROOT:-}" ]]; then
  case "$OS" in
  Linux | Darwin)
    GOROOT="/opt/golang/go${GOVERSION}"
    ;;
  MINGW* | MSYS* | CYGWIN*)
    GOROOT="C:\\golang\\go${GOVERSION}"
    ;;
  *)
    echo "unsupported OS: $OS"
    exit 1
    ;;
  esac
fi

PATH="${GOROOT}/bin:${GOPATH}/bin:${PATH}"
export GOROOT PATH

echo "Using Go SDK at: $GOROOT (version: $GOVERSION)"

test -x "${GOROOT}/bin/go" || {
  echo "Go SDK not found at: $GOROOT"
  exit 1
}

"${GOROOT}/bin/go" install github.com/prestonvasquez/mongoproxy/cmd/mongoproxy@de97d8b0548a24b6e2f780d2222cb167e0c46390

if [[ -x "${GOPATH}/bin/mongoproxy" ]]; then
  echo "mongoproxy installed successfully to ${GOPATH}"
else
  echo "mongoproxy installation failed"
  exit 1
fi

echo "Starting mongoproxy"
exec "${GOPATH}/bin/mongoproxy"
