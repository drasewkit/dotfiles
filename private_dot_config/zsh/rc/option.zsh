# rc/option.zsh — setopt/unsetopt, history, misc. Sourced first from .zshrc
# (must run after /etc/zshrc, which forces HISTSIZE=2000/SAVEHIST=1000).

# ---- History ----
HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt BANG_HIST EXTENDED_HISTORY SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS HIST_IGNORE_SPACE HIST_SAVE_NO_DUPS
setopt HIST_VERIFY HIST_REDUCE_BLANKS

# ---- Directory / navigation ----
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT PUSHD_TO_HOME
setopt CDABLE_VARS MULTIOS EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS RC_QUOTES COMBINING_CHARS
unsetopt CLOBBER

# ---- Jobs ----
setopt LONG_LIST_JOBS AUTO_RESUME NOTIFY
unsetopt BG_NICE HUP CHECK_JOBS MAIL_WARNING

# ---- Completion behaviour (options only; zstyles live in completion.zsh) ----
setopt COMPLETE_IN_WORD ALWAYS_TO_END PATH_DIRS
setopt AUTO_MENU AUTO_LIST AUTO_PARAM_SLASH LIST_PACKED
unsetopt MENU_COMPLETE FLOW_CONTROL

# ---- Correction / bell ----
setopt CORRECT
setopt NO_BEEP

umask 022

# Free Ctrl-S / Ctrl-Q from terminal flow control
[[ -t 0 && -t 1 ]] && stty -ixon 2>/dev/null

# Auto-quote URLs and metacharacters on paste
autoload -Uz bracketed-paste-url-magic && zle -N bracketed-paste bracketed-paste-url-magic
autoload -Uz url-quote-magic && zle -N self-insert url-quote-magic
