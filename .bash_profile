export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

export PS1="\W \u\$ "

export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

export PATH=$HOME/.bin:$PATH
export PATH=$HOME/go/bin:$PATH
export PATH=$HOME/depot_tools:$PATH
export PATH=$HOME/reman-install/bin:$PATH
export REMAN_DIR=$HOME/reman-install

# Go
export GOPATH=$(go env GOPATH)
export PATH=$GOPATH/bin:$PATH

# Krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
