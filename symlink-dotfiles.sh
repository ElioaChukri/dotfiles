#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
BACKUP=true
BACKUP_DIR="${HOME}/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
TPM_URL="https://github.com/tmux-plugins/tpm"
TPM_DEST="$HOME/.tmux/plugins/tpm"


# Format: "source_path target_path"
# For tmux we must specify the full path to avoid symlinking the entire tmux directory which contains plugins that shouldn't be in the repo
# For sway, we have an output file specific for each device, so we only link the config file and not the entire sway directory
# For zsh, we must link the individual files to allow for machine-specific files alongside our files
declare -a LINKS=(
    "alacritty                      ~/.config/alacritty"
    "fuzzel                         ~/.config/fuzzel"
    "starship/starship.toml         ~/.config/starship.toml"
    "sway/config                    ~/.config/sway/config"
    "swaylock                       ~/.config/swaylock"
    "swaynag                        ~/.config/swaynag"
    "swaync                         ~/.config/swaync"
    "tmux/tmux.conf                 ~/.config/tmux/tmux.conf"
    "waybar                         ~/.config/waybar"
    "zsh/.zshenv                    ~/.zshenv"
    "zsh/.zshrc                     ~/.config/zsh/.zshrc"
    "zsh/aliases.zsh                ~/.config/zsh/aliases.zsh"
    "zsh/env.zsh                    ~/.config/zsh/env.zsh"
    "zsh/functions.zsh              ~/.config/zsh/functions.zsh"
)

log()    { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }
ok()     { printf '[\033[32mOK\033[0m]  %s\n' "$*"; }
warn()   { printf '[\033[33mWARN\033[0m] %s\n' "$*"; }
err()    { printf '[\033[31mERR\033[0m] %s\n' "$*" >&2; }
dry()    { printf '[\033[36mDRY\033[0m] %s\n' "$*"; }

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -n, --dry-run     Print actions without executing
  -b, --no-backup   Skip backup of existing files before replacing
  -h, --help        Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run)   DRY_RUN=true ;;
        -b|--no-backup) BACKUP=false ;;
        -h|--help)      usage; exit 0 ;;
        *) err "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done

ensure_cmd() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        err "Required command not found: $cmd"
        exit 1
    fi
}

link_file() {
    local src="$1"
    local target="$2"

    src="${DOTFILES_DIR}/${src}"
    
    # Need to manually expand ~ in quotes
    target="${target/#\~/$HOME}"

    if [[ ! -e "$src" ]]; then
        err "Source missing: $src"
        return 1
    fi

    local target_dir
    target_dir="$(dirname "$target")"

    if "$DRY_RUN"; then
        dry "mkdir -p $target_dir"
        dry "ln -sfn $src -> $target"
        return 0
    fi

    mkdir -p "$target_dir"

    # Backup existing non-symlink files/dirs
    if [[ -e "$target" && ! -L "$target" ]]; then
        if "$BACKUP"; then
            mkdir -p "$BACKUP_DIR"
            mv "$target" "${BACKUP_DIR}/$(basename "$target")"
            warn "Backed up existing: $target -> $BACKUP_DIR"
        else
            rm -rf "$target"
            warn "Removed existing: $target"
        fi
    fi

    ln -sfn "$src" "$target"
    ok "$target -> $src"
}

install_tpm() {
    log "Installing Tmux Plugin Manager"

    if [[ -d "$TPM_DEST" ]]; then
        log "TPM already exists at $TPM_DEST, skipping clone"
        return 0
    fi

    if "$DRY_RUN"; then 
        dry "git clone $TPM_URL $TPM_DEST"
        return 0
    fi

    git clone "$TPM_URL" "$TPM_DEST"
}

log "Dotfiles dir: $DOTFILES_DIR"
"$DRY_RUN" && log "Dry run mode — no changes will be made"

ensure_cmd git 

failed=0
for entry in "${LINKS[@]}"; do
    read -r src target <<< "$entry"
    link_file "$src" "$target" || (( failed++ )) || true
done

if (( failed > 0 )); then
    err "$failed link(s) failed"
    exit 1
fi

install_tpm

log "Done"
