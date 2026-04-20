if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi

if [[ -d /opt/homebrew/share/zsh-completions ]]; then
  fpath=(/opt/homebrew/share/zsh-completions $fpath)
fi

autoload -Uz compinit
compinit -C

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' format '%F{yellow}-- %d --%f'

setopt AUTO_MENU
setopt COMPLETE_IN_WORD
