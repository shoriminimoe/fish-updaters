#!/usr/bin/env fish
function update-asdf
    # All paths are absolute paths!
    set install_dir "$HOME/.local/bin"
    set name_re '-linux-amd64.tar.gz$'
    set asset (curl -s https://api.github.com/repos/asdf-vm/asdf/releases/latest | jq (printf '.assets.[] | select(.name | test("%s"))' $name_re))
    set download_url (echo "$asset" | jq -r '.browser_download_url')
    set name (echo "$asset" | jq -r (printf '.name | split("%s").[0]' $arch_re) | string lower)
    mkdir -p "$install_dir"
    wget --quiet --show-progress -O- "$download_url" | tar -C "$install_dir" -xzf-
end
