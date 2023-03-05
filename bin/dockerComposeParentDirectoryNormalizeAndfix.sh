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


echo "Where 0:  ${TARGET_PATH}"

if [[ "${TARGET_PATH}" == "" ]]; then
  error "First argument is missing"
fi

TARGET_PATH="${PWD}/${TARGET_PATH}"

if ! [[ -d "${TARGET_PATH}" ]]; then
  error "No such directory \"${TARGET_PATH}\""
fi

echo "Where 1:  ${TARGET_PATH}"


chmod -v 750 "${TARGET_PATH}"

chmod -R a=,a+rX,u+w,g+w "${TARGET_PATH}"
chown -R toor:sg-docker "${TARGET_PATH}"

find "${TARGET_PATH}" -type d -print0 | xargs -0 -I{} chmod -v 750 {}
