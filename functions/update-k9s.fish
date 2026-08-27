#!/usr/bin/env fish
function update-k9s
    # All paths are absolute paths!
    set prefix "$HOME/.local"
    set stow_dir "$prefix/stow"
    set os (uname --kernel-name)
    set arch (uname --processor | string replace 'x86_64' 'amd64')
    set name_re (printf '_%s_%s.tar.gz$' $os $arch)
    set asset (curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq (printf '.assets.[] | select(.name | test("%s"))' $name_re))
    set download_url (echo "$asset" | jq -r '.browser_download_url')

    set name (echo "$download_url" | awk -F/ '{print "k9s-" $(NF-1)}')
    set install_dir "$stow_dir/$name/bin"
    mkdir -p "$install_dir"
    # only the binary is extracted; the archive also carries LICENSE and README.md
    wget --quiet --show-progress -O- "$download_url" | tar -C "$install_dir" -xzf- k9s
    # uninstall the old version(s)
    for old_name in (path basename "$stow_dir/"k9s-* | grep -v "$name")
        stow -v -d "$stow_dir" -t "$prefix" -D "$old_name"
    end
    # install the new version
    stow -v -d "$stow_dir" -t "$prefix" "$name"
end
