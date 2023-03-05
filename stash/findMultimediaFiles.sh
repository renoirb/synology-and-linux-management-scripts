#!/usr/bin/env bash

##
## Fine multimedia files in deeply nested directories
##
## Was useful when merging from many USB drives and trying
## to catalog them all.
##
## Originally written: 2017-08-01
## See: https://gist.github.com/renoirb/89b9fce3ab41dc08002a806e926d9282#file-index-sh
## Time Spent: ~
##
## Renoir Boulanger <contribs@renoirboulanger.com>
##

set -e

TIMESTAMP=$(date +%Y%m%d%H%M%S)
LOGFILEPATH="/volumeUSB3/Somewhere"

## Adjust to your needs
declare -a DIRECTORIES=(\
              "volumeUSB1" \
              "volumeUSB2" \
              "volume1" \
            )

declare -a EXT_MUSIC=(\
              "mp3" \
              "wma" \
              "flac" \
              "ogg" \
              "ogg" \
              "m4a" \
              "oga" \
            )

declare -a EXT_VIDEOS=(\
              "mp4" \
              "mkv" \
              "flv" \
              "avi" \
              "wmv" \
              "rm" \
              "asf" \
              "m4v" \
              "mpg" \
              "mpeg" \
              "m2v" \
            )

function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }

#find /volumeUSB2 -type f -iregex ".*\.\($(join_by \\\| ${EXT_MUSIC[@]})\)" -print
#find /volumeUSB2 -type f -iregex '.*\.\(mp3\|wma\|m4a\)$'

for d in "${DIRECTORIES[@]}"; do
  FILE="${LOGFILEPATH}music_${d}.${TIMESTAMP}.txt"
  echo "At ${d} looking for ${EXT_MUSIC[@]}, logging to ${FILE}"
  find "/${d}" -type f -iregex ".*\.\($(join_by \\\| ${EXT_MUSIC[@]})\)" -exec /usr/bin/filetype "{}" + >> "${FILE}"
  FILE="${LOGFILEPATH}video_${d}.${TIMESTAMP}.txt"
  echo "At ${d} looking for ${EXT_VIDEOS[@]}, logging to ${FILE}"
  find "/${d}" -type f -iregex ".*\.\($(join_by \\\| ${EXT_VIDEOS[@]})\)" -exec /usr/bin/filetype "{}" + >> "${FILE}"
  #                                                                             ^^^^^^^^^^^^^^^^^
  # See findMultimediaFiletype.py ----------------------------------------------/
done
