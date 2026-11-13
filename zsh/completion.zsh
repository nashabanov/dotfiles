if [[ -n ${HOMEBREW_PREFIX:-} ]]; then
  if [[ -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]]; then
    fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
  fi

  if [[ -d "$HOMEBREW_PREFIX/share/zsh-completions" ]]; then
    fpath=("$HOMEBREW_PREFIX/share/zsh-completions" $fpath)
  fi
fi
if [[ -d "$DOTFILES_ZSH_DIR/completions" ]]; then
  fpath=("$DOTFILES_ZSH_DIR/completions" $fpath)
fi
typeset -U fpath

autoload -Uz compinit
compinit -C

# Register generated completions even when compinit reuses an older dump.
for completion_command in mise bat fd rg uv uvx eza gh ruff golangci-lint; do
  if [[ -f "$DOTFILES_ZSH_DIR/completions/_$completion_command" ]]; then
    autoload -Uz "_$completion_command"
    compdef "_$completion_command" "$completion_command"
  fi
done
unset completion_command

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' format '%F{yellow}-- %d --%f'

setopt AUTO_MENU
setopt COMPLETE_IN_WORD
