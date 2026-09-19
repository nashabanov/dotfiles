if (( ! $+commands[brew] )); then
  for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$brew_path" ]]; then
      path=("${brew_path:h}" $path)
      break
    fi
  done
fi

if (( $+commands[brew] )) && HOMEBREW_PREFIX="$(brew --prefix 2>/dev/null)"; then
  export HOMEBREW_PREFIX
  path=("$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin" $path)
fi

path=("$HOME/.local/bin" "$HOME/.o3-cli/bin" $path)
typeset -U path
