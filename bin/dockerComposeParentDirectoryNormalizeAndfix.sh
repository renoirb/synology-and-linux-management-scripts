#!/usr/bin/env bash

##
## When we just want Docker Compose service in a folder
## Keep folder ownership and structure the same
##
## Ideal for small machines, like a RockPro64 or Pine64, or a NAS.
##
## Originally written on 2023-02-29
## Time Spent:
##   2023-03-04: 1h
##
## Renoir Boulanger <contribs@renoirboulanger.com>
##


set -e
set -u
set -o pipefail
shopt -s nullglob

TARGET_PATH="${1:-""}"


function error { printf "Error: %s \n " "$@" >&2; exit 1; }

# Generate password
# pwgen -N 1 -s 96

echo "Where 0:  ${TARGET_PATH}"

if [[ "${TARGET_PATH}" == "" ]]; then
  error "First argument is missing"
fi

TARGET_PATH="${PWD}/${TARGET_PATH}"

if ! [[ -d "${TARGET_PATH}" ]]; then
  error "No such directory \"${TARGET_PATH}\""
fi

echo "Where 1:  ${TARGET_PATH}"


TARGET_PUID=$(sed -n -e '0,/PUID/s/.*\= *//p' "${TARGET_PATH}env_file.txt" | tail -n 1)
TARGET_UID=$(sed -n -e '0,/UID/s/.*\= *//p' "${TARGET_PATH}env_file.txt" | tail -n 1)
TARGET_PGID=$(sed -n -e '0,/PGID/s/.*\= *//p' "${TARGET_PATH}env_file.txt" | tail -n 1)
TARGET_GID=$(sed -n -e '0,/GID/s/.*\= *//p' "${TARGET_PATH}env_file.txt" | tail -n 1)

echo "   PUID:  '${TARGET_PUID}'"
echo "    UID:  '${TARGET_UID}'"
echo "   PGID:  '${TARGET_PGID}'"
echo "    GID:  '${TARGET_GID}'"
#exit 0

chmod -v 750 "${TARGET_PATH}"

chmod -R a=,a+rX,u+w,g+w "${TARGET_PATH}"
chown -R toor:65540 "${TARGET_PATH}"

find "${TARGET_PATH}" -type d -print0 | xargs -0 -I{} chmod -v 750 {}
