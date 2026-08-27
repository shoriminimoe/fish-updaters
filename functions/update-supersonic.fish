#!/usr/bin/env fish
function update-supersonic
    # All paths are absolute paths!
    set prefix "$HOME/.local"
    set stow_dir "$prefix/stow"
    set arch_re -linux-x64-libmpv2
    set asset (curl -s https://api.github.com/repos/dweymouth/supersonic/releases/latest | jq (printf '.assets.[] | select(.name | test("%s"))' $arch_re))
    set download_url (echo "$asset" | jq -r '.browser_download_url')
    set name (echo "$asset" | jq -r (printf '.name | split("%s").[0]' $arch_re) | string lower)
    set install_dir "$stow_dir/$name"
    echo "Installing to $install_dir"
    mkdir -p "$install_dir"
    ### The download and setup {{{
    # strip-components is used because the tar file is rooted at /usr/local
    wget --quiet --show-progress -O- "$download_url" | tar -C "$install_dir" --strip-components=2 -xJf-
    set icon_dir "$install_dir/share/icons/hicolor/512x512/apps"
    mkdir -p "$icon_dir"
    cp -t "$icon_dir" "$install_dir/share/pixmaps"/*
    ### }}}
    # uninstall the old version(s)
    for old_name in (path basename "$stow_dir/"supersonic-* | grep -v "$name")
        stow -v -d "$stow_dir" -t "$prefix" -D "$old_name"
    end
    # install the new version
    stow -v -d "$stow_dir" -t "$prefix" "$name"
end
