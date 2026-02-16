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
