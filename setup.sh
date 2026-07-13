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
MISE_BIN=""
if command -v mise &> /dev/null; then
  MISE_BIN=$(command -v mise)
elif [ -f "$HOME/.local/bin/mise" ]; then
  MISE_BIN="$HOME/.local/bin/mise"
elif [ -f "$HOME/.local/share/mise/bin/mise" ]; then
  MISE_BIN="$HOME/.local/share/mise/bin/mise"
fi

if [ -z "$MISE_BIN" ]; then
  echo "Installing mise-en-place..."
  curl https://mise.run | sh
  # Resolve path after installing
  if [ -f "$HOME/.local/bin/mise" ]; then
    MISE_BIN="$HOME/.local/bin/mise"
  elif [ -f "$HOME/.local/share/mise/bin/mise" ]; then
    MISE_BIN="$HOME/.local/share/mise/bin/mise"
  fi
else
  echo "mise-en-place is already installed."
fi

# 3. Temporarily add mise to PATH for the rest of this setup script
if [ -n "$MISE_BIN" ]; then
  export PATH="$(dirname "$MISE_BIN"):$PATH"
fi


# 4. Clean up conflicting physical files/folders in home directory (back them up if they exist and are not symlinks)
echo "Checking for conflicting physical configurations in home directory..."
for pkg in */; do
  pkg=${pkg%/}
  # Skip non-directories or hidden folders (like .git)
  if [ ! -d "$pkg" ] || [[ "$pkg" == .* ]]; then
    continue
  fi
  
  # Find all files/directories in this package and check their matching paths in $HOME
  find "$pkg" -mindepth 1 | while read -r path; do
    rel_path=${path#$pkg/}
    target_path="$HOME/$rel_path"
    
    # If the target exists and is a physical file or folder (not a symlink)
    if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
      # If it's a directory, only back it up if it's a leaf/target directory in our stow config, 
      # or if the repository contains it as a file. If it's just a parent folder (like .config), 
      # Stow will merge it, so we don't back up parent folders.
      if [ -d "$target_path" ] && [ -d "$path" ]; then
        # Check if the repository path contains files directly (meaning it's a leaf target directory)
        # or if we want to merge it. We only back up if we are stowing the entire directory.
        # Generally, backing up directories like .config/nvim is safe, but we shouldn't back up ~/.config itself.
        # We can identify leaf directories by checking if their parent directory in the repo is the package root.
        if [ "$(dirname "$rel_path")" = "." ]; then
          echo "Backing up physical directory $target_path to $target_path.bak..."
          mv "$target_path" "$target_path.bak"
        fi
      elif [ -f "$target_path" ]; then
        echo "Backing up physical file $target_path to $target_path.bak..."
        mkdir -p "$(dirname "$target_path.bak")"
        mv "$target_path" "$target_path.bak"
      fi
    fi
  done
done

# 5. Stow dotfiles (runs Makefile to link all configurations, including mise config.toml)
echo "Stowing configurations..."
if [ -f "makefile" ] || [ -f "Makefile" ]; then
  make
else
  stow --verbose --target="$HOME" --restow */
fi

# 6. Install all configured tools in ~/.config/mise/config.toml (tmux, ripgrep, lazygit, neovim)
if command -v mise &> /dev/null; then
  echo "Installing tools via mise..."
  mise install --yes
else
  echo "Error: mise command not found, cannot install tools automatically."
fi

# 7. Set fish as the default shell if available
if command -v fish &> /dev/null; then
  FISH_PATH=$(command -v fish)
  if [ "$SHELL" != "$FISH_PATH" ]; then
    echo "Setting fish as the default shell..."
    sudo chsh -s "$FISH_PATH" "$(whoami)" || chsh -s "$FISH_PATH" || true
  fi
fi

echo "=== Dotfiles setup complete! ==="

