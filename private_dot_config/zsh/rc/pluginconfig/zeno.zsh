# rc/pluginconfig/zeno.zsh — sourced after sheldon (ZENO_LOADED must be set).

export ZENO_HOME="$XDG_CONFIG_HOME/zeno"
export ZENO_GIT_CAT="bat --color=always"
export ZENO_GIT_TREE="eza --tree"

if [[ -n $ZENO_LOADED ]]; then
  bindkey ' '    zeno-auto-snippet
  bindkey '^m'   zeno-auto-snippet-and-accept-line
  bindkey '^i'   zeno-completion
  bindkey '^xx'  zeno-insert-snippet
  bindkey '^x '  zeno-insert-space
  bindkey '^x^m' accept-line
  bindkey '^x^z' zeno-toggle-auto-snippet
  bindkey '^r'   zeno-smart-history-selection
fi
