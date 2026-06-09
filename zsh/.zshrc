source ~/dotfiles/zsh/path.zsh
source ~/dotfiles/zsh/options.zsh
source ~/dotfiles/zsh/completion.zsh
source ~/dotfiles/zsh/fzf.zsh
source ~/dotfiles/zsh/plugins.zsh
source ~/dotfiles/zsh/aliases.zsh
source ~/dotfiles/zsh/env.zsh

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi


export PATH=$PATH:~/.o3-cli/bin
