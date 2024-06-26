#!/bin/bash

check_brew_shellenv() {
  local homebrew_prefix_tmp=${1:-$HOMEBREW_PREFIX}
  if [ "$HOMEBREW_SHELLENV_DID_INIT" = true ]; then
    return 0
  elif [ -O "$HOMEBREW_PREFIX" ] && [ "$HOMEBREW_PREFIX" = "$homebrew_prefix_tmp" ] &&
    [ -n "$HOMEBREW_CELLAR" ] && [ "$HOMEBREW_CELLAR" = "$HOMEBREW_PREFIX/Cellar" ] &&
    [ -n "$HOMEBREW_REPOSITORY" ] && [ "$HOMEBREW_REPOSITORY" = "$HOMEBREW_PREFIX" ] &&
    echo "$PATH" | grep -q "$HOMEBREW_PREFIX/bin"; then
    HOMEBREW_SHELLENV_DID_INIT=true
    return 0
  else
    HOMEBREW_SHELLENV_DID_INIT=false
    return 1
  fi
}

# eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
# eval "$($HOMEBREW_PREFIX/bin/brew shellenv zsh)"
eval_brew_shellenv() {
  # find homebrew root directory
  local homebrew_prefix_tmp=${1:-$HOMEBREW_PREFIX}

  if check_brew_shellenv "$homebrew_prefix_tmp"; then
    unset HOMEBREW_PREFIX
    return 0
  else
    if macos; then
      UNAME_MACHINE=$(uname -m)
      if [ -n "$homebrew_prefix_tmp" ]; then
        HOMEBREW_PREFIX=$homebrew_prefix_tmp
      elif [ "$UNAME_MACHINE" = 'arm64' ]; then
        HOMEBREW_PREFIX=/opt/homebrew
      elif [ "$UNAME_MACHINE" = 'x86_64' ]; then
        HOMEBREW_PREFIX=/usr/local
      else
        echo "Unknown machine type: $UNAME_MACHINE" >&2
      fi
    elif linux; then
      HOMEBREW_PREFIX=${homebrew_prefix_tmp:-/home/linuxbrew/.linuxbrew}
    else
      echo "Unknown OS: $OSTYPE" >&2
    fi

    if [ -O "$HOMEBREW_PREFIX/bin/brew" ]; then
      export HOMEBREW_PREFIX
      export HOMEBREW_CELLAR=$HOMEBREW_PREFIX/Cellar
      export HOMEBREW_REPOSITORY=$HOMEBREW_PREFIX/Homebrew
      PATH=$(add_path_before "$PATH" "$HOMEBREW_PREFIX/sbin")
      PATH=$(add_path_before "$PATH" "$HOMEBREW_PREFIX/bin")
      MANPATH=$(add_path_before "$MANPATH" "$HOMEBREW_PREFIX/share/man")
      INFOPATH=$(add_path_before "$INFOPATH" "$HOMEBREW_PREFIX/share/info")

      HOMEBREW_SHELLENV_DID_INIT=true
      return 0
    fi
  fi

  return 1
}

# ----------

eval_brew_shellenv /opt/homebrew ||
  eval_brew_shellenv /home/linuxbrew/.linuxbrew ||
  eval_brew_shellenv "$HOME/homebrew"

# 2nd Homebrew home
if [ -d /home/linuxbrew/.linuxbrew ]; then
  export HOMEBREWALT_PREFIX=/home/linuxbrew/.linuxbrew
  export HOMEBREWALT_CELLAR="$HOMEBREWALT_PREFIX/Cellar"
  export HOMEBREWALT_REPOSITORY="$HOMEBREWALT_PREFIX"/Homebrew
  PATH=$(add_path_after "$PATH" $HOMEBREWALT_PREFIX/bin)
  PATH=$(add_path_after "$PATH" $HOMEBREWALT_PREFIX/sbin)
  [ -d $HOMEBREWALT_PREFIX/share/man ] && MANPATH=$(add_path_after "$MANPATH" $HOMEBREWALT_PREFIX/share/man)
  [ -d $HOMEBREWALT_PREFIX/share/info ] && INFOPATH=$(add_path_after "$INFOPATH" $HOMEBREWALT_PREFIX/share/info)
fi

if command -v brew >/dev/null && [ -v https_proxy ]; then
  if [ -f ${XDG_CONFIG_HOME:-$HOME/.config}/.curlrc ]; then
    export HOMEBREW_CURLRC=${XDG_CONFIG_HOME:-$HOME/.config}/.curlrc
  fi
  # export HOMEBREW_TEMP=$HOME/.tmp
  # [ ! -d "$HOMEBREW_TEMP" ] && mkdir -p "$HOMEBREW_TEMP"
fi

export PATH MANPATH INFOPATH
