# GHIFARI160's dotfiles

[GHFIFARI160](https://github.com/ghifari160)'s dotfiles.

## Cheatsheet

``` shell
git clone --bare git@github.com:ghifari160/dotfiles.git ~/.dotfiles.git
alias dotfiles="git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME"
dotfiles config --local status.showUntrackedFiles no
dotfiles checkout
```
