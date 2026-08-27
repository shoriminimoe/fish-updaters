#!/usr/bin/env fish
function update-kitty
    set prefix "$HOME/.local"
    if test -d "$prefix/stow/kitty.app"
        stow -v -d "$prefix/stow" -t "$prefix" -D kitty.app
        rm -rf "$prefix/stow/kitty.app"
    end
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n dest="$prefix/stow"
    stow -v -d "$prefix/stow" -t "$prefix" kitty.app

    # update-alternatives --install /usr/bin/kitty x-terminal-emulator /usr/local/bin/kitty 60
    # gsettings set org.gnome.desktop.default-applications.terminal exec kitty
end
