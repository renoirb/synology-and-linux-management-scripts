#!/usr/bin/env bash

##
## When organizing photos for storage and scanning older photos
##
## Older photos wouldn't have the proper file date, and proper
## metadata.
##
## This script helps creating folder structure with date matching
## the folder name's written date.
##
## UNFINISHED
## This is part of other scripts to add Exif metadata.
## Just adding this file in this repository for now.
##
## Originally written: 2022-11-19
## See: https://gist.github.com/renoirb/7fa6d4cf54b769fdac002a2cef56bbdb
## Time Spent:
##   2023-03-04: 1h
##
## Renoir Boulanger <contribs@renoirboulanger.com>
##

set -e
set -u
#set -x
set -o pipefail
shopt -s nullglob


display_usage() {
    echo "Adjust file/directory creation date based on name or argument."
    echo -e "\nUsage:\n  ${0} <PATH> [<TIMESTAMP>]\n"
    echo -e "\n"
    echo -e "Examples:"
    echo -e "  ${0} IMG_20221010_000000.HEIC"
    echo -e "\n"
}

function error { printf "Error: %s \n " "$@" >&2; exit 1; }

charpos() { pos=$1; shift; echo "$@" |sed 's/^.\{'$pos'\}\(.\).*$/\1/'; }


# Bookmarks
#
##########################################



TARGET_FILE=${1:-""}

if [[ ${TARGET_FILE} == "" ]]; then
    display_usage
    exit
fi




##########################################






TARGET_FILE_MODE=""
if [[ ! -f "${TARGET_FILE}" ]]; then
  if [[ ! -d "${TARGET_FILE}" ]]; then
    error "Not a file, nor a directory"
  else
    TARGET_FILE_MODE="dir"
  fi
else
  TARGET_FILE_MODE="file"
fi




## Not possible on macOS
#TARGET_FILE_CURRENT_DATE=$(date +%Y%m%d%H%M.%S -r $TARGET_FILE)

TARGET_DATE=""
TARGET_DATE_PATTERN=""

TARGET_DATE_YEAR=""
TARGET_DATE_MONTH=""
TARGET_DATE_DAY=""

##
## RegEx in Bash
## - https://www.regular-expressions.info/charclass.html
##

RE_MUST_BE_DATE_FORMAT='[1-2]0[0-9][0-9]-[0-1][0-9]-[0-9][0-9]'


echo "File:         '${TARGET_FILE}'"
echo "Mode:         '${TARGET_FILE_MODE}'"


##
## When has full date with or without a dash somewhere in the file/directory name
## - 20220101
## - 2022-01-01
##
## https://regex101.com/r/dX8cN8/1
RE_DATE_FORMAT_ALPHA='[1-2]0[0-9][0-9]-?[0-1][0-9]-?[0-9][0-9]'

##
## When directory name starts by numbers reminding of a date.
## - '202201 Some directory name'
## - '2022-01 Some directory name'
##
## Notice that it must begin by, and be followed by a space
##
RE_DATE_FORMAT_BRAVO='^([1-2]0[0-9][0-9])-?([0-1][0-9])[[:space:]\-][[:alnum:]]'


if [[ ${TARGET_FILE} =~ $RE_DATE_FORMAT_BRAVO ]]; then
  TARGET_DATE_PATTERN="bravo"
  set +u
  TARGET_DATE=$(echo "${TARGET_FILE}" | grep -Eo "${RE_DATE_FORMAT_BRAVO}")
  TARGET_DATE="${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-30"
  set -u
fi

if [[ "${TARGET_FILE}" =~ $RE_DATE_FORMAT_ALPHA ]]; then
  TARGET_DATE_PATTERN="alpha"
  TARGET_DATE=$(echo "${TARGET_FILE}" | grep -Eo "${RE_DATE_FORMAT_ALPHA}")
  if ! [[ "${TARGET_FILE}" =~ $RE_MUST_BE_DATE_FORMAT ]]; then
    TARGET_DATE="${TARGET_DATE:0:4}-${TARGET_DATE:4:2}-${TARGET_DATE:6:2}"
  fi
fi


if [[ "${TARGET_DATE}" =~ $RE_MUST_BE_DATE_FORMAT ]]; then
  TARGET_DATE_YEAR="${TARGET_DATE:0:4}"
  TARGET_DATE_MONTH="${TARGET_DATE:5:2}"
  TARGET_DATE_DAY="${TARGET_DATE:8:2}"
else
  error "Invalid date format in \"${TARGET_FILE}\""
fi



echo "Date pattern:	'${TARGET_DATE_PATTERN}'"
echo "Date:					'${TARGET_DATE}'"
echo "Y:						'${TARGET_DATE_YEAR}'"
echo "M:						'${TARGET_DATE_MONTH}'"
echo "D:						'${TARGET_DATE_DAY}'"



if ! [[ "${TARGET_DATE_YEAR}" =~ [1-2]0[0-9][0-9] ]]; then
  error "Invalid year number ${TARGET_DATE_YEAR}"
fi

if ! [[ "${TARGET_DATE_MONTH}" =~ [0-1][0-9] ]]; then
  error "Invalid month number ${TARGET_DATE_MONTH}"
else
  WITHOUT_ZERO=$(echo "${TARGET_DATE_MONTH}" | sed 's/^0*//')
  if (( $WITHOUT_ZERO > 13 )); then
    error "There is no such month number ${TARGET_DATE_MONTH}, there are only 12 months in a Gregorian calendar."
  fi
fi

if ! [[ "${TARGET_DATE_DAY}" =~ [0-3][0-9] ]]; then
  error "Invalid day number ${TARGET_DATE_DAY}"
else
  WITHOUT_ZERO=$(echo "${TARGET_DATE_DAY}" | sed 's/^0*//')
  if (( $WITHOUT_ZERO > 32 )); then
    error "Invalid day ${TARGET_DATE_DAY}, months are no longer than 31"
  fi
fi

touch -a -m -t "${TARGET_DATE_YEAR}${TARGET_DATE_MONTH}${TARGET_DATE_DAY}0101" "${TARGET_FILE}"
echo "touch -a -m -t \"${TARGET_DATE_YEAR}${TARGET_DATE_MONTH}${TARGET_DATE_DAY}0101\" \"${TARGET_FILE}\""

echo "DONE"
