#!/usr/bin/env fish
function update-fzf
    set FZF_DIR "$HOME/.local/fzf"
    git -C "$FZF_DIR" pull
    "$FZF_DIR/install" --xdg --completion --update-rc --no-key-bindings
end
