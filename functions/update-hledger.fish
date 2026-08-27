#!/usr/bin/env fish
function update-hledger
    set dest $HOME/.local/hledger
    set tmpdir (mktemp --tmpdir -d update-hledger-XXXXXXX)
    set tag_name (curl -sL https://api.github.com/repos/simonmichael/hledger/releases/latest | jq -r '.tag_name')

    set scripts hledger-git hledger-bar ft
    set python_tools hledger-utils hledger-lots

    cd "$tmpdir"
    curl -LOC- https://github.com/simonmichael/hledger/releases/latest/download/hledger-linux-x64.zip
    curl -LOC- https://github.com/simonmichael/hledger/archive/refs/tags/$tag_name.tar.gz
    extract hledger-linux-x64.zip && extract hledger-linux-x64.tar && rm hledger-linux-x64.*
    tar xzf $tag_name.tar.gz && mv -vt . hledger-$tag_name/bin/{$scripts}
    rm -rf $tag_name.tar.gz hledger-$tag_name
    rm -vrf $dest && mv -v $tmpdir $dest
    ln -vsft $HOME/.local/bin $dest/*
    for py_tool in $python_tools
        pipx install $py_tool
    end
    $HOME/.local/bin/hledger --version
    cd $dirprev[-1]
end
