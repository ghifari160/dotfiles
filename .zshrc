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

system_type=$(uname -s)

# If recording
if [[ $ASCIINEMA_REC ]]; then
    export PS1="%~ $ "
fi

if [[ $system_type = "Darwin" ]]; then
    # asciinema recording
    alias asciirec="ASCIINEMA_REC=1 asciinema rec $@"

    # Flush DNS
    alias flush-dns="echo \"Flushing DNS\"; sudo killall -HUP mDNSResponder; echo \"DNS Flushed!\""

    # WiFi Toggle
    alias wifi="networksetup -setairportpower en0 $@"

    # Sleep Toggle
    alias sleepctl="$HOME/.macOS/sleepctl.sh $@"

    # Clear Clipboard
    alias clearboard="cat /dev/null | pbcopy"
fi

# Go
if type "go" > /dev/null; then
    export GOPATH=$(go env GOPATH)
    export PATH=$GOPATH/bin:$PATH
fi

# Kubectl
if type "kubectl" > /dev/null; then
    export KUBE_EDITOR="code -w"
    if [[ -n $ZSH_VERSION ]]; then
        [[ $commands[kubectl] ]] && source <(kubectl completion zsh)
    fi
fi

# OpenJDK 17
if type "javac" > /dev/null; then
    export PATH="/usr/local/opt/openjdk@17/bin:$PATH"
    export JAVA_HOME="$(dirname $(dirname $(realpath $(which javac))))"
fi
