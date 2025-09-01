#!/bin/bash

# 1. Get clipboard content using xclip.
CLIPBOARD_CONTENT=$(xclip -o)

# 2. Run your main script, pass the clipboard content as an argument,
#    and capture whatever it prints out.
SCRIPT_OUTPUT=$(\
    doppler run -c dev_personal -p reading-list -- \
    bash $HOME/.reading_list/add_link.sh "$CLIPBOARD_CONTENT")

# 3. Use notify-send to show the captured output in a notification.
#    The format is: notify-send "Title" "Body"
notify-send "Script Executed" "$SCRIPT_OUTPUT"
