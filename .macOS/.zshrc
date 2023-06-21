if [[ $OSTYPE != "darwin"* ]]; then
    echo ".macOS must be used on macOS systems!"

    exit 1
fi

# asciinema recording
alias asciirec="ASCIINEMA_REC=1 asciinema rec $@"

# WiFi Toggle
alias wifi="networksetup -setairportpower en0 $@"

# Sleep Toggle
alias sleepctl="$HOME/.macOS/sleepctl.sh $@"

# Clear clipboard
alias clearboard="cat /dev/null | pbcopy"

# Go
if [[ $(which go) ]]; then
    export GOPATH=$(go env GOPATH)
    export PATH=$GOPATH/bin:$PATH
fi

# Kubectl
if [[ $(which kubectl) ]]; then
    export KUBE_EDITOR="code -w"
    if [[ -n $ZSH_VERSION ]]; then
        [[ $commands[kubectl] ]] && source <(kubectl completion zsh)
    fi
fi

# OpenJDK 17
if [[ $(which javac) ]]; then
    export PATH="/usr/local/opt/openjdk@17/bin:$PATH"
    export JAVA_HOME="$(dirname $(dirname $(realpath $(which javac))))"
fi
