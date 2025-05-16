[ -z "$SHENV_READ" -a -f "$HOME/.sh_env" ] && . "$HOME/.sh_env"

if [ -n "$SSH_AUTH_SOCK" ]; then
  systemctl --user import-environment SSH_AUTH_SOCK
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
fi
