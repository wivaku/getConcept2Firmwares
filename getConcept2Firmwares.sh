#!/bin/bash

# https://github.com/wivaku/getConcept2Firmwares

# UNOFFICIAL script to download the Concept2 firmwares PM5 monitors for rower/skierg/bike
# similar to what the Concept2 Utility does: first retrieve list of available firmwares and then download them

# optional parameters
# -d <folder> e.g. /Volumes/MYCONCEPT2USB/Concept2/Firmware  (default: $HOME/Downloads/Concept2/Firmware)
# -s [public | beta]  (default: "public")
# -m [pm3 | pm4 | pm5]  (default: pm5) note: not really useful for PM3/PM4 as they don't have USB stick support

# --------------------------------------------------------------------------------------
# Concept2 Utility uses basic auth to get the list of latest firmwares
# to find the token you can use a "man in the middle proxy tool" and run Concept2 Utility
# look for request to https://tech.concept2.com/api/firmware/latest
# you can store the token in .env or put it in this script
# --------------------------------------------------------------------------------------
[[ -f ".env" ]] && source .env
[[ -z $TOKEN ]] && TOKEN="Authorization: Basic Y...U=" # <<< CHANGE HERE OR IN .env FILE
# --------------------------------------------------------------------------------------

UNZIP="/usr/local/bin/7z"
JQ="/usr/local/bin/jq"

MONITOR="pm5"
STATUS="public"
DESTINATION=$HOME/Downloads/Concept2/Firmware

ORIGDIR=$PWD

# parse the parameters
while getopts ":m:s:d:" opt; do
  case $opt in
    d) DESTINATION="$OPTARG"
      ;;
    s) STATUS="$OPTARG"
      ;;
    m) MONITOR="$OPTARG"
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# if anything fails it is probably because there's no token
# set -e
trap 'catch' ERR
catch() {
  echo "------------------------------------------------------------------------"
  echo "error occured - are you sure the TOKEN is available (in .env or script)?"
  echo "------------------------------------------------------------------------"
  cd $ORIGDIR
  exit 1
}

# helper function to print text in green
log () { echo -e "\033[0;32m${*}\033[0m"; }

# show all available firmwares (for that model)
log "all available $MONITOR firmware versions (public & beta)"
# note: Concept2 Utility only gets the first file (eurochinese), not the zhjakobin file 
# therefore files[0].name instead of files[].name
QUERY=".data \
  | sort_by(.release_date) \
  | .[] \
  | select(.monitor | index(\"$MONITOR\") )
  | select(.description | index(\"Internal Use Only\") | not )
  | [.status, .machine, .release_date, .short_description, .files[0].name] \
  | @tsv
"
curl -s "https://tech.concept2.com/api/firmware/latest" -H "$TOKEN" | $JQ -r "$QUERY"

echo
log "Ready to download the ${STATUS} files to '${DESTINATION}'. Note: all existing files will be removed!"
read -p "Do you want to continue? (y/n) " -n 1 -r
echo
# if not: exit
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 0

# create the destination (if it does not exist) and delete existing files
mkdir -p "$DESTINATION"
cd "$DESTINATION"
/bin/rm -f *

# create comma separated string of the filenames
QUERY=".data | sort_by(.release_date) | .[]"
# option 1: only get public OR beta (i.e. don't get public when requesting beta and vice versa)
QUERY="${QUERY} | select(.status | index(\"$STATUS\") )" # 
# option 2 (Concept2 Utility approach): if beta: get public AND beta
# [[ "$STATUS" != "beta" ]] && QUERY="${QUERY} | map(select(.status | index(\"beta\") | not )) " 
QUERY="${QUERY} \
  | select(.monitor | index(\"$MONITOR\") )
  | select(.description | index(\"Internal Use Only\") | not )
  | .files[0].name
"

FILES=$(curl -s "https://tech.concept2.com/api/firmware/latest" -H "$TOKEN" | $JQ -r "$QUERY")

BASEURL=https://firmware.concept2.com/files

log "downloading the firmware files to ${DESTINATION}"
for FILE in $FILES
do
  echo "- $FILE"
  curl -s -O "$BASEURL/$FILE"
  $UNZIP e -y $FILE > /dev/null
done

echo
log "make sure these files end up in folder 'Concept2/Firmware' on your USB stick"
