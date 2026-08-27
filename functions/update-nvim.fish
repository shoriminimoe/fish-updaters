#!/usr/bin/env fish
function update-nvim
    # All paths are absolute paths!
    set prefix "$HOME/.local"
    set stow_dir "$prefix/stow"
    set os (uname --kernel-name | string lower)
    set arch (uname --processor)
    set name_re (printf '-%s-%s.tar.gz$' $os $arch)
    set asset (curl -s https://api.github.com/repos/neovim/neovim/releases/latest | jq (printf '.assets.[] | select(.name | test("%s"))' $name_re))
    set download_url (echo "$asset" | jq -r '.browser_download_url')
    set name (echo "$download_url" | awk -F/ '{print "nvim-" $(NF-1)}')
    set install_dir "$stow_dir/$name"
    mkdir -p "$install_dir"
    wget --quiet --show-progress -O- "$download_url" | tar -C "$install_dir" --strip-components=1 -xzf-
    # uninstall the old version(s)
    for old_name in (path basename "$stow_dir/"nvim* | grep -v "$name")
        stow -v -d "$stow_dir" -t "$prefix" -D "$old_name"
    end
    # install the new version
    stow -v -d "$stow_dir" -t "$prefix" "$name"
end
