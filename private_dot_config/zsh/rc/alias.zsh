# rc/alias.zsh — interactive aliases and small functions.

# Keep globbing out of these so args pass through literally.
for c (find fc scp sftp rsync locate); alias $c="noglob $c"
unset c

# ls -> eza (with fallback for machines without eza, e.g. fresh install / SSH)
if (( $+commands[eza] )); then
  alias ls='eza --group-directories-first'
  alias l='eza -1a --group-directories-first'
  alias ll='eza -l  --group-directories-first --git --icons=auto'
  alias la='eza -la --group-directories-first --git --icons=auto'
  alias lt='eza --tree --level=2 --group-directories-first --icons=auto'
else
  alias ls='ls -F'
  alias l='ls -1A'
  alias ll='ls -lh'
  alias la='ls -lhA'
fi

alias o='open'
alias df='df -kh'
alias du='du -kh'
alias dc='docker compose'
alias history-stat="history 0 | awk '{print \$2}' | sort | uniq -c | sort -nr | head"
alias zcache-clear='rm -f ${XDG_CACHE_HOME:-$HOME/.cache}/zsh/*.zsh(N) ${XDG_CACHE_HOME:-$HOME/.cache}/zsh/*.zwc(N); echo "zsh eval caches cleared"'
(( $+commands[python3] )) && alias http-serve='python3 -m http.server'

# Make a directory and cd into it.
function mkdcd { [[ -n "$1" ]] && mkdir -p "$1" && builtin cd "$1"; }
