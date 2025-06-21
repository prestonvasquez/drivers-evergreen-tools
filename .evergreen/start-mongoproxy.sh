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

"${GOROOT}/bin/go" install github.com/prestonvasquez/mongoproxy/cmd/mongoproxy@881f897876eef81e9ae64e22f1a1a1e0203efdd4

if [[ -x "${GOPATH}/bin/mongoproxy" ]]; then
  echo "mongoproxy installed successfully to ${GOPATH}"
else
  echo "mongoproxy installation failed"
  exit 1
fi

# Ensure the target URI is set
: "${MONGODB_URI?Please set the MONGODB_URI environment variable}"

echo "Starting mongoproxy with URI: $MONGODB_URI"
exec "${GOPATH}/bin/mongoproxy" --target-uri "$MONGODB_URI"
