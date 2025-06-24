#!/bin/bash

# added to fix issue when calling from i3 keybinding
sleep 0.2

timestamp=$(date +%Y%m%d%H%M%S)
output="$HOME/Pictures/screenshots/snip-${timestamp}.png"

scrot "$output" -s -l mode=edge &&
xclip  -selection clipboard -t image/png -i "$output" &&
rm "$output"
