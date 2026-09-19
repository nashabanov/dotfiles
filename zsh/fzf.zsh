if [[ -n ${HOMEBREW_PREFIX:-} ]]; then
  fzf_shell_dir="$HOMEBREW_PREFIX/opt/fzf/shell"
  if [[ -f "$fzf_shell_dir/completion.zsh" ]]; then
    source "$fzf_shell_dir/completion.zsh"
  fi

  if [[ -f "$fzf_shell_dir/key-bindings.zsh" ]]; then
    source "$fzf_shell_dir/key-bindings.zsh"
  fi
fi

if command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git/*' --follow"
fi

if command -v bat >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --style=numbers --color=always --line-range :500 {}'"
fi

if [[ -n ${HOMEBREW_PREFIX:-} && -f "$HOMEBREW_PREFIX/share/fzf-tab/fzf-tab.plugin.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/fzf-tab/fzf-tab.plugin.zsh"
fi

zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border
