#!/bin/bash

set -e

# --- Configuration ---
# ACCESS_TOKEN is provided by your environment (e.g., Doppler)
DROPBOX_FILE_PATH="/reading_list.md" # The full path to your file in Dropbox

# --- Script Logic ---

# 1. Create a secure, temporary local file to store the content from Dropbox.
TEMP_FILE=$(mktemp)

# 2. Set a "trap" to automatically delete the temp file when the script exits,
#    no matter if it succeeds, fails, or is cancelled. This is for cleanup.
trap 'rm -f "$TEMP_FILE"' EXIT

echo "⬇️  Downloading $DROPBOX_FILE_PATH..."
# 3. Download the file content from Dropbox and save it to our temp file.
curl -sS -X POST https://content.dropboxapi.com/2/files/download \
    --header "Authorization: Bearer $ACCESS_TOKEN" \
    --header "Dropbox-API-Arg: {\"path\":\"$DROPBOX_FILE_PATH\"}" \
    --output "$TEMP_FILE"

# 4. Calculate the initial checksum (a unique "fingerprint") of the downloaded file.
INITIAL_HASH=$(md5sum "$TEMP_FILE" | awk '{print $1}')

echo "📝 Opening file in nvim. Save and quit (:wq) to upload changes."
# 5. Open the temporary file in Neovim. The script will pause here until you close nvim.
nvim "$TEMP_FILE"

# 6. After you close nvim, calculate the new checksum of the (possibly modified) file.
FINAL_HASH=$(md5sum "$TEMP_FILE" | awk '{print $1}')

# 7. Compare the initial and final checksums. If they are different, the file has changed.
if [[ "$INITIAL_HASH" != "$FINAL_HASH" ]]; then
    echo "✅ Changes detected. Uploading to Dropbox..."
    # 8. Upload the modified local file back to Dropbox, overwriting the original.
    # The "@" symbol tells curl to send the contents of the file.
    curl -s -X POST https://content.dropboxapi.com/2/files/upload \
        --header "Authorization: Bearer $ACCESS_TOKEN" \
        --header "Dropbox-API-Arg: {\"path\": \"$DROPBOX_FILE_PATH\",\"mode\": \"overwrite\"}" \
        --header "Content-Type: application/octet-stream" \
        --data-binary @"$TEMP_FILE"

    echo "🚀 Successfully updated $DROPBOX_FILE_PATH"
else
    echo "🤷 No changes detected. Nothing to upload."
fi
