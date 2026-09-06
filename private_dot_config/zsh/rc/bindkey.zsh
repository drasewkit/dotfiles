# rc/bindkey.zsh — sourced before sheldon. emacs keymap + core widgets.
# zeno keybindings are applied later in rc/pluginconfig/zeno.zsh.

bindkey -e

# Application mode: makes $terminfo key sequences valid while ZLE is active.
function zle-line-init   { (( $+terminfo[smkx] )) && echoti smkx; }
function zle-line-finish { (( $+terminfo[rmkx] )) && echoti rmkx; }
zle -N zle-line-init
zle -N zle-line-finish

# Navigation — bind both CSI (normal) and SS3 (application-mode) forms.
bindkey '^[[H' beginning-of-line   ; bindkey '^[OH' beginning-of-line
bindkey '^[[F' end-of-line         ; bindkey '^[OF' end-of-line
bindkey '^[[1~' beginning-of-line  ; bindkey '^[[4~' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word     ; bindkey '^[[1;3C' forward-word
bindkey '^[[1;5D' backward-word    ; bindkey '^[[1;3D' backward-word
bindkey '^[[3;5~' kill-word

# Edit the current command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# History: prefix search (line start .. cursor) on Up/Down and ^p/^n.
# Full-history fuzzy search stays on ^r via zeno.
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end  history-search-end
bindkey '^[[A' history-beginning-search-backward-end
bindkey '^[OA' history-beginning-search-backward-end
bindkey '^[[B' history-beginning-search-forward-end
bindkey '^[OB' history-beginning-search-forward-end
bindkey '^p'   history-beginning-search-backward-end
bindkey '^n'   history-beginning-search-forward-end

# ghq + fzf repository jump (Ctrl-]) — widget defined in rc/functions/ghq-fzf
zle -N ghq-fzf
bindkey '^]' ghq-fzf
