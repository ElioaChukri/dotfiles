source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# Adding relevant paths to PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/go/bin:$PATH
export PATH=$HOME/.local/share/gem/ruby/3.0.0/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Keybindings
bindkey -v # vi mode 
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^ ' autosuggest-accept

# Set some environment variables
export EDITOR=nvim
export QT_QPA_PLATFORM=wayland
export XDG_SESSION_TYPE=wayland
export ZSH_AUTOSUGGEST_STRATEGY=(history)
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# Save screenshots to ~/Pictures/Screenshots
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_SCREENSHOTS_DIR="$XDG_PICTURES_DIR/Screenshots"

# Colorize sudo password prompt 
export SUDO_PROMPT="$(tput setaf 1 bold)Password:$(tput sgr0) "

# Dark mode for QT apps
export QT_STYLE_OVERRIDE=Adwaita-dark

# History
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Allow comments in interactive shell
setopt INTERACTIVE_COMMENTS

# Completion styling (make case-insensitive)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "{(s.:..)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --colour=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --colour=always $realpath'

# Add in snippets
zinit snippet OMZP::extract
zinit snippet OMZP::colored-man-pages

# Aliases
alias cl=clear
alias vim=nvim
alias du="du -h"
alias df="df -h"
alias ls="eza"
alias cat="bat --paging=always"
alias vzsh="vim ~/.zshrc"
alias szsh="source ~/.zshrc"
alias ip="ip -color"
alias myip="curl ifconfig.me"
alias "cd.."="cd .."
alias serve="python3 -m http.server"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias show="feh"
alias orphans='[[ -n $(pacman -Qdt) ]] && sudo pacman -Rs $(pacman -Qdtq) || echo "no orphans to remove"'

uniqchars() {
  if [ -z "$1" ]; then
    echo "Usage: uniqchars <string>"
    return 1
  fi
  echo "$1" | grep -o . | sort -u | wc -l
}

backup() {
  if [ -z "$1" ]; then
    echo "Usage: backup <file>"
    return 1
  fi
  cp "$1" "$1.bak"
}

# Function to decode base64 string 
b64d() {
  echo -n "$1" | base64 -d; echo
}

# Function to set the kubeconfig env var 
set-kube() {
  if [ -z "$1" ]; then 
    echo "Usage: set-kube <filename>"
    return 1
  fi
  local filename="$1"
  export KUBECONFIG=$(realpath $filename)
}

# Shell integrations
eval "$(zoxide init --cmd cd --hook pwd zsh)"
eval "$(atuin init zsh --disable-up-arrow)"

# Load completions
autoload -Uz compinit

# Enable editing command in VIM
autoload -U edit-command-line
zle -N edit-command-line
# Bind to Ctrl-x Ctrl-e (only while in INSERT mode)
bindkey '^x^e' edit-command-line

if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zinit cdreplay -q

# Check that the function `starship_zle-keymap-select()` is defined.
# xref: https://github.com/starship/starship/issues/3418
type starship_zle-keymap-select >/dev/null || \
  {
    eval "$(starship init zsh)"
  }
