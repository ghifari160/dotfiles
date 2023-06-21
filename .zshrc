export PS1="%F{111}%~ %n$%f "
export RPROMPT="%F{111}%t%f"

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

# Include .common

if [[ $OSTYPE == "darwin"* ]]; then
    . "$HOME/.macOS/.zshrc"
elif [[ $OSTYPE == "linux"* ]]; then
    . "$HOME/.linux/.zshrc"
fi

# If recording
if [[ $ASCIINEMA_REC ]]; then
    export PS1="%~ $ "
fi
