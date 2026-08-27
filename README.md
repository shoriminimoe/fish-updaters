# fish-updaters

[fish](https://fishshell.com/) functions that install and update tools I keep
outside the system package manager — mostly single-binary releases pulled
straight from GitHub or a vendor's download endpoint.

One autoloadable function per tool in `functions/`, named `update-<tool>`. Run
it and it fetches the latest release, unpacks it, and links it onto `PATH`.
Type `update-` and hit tab to see what's here.

## Install

The layout is a standard fish plugin, so [fisher](https://github.com/jorgebucaran/fisher)
can install the whole set:

```fish
fisher install shoriminimoe/fish-updaters
```

Or from a local clone, which is handy while editing: `fisher install
/path/to/fish-updaters`. Either way `fisher update` picks up new versions and
`fisher remove` takes it all back out again.

Without fisher, fish autoloads functions from any directory on
`$fish_function_path`. Either point fish at this repo:

```fish
# ~/.config/fish/config.fish
set -p fish_function_path /path/to/fish-updaters/functions
```

…or symlink the individual functions you want:

```fish
ln -svt ~/.config/fish/functions (pwd)/functions/update-*.fish
```

## Conventions

Most of the updaters follow the same shape:

1. Query the GitHub releases API for the latest tag and pick the asset matching
   this OS/arch (`uname` + a name regex, filtered with `jq`).
2. Unpack it into a versioned directory under `~/.local/stow/<name>-<version>`.
3. Unlink previously installed versions with `stow -D`, then `stow` the new one
   into the `~/.local` prefix.

Keeping each version in its own stow package makes an update just "unlink old,
link new", and rollback a matter of re-stowing the old directory. `~/.local/bin`
needs to be on `PATH`. A few tools that ship their own updater or want a
system-wide prefix deviate from this — read the function before running it.

## Requirements

`curl`, `wget`, `tar`, `jq`, `awk`, `git`, and [GNU
Stow](https://www.gnu.org/software/stow/). Individual updaters may want more.
The GitHub API calls are unauthenticated, so they're subject to the anonymous
rate limit.

## Adding an updater

Copy the closest existing function, rename it to `update-<tool>.fish`, and
adjust the repo, the asset name regex, and the tar flags
(`--strip-components` depends on how the upstream archive is rooted). The file
name must match the function name for fish to autoload it.
