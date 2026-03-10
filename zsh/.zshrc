PROMPT='%n@%m %~ $ '

# PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$PATH:$HOME/go/bin"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$PATH:$HOME/.lmstudio/bin"
export PATH="/Library/TeX/texbin:$PATH"
export FZF_DEFAULT_OPTS_FILE="$HOME/.fzfrc"

# aliases
alias ls='lsd --tree --depth 1'
alias ll='lsd -la'
alias la='lsd -a'
alias lt='lsd --tree'
alias c='clear'
alias browse='w3md'
alias files='ranger'
alias pn='pnpm'
alias utmctl='/Applications/UTM.app/Contents/MacOS/utmctl'

# functions
vm() {
    case "$1" in
        start)
            open -gja UTM
            sleep 1
            utmctl start FreeBSD
            echo "Waiting for SSH..."
            while ! nc -z localhost 2222 2>/dev/null; do
                sleep 1
            done
            echo "Ready."
            ;;
        stop)
            utmctl stop FreeBSD
            ;;
        ssh)
            shift
            ssh tristan@localhost -p 2222 "$@"
            ;;
        *)
            echo "Usage: vm {start|stop|ssh}"
            ;;
    esac
}

# tool integrations
# envman
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# zerobrew
export ZEROBREW_DIR="$HOME/.zerobrew"
export ZEROBREW_BIN="$HOME/.zerobrew/bin"
export ZEROBREW_ROOT=/opt/zerobrew
export ZEROBREW_PREFIX=/opt/zerobrew
export PKG_CONFIG_PATH="$ZEROBREW_PREFIX/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

if [ -z "${CURL_CA_BUNDLE:-}" ] || [ -z "${SSL_CERT_FILE:-}" ]; then
    if [ -f "$ZEROBREW_PREFIX/opt/ca-certificates/share/ca-certificates/cacert.pem" ]; then
        [ -z "${CURL_CA_BUNDLE:-}" ] && export CURL_CA_BUNDLE="$ZEROBREW_PREFIX/opt/ca-certificates/share/ca-certificates/cacert.pem"
        [ -z "${SSL_CERT_FILE:-}" ] && export SSL_CERT_FILE="$ZEROBREW_PREFIX/opt/ca-certificates/share/ca-certificates/cacert.pem"
    elif [ -f "$ZEROBREW_PREFIX/etc/ca-certificates/cacert.pem" ]; then
        [ -z "${CURL_CA_BUNDLE:-}" ] && export CURL_CA_BUNDLE="$ZEROBREW_PREFIX/etc/ca-certificates/cacert.pem"
        [ -z "${SSL_CERT_FILE:-}" ] && export SSL_CERT_FILE="$ZEROBREW_PREFIX/etc/ca-certificates/cacert.pem"
    elif [ -f "$ZEROBREW_PREFIX/etc/openssl/cert.pem" ]; then
        [ -z "${CURL_CA_BUNDLE:-}" ] && export CURL_CA_BUNDLE="$ZEROBREW_PREFIX/etc/openssl/cert.pem"
        [ -z "${SSL_CERT_FILE:-}" ] && export SSL_CERT_FILE="$ZEROBREW_PREFIX/etc/openssl/cert.pem"
    elif [ -f "$ZEROBREW_PREFIX/share/ca-certificates/cacert.pem" ]; then
        [ -z "${CURL_CA_BUNDLE:-}" ] && export CURL_CA_BUNDLE="$ZEROBREW_PREFIX/share/ca-certificates/cacert.pem"
        [ -z "${SSL_CERT_FILE:-}" ] && export SSL_CERT_FILE="$ZEROBREW_PREFIX/share/ca-certificates/cacert.pem"
    fi
fi

if [ -z "${SSL_CERT_DIR:-}" ]; then
    if [ -d "$ZEROBREW_PREFIX/etc/ca-certificates" ]; then
        export SSL_CERT_DIR="$ZEROBREW_PREFIX/etc/ca-certificates"
    elif [ -d "$ZEROBREW_PREFIX/etc/openssl/certs" ]; then
        export SSL_CERT_DIR="$ZEROBREW_PREFIX/etc/openssl/certs"
    elif [ -d "$ZEROBREW_PREFIX/share/ca-certificates" ]; then
        export SSL_CERT_DIR="$ZEROBREW_PREFIX/share/ca-certificates"
    fi
fi

_zb_path_prepend() {
    local argpath="$1"
    case ":$PATH:" in
        *:"$argpath":*)
            ;;
        *)
            export PATH="$argpath:$PATH"
            ;;
    esac
}

_zb_path_prepend "$ZEROBREW_BIN"
_zb_path_prepend "$ZEROBREW_PREFIX/bin"

brew() {
    case "$1" in
        install|uninstall|list|info|gc)
            zb "$@"
            ;;
        *)
            command brew "$@"
            ;;
    esac
}

# nvm
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
[ -s "$HOME/.nvm/bash_completion" ] && . "$HOME/.nvm/bash_completion"

# secrets
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
