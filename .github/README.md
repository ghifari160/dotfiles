# GHIFARI160's dotfiles

[GHIFARI160](https://github.com/ghifari160)'s dotfiles.

## Caveats

MAS commands in [`Brewfile`](../Brewfile) and [`.private/Brewfile`](../.private/Brewfile) has been disabled.
MAS is not _yet_ functional in macOS Monterey.
See [mas-cli/mas#417](https://github.com/mas-cli/mas/issues/417).

## Cheatsheet

``` shell
# Brewfile
curl -o $HOME/Brewfile -fsSL https://raw.githubusercontent.com/Ghifari160/dotfiles/main/.private/Brewfile
brew bundle install
rm -f Brewfile.lock.json

# dotfiles
git clone --bare git@github.com:ghifari160/dotfiles.git ~/.dotfiles.git
alias dotfiles="git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME"
dotfiles config --local status.showUntrackedFiles no
dotfiles checkout

# macOS Terminal
open Ghi.terminal && defaults write com.apple.terminal "Default Window Settings" "Ghi" && defaults write com.apple.terminal "Startup Window Settings" "Ghi" && killall Terminal
```
