# rc/pluginconfig/nvm.zsh — lazy-load nvm.
# Eager `source nvm.sh` costs ~184ms (nvm_auto resolving lts/*). Instead, stub the
# entrypoints; the first call loads the real nvm/node and re-execs itself.
# Migration to mise is a separate future task.

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] || return

_load_nvm() {
  unset -f nvm node npm npx
  source "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
}
nvm()  { _load_nvm; nvm "$@"; }
node() { _load_nvm; node "$@"; }
npm()  { _load_nvm; npm "$@"; }
npx()  { _load_nvm; npx "$@"; }
