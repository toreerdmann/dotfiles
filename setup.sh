#!/usr/bin/env bash
set -e

echo "=== Starting dotfiles setup ==="

# 1. Install system prerequisites if needed (stow and fish)
if ! command -v stow &> /dev/null || ! command -v fish &> /dev/null; then
  echo "Prerequisites (stow/fish) missing. Attempting to install..."
  if command -v apt-get &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y stow fish
  else
    echo "Warning: apt-get not found. Please ensure 'stow' and 'fish' are installed manually."
  fi
fi

# 2. Install mise-en-place if not already installed
MISE_BIN="$HOME/.local/share/mise/bin/mise"
if ! command -v mise &> /dev/null && [ ! -f "$MISE_BIN" ]; then
  echo "Installing mise-en-place..."
  curl https://mise.run | sh
else
  echo "mise-en-place is already installed."
fi

# 3. Temporarily add mise to PATH for the rest of this setup script
if [ -f "$MISE_BIN" ]; then
  export PATH="$HOME/.local/share/mise/bin:$PATH"
fi

# 4. Stow dotfiles (runs Makefile to link all configurations, including mise config.toml)
echo "Stowing configurations..."
if [ -f "makefile" ] || [ -f "Makefile" ]; then
  make
else
  stow --verbose --target="$HOME" --restow */
fi

# 5. Install all configured tools in ~/.config/mise/config.toml (tmux, ripgrep, lazygit, neovim)
if command -v mise &> /dev/null; then
  echo "Installing tools via mise..."
  mise install --yes
else
  echo "Error: mise command not found, cannot install tools automatically."
fi

echo "=== Dotfiles setup complete! ==="
