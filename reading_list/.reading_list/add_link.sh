#!/bin/bash

set -e

# --- Configuration ---
#ACCESS_TOKEN=<provided by doppler>
DROPBOX_FILE_PATH="/reading_list.md" # The full path to your file in Dropbox
NEW_CONTENT="$1" # The new text/link comes from the first argument to the script

# Check if content was provided
if [ -z "$NEW_CONTENT" ]; then
    echo "Usage: $0 \"Your new link or text\""
    exit 1
fi

# this works
CURRENT_CONTENT=$(curl -s -X POST https://content.dropboxapi.com/2/files/download \
    --header "Authorization: Bearer $ACCESS_TOKEN" \
    --header "Dropbox-API-Arg: {\"path\":\"/reading_list.md\"}")

# add a line
# echo $NEW_CONTENT >> local_file.md
UPDATED_CONTENT=$(echo -e "$CURRENT_CONTENT\n$NEW_CONTENT")


# 3. Upload the modified content back to Dropbox, overwriting the old file
# We pass the file path in the Dropbox-API-Arg header and the data in the body.
curl -X POST https://content.dropboxapi.com/2/files/upload \
    --header "Authorization: Bearer $ACCESS_TOKEN" \
    --header "Dropbox-API-Arg: {\"path\": \"$DROPBOX_FILE_PATH\",\"mode\": \"overwrite\"}" \
    --header "Content-Type: application/octet-stream" \
    --data-binary "$UPDATED_CONTENT" > /dev/null

#echo "Successfully added to $DROPBOX_FILE_PATH"

echo "New contents:\n$UPDATED_CONTENT"
