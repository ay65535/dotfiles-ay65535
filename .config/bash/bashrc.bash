if [ ! -d "$XDG_STATE_HOME"/bash ]; then
  mkdir -p "$XDG_STATE_HOME"/bash
fi
export HISTFILE="$XDG_STATE_HOME/bash/history"
export BASH_COMPLETION_USER_FILE="$XDG_CONFIG_HOME/bash-completion/bash_completion"

if [ -n "$http_proxy" ]; then
  echo "proxy=$http_proxy" >"$HOME/curlrc"
else
  test -f "$HOME/curlrc" && rm "$HOME/curlrc"
fi
