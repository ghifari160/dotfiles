# GHIFARI160's dotfiles

[GHIFARI160](https://github.com/ghifari160)'s dotfiles.

## Caveats

~~MAS commands in [`Brewfile`](../Brewfile) and [`.private/Brewfile`](../.private/Brewfile) has been disabled.
MAS is not _yet_ functional in macOS Monterey.
See [mas-cli/mas#417](https://github.com/mas-cli/mas/issues/417).~~
First installation through MAS no longer works, but it is worth keeping in the Brewfiles as a reminder of what needs to be installed.

## Cheatsheet

``` shell
# Private Brewfile
curl -o $HOME/Brewfile -fsSL https://raw.githubusercontent.com/Ghifari160/dotfiles/main/.private/Brewfile
brew bundle install
rm -f Brewfile Brewfile.lock.json

# Setup GitHub
gh auth login

# Temporary SSH setup
ssh-keygen -t ed25519 -C "<email>"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
gh ssh-key add ~/.ssh/id_ed25519 --title "<machine>-provision"

# dotfiles
git clone --bare git@github.com:ghifari160/dotfiles.git ~/.dotfiles.git
alias dotfiles="git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME"
dotfiles config --local status.showUntrackedFiles no
dotfiles checkout

# Brewfile
brew bundle install

# macOS Terminal
open Ghi.terminal && defaults write com.apple.terminal "Default Window Settings" "Ghi" && defaults write com.apple.terminal "Startup Window Settings" "Ghi" && killall Terminal
```
