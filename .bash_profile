export CLICOLOR=1

export PS1="\W \u\$ "

export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

. "$HOME/.common"
