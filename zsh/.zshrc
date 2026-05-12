# =================================================================================
#                                     Zinit
# =================================================================================

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

# =================================================================================
#                                     PATH
# =================================================================================

export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/go/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH

# =================================================================================
#                               Completions 
# =================================================================================

zinit light zsh-users/zsh-completions

# Load completions
autoload -Uz compinit

_zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ ! -f "$_zcompdump" || -n "$_zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zinit cdreplay -q

# Completion styling (make case-insensitive)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

# Add in snippets
zinit snippet OMZP::extract
zinit snippet OMZP::colored-man-pages


# =================================================================================
#                                   ZSH Plugins
# =================================================================================

zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-syntax-highlighting

# =================================================================================
#                                   Keybinds
# =================================================================================

# Needed to enable edit-command-line
autoload -U edit-command-line
zle -N edit-command-line

bindkey -v # vi mode 
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^ ' autosuggest-accept # Ctrl-Space
bindkey '^x^e' edit-command-line # Ctrl-x Ctrl-e to edit command in vim


# =================================================================================
#                                   History
# =================================================================================

HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE

# Share history across all active zsh sessions in real time
setopt sharehistory

# Don't save commands prefixed with a space 
setopt hist_ignore_space

# Remove older duplicate entries, keeping only the most recent
setopt hist_ignore_all_dups

# When searching history, skip duplicate entries
setopt hist_find_no_dups

# Allow inline comments with # in interactive shell
setopt interactive_comments

# Save timestamp and elapsed time for each command in history
setopt extended_history

# =================================================================================
#                                 Integrations
# =================================================================================

eval "$(zoxide init --cmd cd --hook pwd zsh)"
eval "$(atuin init zsh --disable-up-arrow)"

# Check kubectl presence before loading completions (using cache for faster startup)
if command -v kubectl > /dev/null 2>&1; then
  _kube_comp="${XDG_CACHE_HOME:-$HOME/.cache}/kubectl_completion.zsh"
  [[ -f "$_kube_comp" ]] || kubectl completion zsh > "$_kube_comp"
  source "$_kube_comp"
fi

# Fzf integration
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --colour=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --colour=always $realpath'

# Starship prompt
# Check that the function `starship_zle-keymap-select()` is defined.
# xref: https://github.com/starship/starship/issues/3418
type starship_zle-keymap-select >/dev/null || \
  {
    eval "$(starship init zsh)"
  }

# =================================================================================
#                                 Includes
# =================================================================================

for f in "$ZDOTDIR"/*.zsh; do 
  source "$f"
done
