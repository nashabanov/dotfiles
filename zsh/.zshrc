typeset -g DOTFILES_ZSH_DIR="${${(%):-%N}:A:h}"

source "$DOTFILES_ZSH_DIR/path.zsh"
source "$DOTFILES_ZSH_DIR/options.zsh"
source "$DOTFILES_ZSH_DIR/completion.zsh"
source "$DOTFILES_ZSH_DIR/fzf.zsh"
source "$DOTFILES_ZSH_DIR/plugins.zsh"
source "$DOTFILES_ZSH_DIR/aliases.zsh"
source "$DOTFILES_ZSH_DIR/env.zsh"

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
