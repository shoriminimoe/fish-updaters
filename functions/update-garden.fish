#!/usr/bin/env fish
function update-garden
    garden self-update --install-dir ~/.garden/bin $argv
end
