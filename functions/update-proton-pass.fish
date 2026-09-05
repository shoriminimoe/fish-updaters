#!/usr/bin/env fish
function update-proton-pass
    if command -q proton-pass
        set current_version (dpkg-query --show --showformat='${Version}' proton-pass 2>/dev/null)
    end
    set --query current_version[1]; or set current_version none

    # The release list is not ordered and mixes Stable with Beta, so pick the
    # highest stable version, then its .deb (the other file is an .rpm).
    curl --proto '=https' -sSf https://proton.me/download/PassDesktop/linux/x64/version.json |
        jq --raw-output '
            [.Releases[] | select(.CategoryName == "Stable")]
            | max_by(.Version | split(".") | map(tonumber))
            | .Version, (.File[] | select(.Url | endswith(".deb")) | .Url, .Sha512CheckSum)' |
        read --line latest_version download_url checksum

    if test -z "$download_url"
        echo "update-proton-pass: no stable .deb found in version.json" >&2
        return 1
    end

    if test "$latest_version" = "$current_version"
        echo "proton pass is already up to date: $current_version"
        return
    end

    set tmpdir (mktemp --tmpdir -d update-proton-pass-XXXXXXX)
    set deb "$tmpdir/"(path basename "$download_url")
    echo "Downloading proton pass $latest_version (installed: $current_version)"
    wget --quiet --show-progress -O "$deb" "$download_url"
    or begin
        rm -rf "$tmpdir"
        return 1
    end

    if not echo "$checksum  $deb" | sha512sum --check --status
        echo "update-proton-pass: sha512 mismatch, expected $checksum" >&2
        echo "update-proton-pass: leaving the download at $deb" >&2
        return 1
    end

    sudo apt-get install "$deb"
    and rm -rf "$tmpdir"
end
