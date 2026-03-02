#!/bin/bash

resurrect_dir="$HOME/.local/share/tmux/resurrect"
newest_res_file=$(ls -t "$resurrect_dir"/tmux* 2>/dev/null | head -1)

if [[ -f "$newest_res_file" ]]; then
    echo "Deleting most recent tmux resurrect file ..."
    rm "$newest_res_file" &&
    echo "Resurrect file removed ..." || {
        echo "Could not remove resurrect file ..."
        exit 1
    }

    next_res_file=$(ls -t "$resurrect_dir"/tmux* 2>/dev/null | head -1)
    if [[ -f "$next_res_file" ]]; then
        echo "Recreating link to next most recent resurrect file ..."
        cd "$resurrect_dir" || exit 1
        [[ -L last ]] && rm last
        ln -s "$next_res_file" last
    else 
        echo "No other resurrect file found ..."
    fi

else
    echo "No resurrect file found to remove ..."
fi
