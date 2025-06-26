#!/usr/bin/env bash
set -ex pipefail

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

"${GOROOT}/bin/go" install github.com/prestonvasquez/mongoproxy/cmd/mongoproxy@aed2d6d38a5365a703cc533bcc1da588d7b7f730

if [[ -x "${GOPATH}/bin/mongoproxy" ]]; then
  echo "mongoproxy installed successfully to ${GOPATH}"
else
  echo "mongoproxy installation failed"
  exit 1
fi

echo "Starting mongoproxy at ${MONGODB_URI}..."
#exec "${GOPATH}/bin/mongoproxy"

echo "Environment variables:"
cat .test.env

if [ -n "$MONGODB_URI" ]; then
  echo "MONGO_GO_DRIVER_CA_FILE: ${MONGO_GO_DRIVER_CA_FILE}"
  exec "${GOPATH}/bin/mongoproxy" --target-uri "$MONGODB_URI"
else
  echo "Error: MONGODB_URI environment variable is not set." >&2
  exit 1
fi
