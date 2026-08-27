#!/usr/bin/env fish
function update-zmx
    # All paths are absolute paths!
    set prefix "$HOME/.local"
    set stow_dir "$prefix/stow"

    set os (uname --kernel-name | string lower)
    set arch (uname --processor)

    set latest_tag (curl -s https://api.github.com/repos/neurosnap/zmx/tags | jq -r '.[].name' | sort -V | tail -n1 | string replace --regex "^v" "")
    set name zmx-$latest_tag
    set download_url "https://zmx.sh/a/$name-$os-$arch.tar.gz"
    set install_dir "$stow_dir/$name/bin"

    echo "Installing to $install_dir"
    mkdir -p "$install_dir"
    set tmpdir (mktemp -d)
    set checksum (wget --quiet -O- $download_url.sha256 | cut -d" " -f1)
    wget --quiet --show-progress -O- "$download_url" | tee "$tmpdir/$name.tar.gz" | sha256sum | grep -q "$checksum" \
        && tar -C "$install_dir" -xzf "$tmpdir/$name.tar.gz"
    # uninstall the old version(s)
    for old_name in (path basename "$stow_dir/zmx-"* | grep -v "$name")
        stow -v -d "$stow_dir" -t "$prefix" -D "$old_name"
    end
    # install the new version
    stow -v -d "$stow_dir" -t "$prefix" "$name"
    "$prefix/bin/zmx" completions fish >"$HOME/.config/fish/completions/zmx.fish"
end
