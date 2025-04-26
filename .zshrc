# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

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

# Add in powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

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
export ZSH_COLORIZE_STYLE="dracula"
export QT_STYLE_OVERRIDE=Adwaita-Dark

# Colorize sudo password prompt 
export SUDO_PROMPT="$(tput setaf 1 bold)Password:$(tput sgr0) "


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
alias sploit="searchsploit"
alias ffuf="ffuf -c"
alias linkfinder="python -W ignore /usr/share/linkfinder/linkfinder.py"
alias httpx="httpx-pd"
alias protonconnect="sudo openvpn /home/tek/Desktop/Cybersec/proton.tcp.ovpn"
alias serve="python3 -m http.server"
alias rustscan='sudo docker run -it --rm --name rustscan rustscan/rustscan:2.1.1'
alias nethogs="bandwhich"
alias tldr="tldr --pager"
alias tk="please"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias mvso="mv ./target/release/libdistances.so ./rust-src"
alias show="feh"

# Function to decode base64 string 
b64d() {
  echo -n "$1" | base64 -d; echo
}

mvscreenshot() {
  screenshot=$(ls -lh ~/Pictures/Screenshots/ | tail -n 1 | grep -Eoi "screenshot.*[^']")
  mv ~/Pictures/Screenshots/${screenshot} "$1"
}

auth_twitter() {
  user="$1"
  case $user in
    "chixteer")
      full_file=/home/tek/Desktop/Work/X/${user}_credentials
      jq_key='.oauth2_tokens.chixteer.oauth2.access_token'
      ;;
    "test")
      full_file=/home/tek/Desktop/Work/X/${user}_credentials
      jq_key='.oauth2_tokens.chixteer_test0.oauth2.access_token'
      ;;
    *)
      echo "Invalid user"
      echo "Usage: auth_twitter <user>"
      echo "Valid users: chixteer, test"
      return 1
      ;;
  esac
  if ! [ -f $full_file ]; then
    echo "File not found"
    return 1
  fi
  source $full_file
  xurl auth oauth2
  echo -n "OAuth2 Token: "
  cat ~/.xurl | jq -r $jq_key
}

# Shell integrations
# eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd --hook pwd zsh)"
eval "$(atuin init zsh --disable-up-arrow)"

# Load completions
autoload -U compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

