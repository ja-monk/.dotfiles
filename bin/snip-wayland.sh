#!/bin/bash

timestamp=$(date +'%Y-%m-%d_%H-%M-%S')
output_dir="$HOME/Pictures/screenshots"
edit=false

# check for edit argument
while [[ $# -gt 0 ]]; do
    case "$1" in
        -e|--edit)
            edit=true
            shift
        ;;
        *)
            notify-send \
                "Unrecognised argument to screenshot: $1" \
                -u critical \
                -t 3000
            exit 1
        ;;
    esac
done

# check for screenshot dir & attempt to create if cant find
[[ -d "$output_dir" ]] || {
    mkdir -p "$output_dir"
 
    if [[ ! -d "$output_dir" ]]; then
      notify-send \
          "Screenshot directory does not exist and creation failed: $output_dir" \
          -u critical \
          -t 3000
      exit 1
    fi
}

# edit with satty if --edit flag passed, otherwise just copy
if [[ "$edit" == true ]]; then
    pkill slurp || hyprshot -m ${1:-region} --raw |
      satty --filename - \
        --output-filename "$output_dir/screenshot-${timestamp}.png" \
        --early-exit \
        --actions-on-enter save-to-clipboard \
        --copy-command 'wl-copy'
else
    pkill slurp || hyprshot -m ${1:-region} --raw | wl-copy
fi

