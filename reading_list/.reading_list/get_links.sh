#!/bin/bash

set -e

# --- Configuration ---
#ACCESS_TOKEN=<provided by doppler>
DROPBOX_FILE_PATH="/reading_list.md" # The full path to your file in Dropbox

# this works
CURRENT_CONTENT=$(curl -s -X POST https://content.dropboxapi.com/2/files/download \
    --header "Authorization: Bearer $ACCESS_TOKEN" \
    --header "Dropbox-API-Arg: {\"path\":\"/reading_list.md\"}")

echo $CURRENT_CONTENT | \
    tr " " "\n" | \
    awk '!/^www\.|^http/ { $0 = "www." $0 } { print }'
