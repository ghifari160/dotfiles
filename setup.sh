#!/bin/bash

if [ -z "${BASH_VERSION:-}" ]
then
    printf "%s\n" "Bash is required to interpret this script"
    exit 1
fi

if [[ -t 1 ]]; then
    function tty_escape {
        printf "\033[%sm" "$1"
    }
else
    function tty_escape {
        :
    }
fi

tty_red="$(tty_escape 31)"
tty_blue="$(tty_escape 34)"
tty_reset="$(tty_escape 0)"

function abort {
    printf "${tty_red}%s${tty_reset}\n" "$@" >&2
    exit 1
}

function log {
    printf "${tty_blue}%s${tty_reset}\n" "$@"
}

function warn {
    printf "${tty_red}%s${tty_reset}\n" "$@"
}

function usage {
    cat << EOS
setup.sh
Usage: [NONINTERACTIVE=1] [USERNAME=USERNAME] [MACHINE=MACHINE] [TOKEN=GITHUB TOKEN] setup.sh
    NONINTERACTIVE  install without prompting for user input. Note: you may still receive one sudo prompt
    USERNAME        username for SSH key generation
    MACHINE         machine name for SSH key generation
    TOKEN           GitHub token. Requires "write:public_key" and "read:gpg_key" OAuth scopes
EOS
    exit 1
}

function isMac {
    [[ $(uname) == "Darwin" ]]
}

function isLinux {
    [[ $(uname) == "Linux" ]]
}

function isUbuntu {
    isLinux && lsb_release -d | grep -q "Ubuntu"
}

function download {
    url=$1
    dest=$2

    log "Downloading $url to $dest"
    curl -fsSL "$url" -o "$dest"
}

SUDO_ASKPASS=""

function sudo_init {
    local SUDO_PASSWORD
    local PASSWORD_SCRIPT

    if ! sudo -v -n &> /dev/null; then
        while :; do
            read -rsp "Sudo password: " SUDO_PASSWORD
            echo

            if sudo -v -S 2>/dev/null <<< "$SUDO_PASSWORD"; then
                break
            fi

            unset SUDO_PASSWORD
            echo "Invalid password!" >&2
        done


        PASSWORD_SCRIPT="$(
            cat << EOS
#!/bin/bash
echo "$SUDO_PASSWORD"
EOS
        )"
        unset SUDO_PASSWORD

        log "Caching sudo password"

        set -x
        SUDO_ASKPASS="$(mktemp)"
        chmod 700 "$SUDO_ASKPASS"
        bash -c "cat > '$SUDO_ASKPASS'" <<< "$PASSWORD_SCRIPT"
        unset PASSWORD_SCRIPT
        export SUDO_ASKPASS
        set +x
    fi
}

function sudo_release {
    local sudo_hold=$1

    log "Releasing sudo ticket"

    set -x
    kill "$sudo_hold"
    unset sudo_hold

    if [[ -f "$SUDO_ASKPASS" ]]; then
        rm -f "$SUDO_ASKPASS"
    fi
    sudo -k
    unset SUDO_ASKPASS
    set +x
}

function sudo_refresh {
    if [[ -f "$SUDO_ASKPASS" ]]; then
        sudo -A -v
    else
        sudo_init
    fi
}

function sudo_askpass {
    if [[ -f "$SUDO_ASKPASS" ]]; then
        sudo -A "$@"
    else
        sudo "$@"
    fi
}

#### Setup ####

HOST="$(echo "$HOSTNAME" | cut -d '.' -f1)"

if [[ ! "$NONINTERACTIVE" -eq 1 ]]; then
    read -rp "Username ($USER): " USERNAME
    read -rp "Machine ($HOST): " MACHINE
    read -rsp "GitHub Token: " TOKEN
    echo
fi

if [[ "$NONINTERACTIVE" -eq 1 ]]; then
    if [[ -z "$USERNAME" ]]; then
        abort "Username is required!"
    fi

    if [[ -z "$MACHINE" ]]; then
        abort "Machine name is required!"
    fi
else
    if [[ -z "$USERNAME" ]]; then
        USERNAME="$USER"
    fi

    if [[ -z "$MACHINE" ]]; then
        MACHINE="$HOST"
    fi
fi

if [[ -z "$TOKEN" ]]; then
    abort "GitHub token is required!"
fi

set -Eeo pipefail

export USERNAME
export MACHINE
export TOKEN

if isMac; then
    caffeinate -s -w $$ &
fi

if [[ "$SKIP_BOOTSTRAP" -eq 1 ]]; then
    log "Provisioning without bootstrap!"
fi

if ! command -v "sudo" &> /dev/null; then
    abort "Need sudo access!"
fi

log "Checking for sudo priviledge"
sudo_refresh
if ! sudo_askpass -l apt-get &> /dev/null && ! sudo_askpass -l tee &> /dev/null && ! sudo_askpass -l mkdir &> /dev/null; then
    abort "Need sudo access!"
fi

log "Holding sudo ticket"
while :; do sudo_refresh; sleep 60; done &
sudo_hold=$!

log "Downloading and installing software updates"
if isMac; then
    sudo_askpass softwareupdate --install --all
elif isUbuntu; then
    sudo_askpass apt-get -yq update
    sudo_askpass apt-get -yq upgrade
    sudo_askpass apt-get -yq dist-upgrade
else
    warn "Cannot install software updates on unknown $(uname)!"
fi

if ! command -v "curl" &> /dev/null; then
    if isUbuntu; then
        log "Downloading and installing curl"
        sudo_askpass apt-get -yq update
        sudo_askpass apt-get -yq install curl
    else
        abort "curl not found!"
    fi
fi

if ! command -v "git" &> /dev/null; then
    if isUbuntu; then
        log "Downloading and installing git"
        sudo_askpass apt-get -yq update
        sudo_askpass apt-get -yq install git
    else
        abort "git not found!"
    fi
fi

if ! command -v "gcc" &> /dev/null; then
    if isUbuntu; then
        log "Downloading and installing build-essential"
        sudo_askpass apt-get -yq update
        sudo_askpass apt-get -yq install build-essential
    else
        abort "Homebrew dependencies not installed. On Ubuntu, install the \`build-essential\` package!"
    fi
fi

log "Downloading and installing Homebrew"
brew=$(mktemp)
download "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" "$brew"
chmod a+x "$brew"
/bin/bash -c "NONINTERACTIVE=1 $brew"
if isMac; then
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

log "Cleaning up Homebrew installation"
rm -f "$brew"
unset brew

log "Downloading and installing private Brewfile"
download "https://raw.githubusercontent.com/ghifari160/dotfiles/yadm/.private/Brewfile" "$HOME/Brewfile"
brew bundle install

log "Cleaning up private Brewfile"
rm -f "$HOME/Brewfile" "$HOME/Brewfile.lock.json"

log "Adding ZSH to /etc/shells"
which zsh | sudo tee -a /etc/shells

if command -v "chsh" &> /dev/null; then
    log "Setting shell for current user to ZSH"
    sudo chsh -s "$(which zsh)" "$USER"
fi

log "Cloning dotfiles repository"
yadm clone --no-bootstrap "https://github.com/ghifari160/dotfiles"

# Finish setup using the bootstrap script.
if [[ "$SKIP_BOOTSTRAP" -eq 0 ]]; then
    log "Running bootstrap"
    yadm bootstrap
fi

sudo_release "$sudo_hold"

log
log "Provisioning complete!"
log
log "Note: log out of current user"

if ! command -v "chsh" &> /dev/null; then
    log
    log "Note: change shell for current user to '$(which zsh)'"
fi
