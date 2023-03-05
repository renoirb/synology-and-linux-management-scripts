#!/usr/bin/env bash

##
## When organizing yearly file archives, I like to have one
## folder per year, with the same directory structure for the
## same type of files.
##
## UNFINISHED
## Started to be used for year 2023, and forgot about it.
## Keeping it here for now for next year.
##
## Originally written: 2023-01-04
## Time Spent:
##   2023-01-04: 1h
##
## Renoir Boulanger <contribs@renoirboulanger.com>
##

set -e
set -u
set -o pipefail
shopt -s nullglob


function error { printf "Error: %s \n " "$@" >&2; exit 1; }

TARGET_PATH="${1:-""}"
TARGET_YEAR=${2:-$(date +'%Y')}

echo "Where 0:  ${TARGET_PATH}"

if [[ "${TARGET_PATH}" == "" ]]; then
  TARGET_PATH="${PWD}"
  echo "Case when ''"
fi

if [[ ${TARGET_PATH} =~ ^\. ]]; then
  echo "Case when './'"
  STRIPPING_PATH=$(echo "${TARGET_PATH}" | sed -E 's#^\./?##g' )
  TARGET_PATH="${PWD}"
  echo "STRIPPING_PATH:			${STRIPPING_PATH}"
  TARGET_PATH+="/${STRIPPING_PATH}"
  if ! [[ "${STRIPPING_PATH}" == "" ]]; then
    echo "TARGET_PATH:			${TARGET_PATH}"
    #mkdir -p "${TARGET_PATH}"
  fi
fi

if ! [[ -d "${TARGET_PATH}" ]]; then
  error "Invalid parent path ${TARGET_PATH}"
fi

if ! [[ "${TARGET_YEAR}" =~ ^[1-2][0-9][0-9][0-9]$ ]]; then
  error "Invalid year ${TARGET_YEAR}"
fi

echo "Where:		${TARGET_PATH}"
echo "Year:			${TARGET_YEAR}"

echo "OK"
