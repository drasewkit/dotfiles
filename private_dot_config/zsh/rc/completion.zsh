# rc/completion.zsh — sourced from .zshrc AFTER sheldon (so zsh-completions is on
# fpath) and AFTER rc/functions is added to fpath.

# LS_COLORS is not set on macOS by default; provide a basic palette for list-colors.
export LS_COLORS="${LS_COLORS:-di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07}"

autoload -Uz compinit
_zcd="$ZDOTDIR/.zcompdump"
if [[ -n ${_zcd}(#qN.mh+20) ]]; then
  compinit -i -d "$_zcd"
else
  compinit -C -d "$_zcd"
fi
unset _zcd

# Byte-compile the dump in the background for faster next start.
{
  local zcd="$ZDOTDIR/.zcompdump"
  if [[ -s "$zcd" && ( ! -s "$zcd.zwc" || "$zcd" -nt "$zcd.zwc" ) ]]; then
    zcompile "$zcd"
  fi
} &!

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list \
  'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
  'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:corrections'  format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:messages'     format ' %F{purple}-- %d --%f'
zstyle ':completion:*:warnings'     format ' %F{red}-- no matches --%f'

zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:approximate:*' max-errors 2 numeric

zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,command -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
