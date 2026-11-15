# macOS-only shell setup. Sourced by ~/.zshrc.

export PATH="/Library/TeX/texbin:$PATH"

alias utmctl='/Applications/UTM.app/Contents/MacOS/utmctl'

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
    # zb doesn't handle casks; fall back to brew when zb is absent too
    if ! (( $+commands[zb] )) || (( ${@[(I)--cask]} )); then
        command brew "$@"
        return
    fi
    case "$1" in
        install|uninstall|list|info|gc)
            zb "$@"
            ;;
        *)
            command brew "$@"
            ;;
    esac
}

alias dwarf='open /Applications/Dwarf\ Fortress.app'

# rustup (Homebrew, keg-only)
export PATH="/opt/homebrew/opt/rustup/bin:$PATH"

export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
