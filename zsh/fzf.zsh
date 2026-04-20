if [[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/completion.zsh
fi

if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
fi

if command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git/*' --follow"
fi

if command -v bat >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --style=numbers --color=always --line-range :500 {}'"
fi

# fzf-tab
if [[ -f /opt/homebrew/share/fzf-tab/fzf-tab.plugin.zsh ]]; then
  source /opt/homebrew/share/fzf-tab/fzf-tab.plugin.zsh
fi

zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border
