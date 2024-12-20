#!/bin/bash
export MISE_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mise/${OSDIR:?}"

if ! command -v mise >/dev/null; then
  return
fi

## eval "$(mise activate bash)"
export MISE_SHELL=bash
export __MISE_ORIG_PATH="$PATH"

mise() {
  local command
  command="${1:-}"
  if [ "$#" = 0 ]; then
    command mise
    return
  fi
  shift

  case "$command" in
  deactivate | shell | sh)
    # if argv doesn't contains -h,--help
    if [[ ! " $* " =~ " --help " ]] && [[ ! " $* " =~ " -h " ]]; then
      eval "$(command mise "$command" "$@")"
      return $?
    fi
    ;;
  esac
  command mise "$command" "$@"
}

_mise_hook() {
  local previous_exit_status=$?
  eval "$(mise hook-env -s bash)"
  return $previous_exit_status
}
if [[ ";${PROMPT_COMMAND:-};" != *";_mise_hook;"* ]]; then
  PROMPT_COMMAND="_mise_hook${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
fi
if [ -z "${_mise_cmd_not_found:-}" ]; then
  _mise_cmd_not_found=1
  if [ -n "$(declare -f command_not_found_handle)" ]; then
    _mise_cmd_not_found_handle=$(declare -f command_not_found_handle)
    eval "${_mise_cmd_not_found_handle/command_not_found_handle/_command_not_found_handle}"
  fi

  command_not_found_handle() {
    if mise hook-not-found -s bash -- "$1"; then
      _mise_hook
      "$@"
    elif [ -n "$(declare -f _command_not_found_handle)" ]; then
      _command_not_found_handle "$@"
    else
      echo "bash: command not found: $1" >&2
      return 127
    fi
  }
fi
## end eval
