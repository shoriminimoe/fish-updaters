#!/usr/bin/env fish
function update-zk
    # All paths are absolute paths!
    set prefix "$HOME/.local"
    set stow_dir "$prefix/stow"
    set os (uname --kernel-name | string lower)
    set arch (uname --processor | string replace 'x86_64' 'amd64')
    set name_re (printf '-%s-%s.tar.gz$' $os $arch)
    set asset (curl -s https://api.github.com/repos/zk-org/zk/releases/latest | jq (printf '.assets.[] | select(.name | test("%s"))' $name_re))
    set download_url (echo "$asset" | jq -r '.browser_download_url')

    set name (echo "$download_url" | awk -F/ '{print "zk-" $(NF-1)}')
    set install_dir "$stow_dir/$name/bin"
    mkdir -p "$install_dir"
    wget --quiet --show-progress -O- "$download_url" | tar -C "$install_dir" -xzf-
    # uninstall the old version(s)
    for old_name in (path basename "$stow_dir/"zk* | grep -v "$name")
        stow -v -d "$stow_dir" -t "$prefix" -D "$old_name"
    end
    # install the new version
    stow -v -d "$stow_dir" -t "$prefix" "$name"
end
