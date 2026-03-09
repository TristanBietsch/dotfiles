#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
OS="$(uname -s)"

DRY_RUN=false
FORCE=false
VERBOSE=false

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [COMMAND]

Commands:
  install     Full install: link configs + install packages (default)
  link        Symlink config files only
  uninstall   Remove symlinks and restore backups
  brew        Install Homebrew packages from Brewfile
  packages    Install system packages

Options:
  --dry-run   Show what would happen without doing it
  --force     Overwrite without backing up
  --verbose   Print debug output
  -h, --help  Show this help
EOF
}

log_ok()   { printf "${GREEN}  [ok]${RESET} %s\n" "$1"; }
log_skip() { printf "${YELLOW}[skip]${RESET} %s\n" "$1"; }
log_back() { printf "${BLUE}[back]${RESET} %s\n" "$1"; }
log_err()  { printf "${RED} [err]${RESET} %s\n" "$1" >&2; }
log_dry()  { printf "${YELLOW} [dry]${RESET} %s\n" "$1"; }
log_dbg()  { $VERBOSE && printf "       %s\n" "$1" || true; }

detect_os() {
    case "$OS" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *)      log_err "Unsupported OS: $OS"; exit 1 ;;
    esac
}

backup_path() {
    local target="$1"
    local rel="${target#$HOME/}"
    echo "$BACKUP_DIR/$rel"
}

do_backup() {
    local target="$1"
    if [[ ! -e "$target" && ! -L "$target" ]]; then
        return
    fi
    if $FORCE; then
        log_dbg "force: skipping backup of $target"
        return
    fi
    local dest
    dest="$(backup_path "$target")"
    if $DRY_RUN; then
        log_dry "would backup $target -> $dest"
        return
    fi
    mkdir -p "$(dirname "$dest")"
    mv "$target" "$dest"
    log_back "$target -> $dest"
}

make_link() {
    local src="$1"
    local target="$2"

    if [[ -L "$target" && "$(readlink "$target")" == "$src" ]]; then
        log_skip "$target (already linked)"
        return
    fi

    if $DRY_RUN; then
        if [[ -e "$target" || -L "$target" ]]; then
            log_dry "would backup and link $target -> $src"
        else
            log_dry "would link $target -> $src"
        fi
        return
    fi

    if [[ -e "$target" || -L "$target" ]]; then
        do_backup "$target"
        if ! $FORCE; then
            : # backup already moved it
        else
            rm -rf "$target"
        fi
    fi

    mkdir -p "$(dirname "$target")"
    ln -sf "$src" "$target"
    log_ok "$target -> $src"
}

ensure_stow() {
    if ! cmd_exists stow; then
        log_err "GNU Stow is required for link/uninstall commands"
        exit 1
    fi
}

prepare_stow_conflicts() {
    local pkg_dir="$1"
    local pkg_name
    pkg_name="$(basename "$pkg_dir")"

    log_dbg "checking conflicts for package: $pkg_name"

    while IFS= read -r -d '' src_file; do
        local rel="${src_file#$pkg_dir/}"
        local target="$HOME/$rel"

        if [[ -L "$target" && "$(readlink "$target")" == "$src_file" ]]; then
            continue
        fi

        if [[ -e "$target" || -L "$target" ]]; then
            do_backup "$target"
            if $FORCE && ! $DRY_RUN; then
                rm -rf "$target"
            fi
        fi
    done < <(find "$pkg_dir" -type f -not -name '.DS_Store' -not -path '*/.git/*' -print0)
}

run_stow() {
    local pkg_dir="$1"
    local pkg_name
    pkg_name="$(basename "$pkg_dir")"
    local -a args=(--dir="$DOTFILES_DIR" --target="$HOME" --verbose=1)

    if $DRY_RUN; then
        args+=(--no)
    fi

    if $VERBOSE; then
        args+=(--verbose=2)
    fi

    stow "${args[@]}" "$pkg_name"
}

run_unstow() {
    local pkg_dir="$1"
    local pkg_name
    pkg_name="$(basename "$pkg_dir")"
    local -a args=(--dir="$DOTFILES_DIR" --target="$HOME" --verbose=1 --delete)

    if $DRY_RUN; then
        args+=(--no)
    fi

    if $VERBOSE; then
        args+=(--verbose=2)
    fi

    stow "${args[@]}" "$pkg_name"
}

# Packages to stow-link (directories with actual config content)
STOW_PACKAGES=(
    aerospace btop claude codex gh ghostty git karabiner
    lsd ncspot nvim obsidian ranger tmux w3m weather zsh
)

