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

if [ -z "$MONGODB_URI" ]; then
  echo "Error: MONGODB_URI environment variable is not set." >&2
  exit 1
fi

echo "Starting mongoproxy at ${MONGODB_URI}..."

# Build the proxy command
CMD=("${GOPATH}/bin/mongoproxy" "--target-uri" "$MONGODB_URI")

# If both cert and key are present, turn on TLS
if [ -n "${SSL:-}" ]; then
  CMD+=(
    "--ca-file" "$DRIVERS_TOOLS/.evergreen/x509gen/ca.pem"
    "--key-file" "$DRIVERS_TOOLS/.evergreen/x509gen/client.pem"
  )
fi
