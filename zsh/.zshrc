# mark load

alias ls='lsd'
alias ll='lsd -la'
alias la='lsd -a'
alias lt='lsd --tree'

export PATH="$HOME/.local/bin:$PATH"
PROMPT="$ "
PROMPT='%n@%m $ '
PROMPT='%n@%m %~ $ '

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
export PATH=$PATH:$HOME/go/bin
alias ls='lsd --tree --depth 1'
alias c="clear" 

# Load secrets (API keys, etc.)
[ -f ~/.secrets ] && source ~/.secrets
export PATH="/Library/TeX/texbin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# user bin
export PATH="$HOME/bin:$PATH"

# w3m
alias browse="w3md"

# opencode
export PATH=/Users/tristan/.opencode/bin:$PATH
alias files="ranger"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/tristan/.lmstudio/bin"
# End of LM Studio CLI section

alias ll="ollama run llama3.2:8b"
alias ll="ollama run llama3.2:8b"
alias utmctl="/Applications/UTM.app/Contents/MacOS/utmctl"
alias utmctl="/Applications/UTM.app/Contents/MacOS/utmctl"

vm() {
    case "$1" in
        start) utmctl start FreeBSD ;;
        stop)  utmctl stop FreeBSD ;;
        ssh)   ssh tristan@localhost -p 2222 ;;
        *)     echo "Usage: vm {start|stop|ssh}" ;;
    esac
}
vm() {
    case "$1" in
        start)
            open -gja UTM
            sleep 1
            utmctl start FreeBSD
            echo "Waiting for SSH..."
            while ! nc -z localhost 2222 2>/dev/null; do sleep 1; done
            echo "Ready."
            ;;
        stop)  utmctl stop FreeBSD ;;
        ssh)   shift; ssh tristan@localhost -p 2222 "$@" ;;
        *)     echo "Usage: vm {start|stop|ssh}" ;;
    esac
}
alias pn=pnpm
export PATH="$HOME/.cargo/bin:$PATH"
# >>> zerobrew >>>
# zerobrew
export ZEROBREW_DIR=/Users/tristan/.zerobrew
export ZEROBREW_BIN=/Users/tristan/.zerobrew/bin
export ZEROBREW_ROOT=/opt/zerobrew
export ZEROBREW_PREFIX=/opt/zerobrew
export PKG_CONFIG_PATH="$ZEROBREW_PREFIX/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

# SSL/TLS certificates (only if ca-certificates is installed)
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

# Helper function to safely append to PATH
_zb_path_append() {
    local argpath="$1"
    case ":${PATH}:" in
        *:"$argpath":*) ;;
        *) export PATH="$argpath:$PATH" ;;
    esac;
}

_zb_path_append "$ZEROBREW_BIN"
_zb_path_append "$ZEROBREW_PREFIX/bin"

# <<< zerobrew <<<
alias brew="zb"
alias brew="zb"
