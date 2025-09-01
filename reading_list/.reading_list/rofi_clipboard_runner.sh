#!/bin/bash

# 1. Get the current content from the clipboard.
CLIPBOARD_CONTENT=$(xclip -o)

# 2. Pipe the content into Rofi's "dmenu" mode.
#    -p sets the prompt text you see at the top.
#    Rofi will display the clipboard content. If you press Enter,
#    it outputs the content. If you press Esc, it outputs nothing.
CONFIRMED_CONTENT=$(echo "$CLIPBOARD_CONTENT" | rofi -dmenu -p "Save link from clipboard:")

# 3. Check if the user confirmed by pressing Enter.
#    If they pressed Esc, $CONFIRMED_CONTENT will be empty, and the script will exit.
if [[ -n "$CONFIRMED_CONTENT" ]]; then
    # 4. Run your main script with the confirmed content, capture its output,
    #    and show it in a notification, just like before.
    OUTPUT=$(doppler run -p reading-list -c dev_personal -- bash $HOME/.reading_list/add_link.sh "$CONFIRMED_CONTENT")
    notify-send "Script Executed" "$OUTPUT"
fi
