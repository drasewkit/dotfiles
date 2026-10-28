# rc/pluginconfig/mise.zsh — mise (Ruby etc.). activate output is cached like starship.
(( $+commands[mise] )) || return
_zcache mise 'mise activate zsh' "$commands[mise]"
