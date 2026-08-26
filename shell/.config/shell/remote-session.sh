# Sourced from ~/.bashrc / ~/.zshrc. On an interactive SSH session (e.g. a
# GitHub Codespace) attach to tmux straight away, so logging in gets you the
# full setup in one hop instead of typing `tmux` every time.

# Interactive shells only.
case $- in
    *i*) ;;
    *) return ;;
esac

# Already inside tmux -- nothing to do.
[ -n "$TMUX" ] && return

# Only for remote sessions, and never inside the VS Code integrated terminal.
[ -z "$SSH_CONNECTION$SSH_TTY" ] && return
[ -n "$VSCODE_INJECTION" ] && return
[ "$TERM_PROGRAM" = "vscode" ] && return

# If the login shell is not zsh (Codespaces defaults to bash), make sure the
# tmux panes still come up as zsh.
if command -v tmux >/dev/null 2>&1; then
    if command -v zsh >/dev/null 2>&1; then
        SHELL=$(command -v zsh)
        export SHELL
    fi
    exec tmux new-session -A -s main
elif [ -n "$SHELL" ] && [ "${SHELL##*/}" != "zsh" ] && command -v zsh >/dev/null 2>&1; then
    exec zsh -l
fi