link_all() {
    ensure_stow
    printf "\n${BLUE}Linking configs...${RESET}\n\n"
    for pkg in "${STOW_PACKAGES[@]}"; do
        local pkg_dir="$DOTFILES_DIR/$pkg"
        [[ -d "$pkg_dir" ]] || continue
        prepare_stow_conflicts "$pkg_dir"
        run_stow "$pkg_dir"
    done
}

unlink_all() {
    ensure_stow
    printf "\n${BLUE}Unlinking configs...${RESET}\n\n"
    for pkg in "${STOW_PACKAGES[@]}"; do
        local pkg_dir="$DOTFILES_DIR/$pkg"
        [[ -d "$pkg_dir" ]] || continue
        run_unstow "$pkg_dir"
    done
}

restore_backups() {
    local latest
    latest="$(ls -dt "$HOME/.dotfiles-backup"/*/ 2>/dev/null | head -1)" || true
    if [[ -z "$latest" ]]; then
        log_skip "no backups found to restore"
        return
    fi
    printf "\n${BLUE}Restoring from $latest${RESET}\n\n"
    while IFS= read -r -d '' backup_file; do
        local rel="${backup_file#$latest}"
        local target="$HOME/$rel"
        if $DRY_RUN; then
            log_dry "would restore $backup_file -> $target"
        else
            mkdir -p "$(dirname "$target")"
            mv "$backup_file" "$target"
            log_ok "restored $target"
        fi
    done < <(find "$latest" -type f -print0)
}

cmd_exists() { command -v "$1" &>/dev/null; }

install_homebrew() {
    if ! cmd_exists brew; then
        printf "\n${BLUE}Installing Homebrew...${RESET}\n\n"
        if $DRY_RUN; then
            log_dry "would install Homebrew"
            return
        fi
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        log_ok "Homebrew installed"
    else
        log_skip "Homebrew already installed"
    fi
}

install_brew_packages() {
    local brewfile="$DOTFILES_DIR/Brewfile"
    if [[ ! -f "$brewfile" ]]; then
        log_skip "no Brewfile found"
        return
    fi
    printf "\n${BLUE}Installing Homebrew packages...${RESET}\n\n"
    if $DRY_RUN; then
        log_dry "would run: brew bundle --file=$brewfile"
        return
    fi
    brew bundle --file="$brewfile" --no-lock
    log_ok "Homebrew packages installed"
}

install_apt_packages() {
    local pkgfile="$DOTFILES_DIR/packages.txt"
    if [[ ! -f "$pkgfile" ]]; then
        log_skip "no packages.txt found"
        return
    fi
    printf "\n${BLUE}Installing apt packages...${RESET}\n\n"

    local to_install=()
    while IFS= read -r pkg; do
        pkg="${pkg%%#*}"
        pkg="$(echo "$pkg" | xargs)"
        [[ -z "$pkg" ]] && continue
        if dpkg -s "$pkg" &>/dev/null; then
            log_skip "$pkg (already installed)"
        else
            to_install+=("$pkg")
        fi
    done < "$pkgfile"

    if [[ ${#to_install[@]} -eq 0 ]]; then
        log_skip "all packages already installed"
        return
    fi

    if $DRY_RUN; then
        log_dry "would install: ${to_install[*]}"
        return
    fi

    sudo apt-get update -qq
    sudo apt-get install -y -qq "${to_install[@]}"
    log_ok "installed ${#to_install[@]} packages"
}

install_packages() {
    case "$(detect_os)" in
        macos)
            install_homebrew
            install_brew_packages
            ;;
        linux)
            install_apt_packages
            ;;
    esac
}

cmd_install() {
    link_all
    install_packages
    printf "\n${GREEN}Done.${RESET}\n"
}

cmd_link() {
    link_all
    printf "\n${GREEN}Done.${RESET}\n"
}

cmd_uninstall() {
    unlink_all
    restore_backups
    printf "\n${GREEN}Done.${RESET}\n"
}

cmd_brew() {
    install_homebrew
    install_brew_packages
    printf "\n${GREEN}Done.${RESET}\n"
}

cmd_packages() {
    install_packages
    printf "\n${GREEN}Done.${RESET}\n"
}

COMMAND="install"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)  DRY_RUN=true ;;
        --force)    FORCE=true ;;
        --verbose)  VERBOSE=true ;;
        -h|--help)  usage; exit 0 ;;
        install|link|uninstall|brew|packages)
            COMMAND="$1" ;;
        *)
            log_err "unknown option: $1"
            usage
            exit 1
            ;;
    esac
    shift
done

printf "${BLUE}dotfiles${RESET} — %s on %s\n" "$COMMAND" "$(detect_os)"
$DRY_RUN && printf "${YELLOW}(dry run)${RESET}\n"

"cmd_$COMMAND"
