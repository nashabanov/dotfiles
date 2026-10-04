if command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git/*' --follow"
fi

if command -v bat >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --style=numbers --color=always --line-range :500 {}'"
fi

# Use the mise-selected binary instead of Homebrew-specific shell paths.
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

if [[ -n ${HOMEBREW_PREFIX:-} && -f "$HOMEBREW_PREFIX/share/fzf-tab/fzf-tab.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/fzf-tab/fzf-tab.zsh"
fi

zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border
