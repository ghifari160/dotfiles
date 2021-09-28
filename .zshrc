export PS1="%~ %n$ "
export RPROMPT="%t"

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=5000
SAVEHIST=500
setopt autocd beep notify
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored _correct _approximate
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]} m:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:]}={[:upper:]} m:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:]}={[:upper:]} m:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:]}={[:upper:]} m:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle :compinstall filename '$HOME/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Misc
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

# Kubectl
export KUBE_EDITOR="code -w"
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

# Dotfiles
alias dotfiles="git --git-dir=$HOME/.dotfiles.git --work-tree=$HOME"

# asciinema recording
alias asciirec="ASCIINEMA_REC=1 asciinema rec $@"

# If recording
if [[ $ASCIINEMA_REC ]]; then
    export PS1="%~ $ "
fi
