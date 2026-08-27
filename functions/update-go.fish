function update-go
    if command -q go
        set CURRENT_GO_VERSION (go version | awk '{print $3}')
    else
        set CURRENT_GO_VERSION none
    end

    set os (uname -o)
    if test "$os" = GNU/Linux
        set os linux
    end

    set arch (uname -m)
    if test "$arch" = x86_64
        set arch amd64
    else if test "$arch" = aarch64
        set arch arm64
    end

    curl -s 'https://go.dev/dl/?mode=json' | jq --raw-output --arg os "$os" --arg arch "$arch" '.[0].files[] | select(.os==$os and .arch==$arch and .kind == "archive") | .filename, .version' | read --line go_filename go_version

    if test "$go_version" = "$CURRENT_GO_VERSION"
        echo "go is already up to date: $CURRENT_GO_VERSION"
        return
    end

    set SYSTEM_PREFIX /usr/local
    sudo rm -rf "$SYSTEM_PREFIX/go"
    curl --proto '=https' -SfL "https://go.dev/dl/$go_filename" | sudo tar -C "$SYSTEM_PREFIX" -xz
    fish_add_path "$SYSTEM_PREFIX/go/bin"
end
