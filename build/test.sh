#!/bin/sh

set -o errexit
set -o nounset
set -o pipefail

TARGETS=$(for d in "$@"; do echo ./$d/...; done)

echo "Running tests:"
export CGO_ENABLED=0
go test -i -installsuffix "static" ${TARGETS}
go test -installsuffix "static" ${TARGETS}
echo
