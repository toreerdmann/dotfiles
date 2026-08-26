#!/usr/bin/env bash
set -e

echo "=== Starting dotfiles setup ==="

# 1. Install system prerequisites if needed (stow and fish)
if ! command -v stow &> /dev/null || ! command -v fish &> /dev/null || ! command -v zsh &> /dev/null; then
  echo "Prerequisites (stow/fish/zsh) missing. Attempting to install..."
  if command -v apt-get &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y stow fish zsh
  else
    echo "Warning: apt-get not found. Please ensure 'stow', 'fish' and 'zsh' are installed manually."
  fi
fi

# Install luarocks if not already installed
if ! command -v luarocks &> /dev/null; then
  echo "luarocks missing. Attempting to install..."
  if command -v apt-get &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y luarocks
  elif command -v brew &> /dev/null; then
    brew install luarocks
  else
    echo "Warning: Package manager not found. Please install 'luarocks' manually."
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

    # Skip if any parent directory of target_path is a symlink (meaning stow already links a parent folder)
    is_inside_symlink=false
    current_dir=$(dirname "$target_path")
    while [ "$current_dir" != "$HOME" ] && [ "$current_dir" != "/" ]; do
      if [ -L "$current_dir" ]; then
        is_inside_symlink=true
        break
      fi
      current_dir=$(dirname "$current_dir")
    done
    if [ "$is_inside_symlink" = true ]; then
      continue
    fi
    
    # If the target exists and is a physical file or folder (not a symlink)
    if [ -e "$target_path" ] && [ ! -L "$target_path" ]; then
      # If it's a directory, only back it up if it's a leaf/target directory in our stow config, 
      # or if the repository contains it as a file. If it's just a parent folder (like .config), 
      # Stow will merge it, so we don't back up parent folders.
      if [ -d "$target_path" ] && [ -d "$path" ]; then
        # Skip backing up shared/system parent directories
        if [ "$rel_path" = ".config" ] || [ "$rel_path" = ".local" ] || [ "$rel_path" = ".local/share" ]; then
          continue
        fi

        # Only back up directories whose parent is .config or the home directory (.)
        parent_dir=$(dirname "$rel_path")
        if [ "$parent_dir" = ".config" ] || [ "$parent_dir" = "." ]; then
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

# 6a. Install tmux plugins non-interactively so a fresh machine doesn't need
#     a manual `prefix + I`.
if [ -d "$HOME/.local/share/mise/shims" ]; then
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi
if command -v tmux &> /dev/null; then
  # Test for the tpm script itself, not just the directory: a failed clone
  # leaves an empty dir behind, which a -d test happily accepts forever.
  if [ ! -f "$HOME/.tmux/plugins/tpm/tpm" ]; then
    echo "Installing tpm..."
    rm -rf "$HOME/.tmux/plugins/tpm"
    git clone --depth 1 --quiet https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" || true
  fi
  if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
    echo "Installing tmux plugins..."
    "$HOME/.tmux/plugins/tpm/bin/install_plugins" || true
  fi
else
  echo "tmux not found, skipping tmux plugin install."
fi

# 6b. Install oh-my-zsh and the zsh plugins referenced by .zshrc
if command -v zsh &> /dev/null; then
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
  fi

  ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  mkdir -p "$ZSH_CUSTOM_DIR/plugins"
  for repo in \
    "https://github.com/zsh-users/zsh-autosuggestions zsh-autosuggestions" \
    "https://github.com/zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting" \
    "https://github.com/Aloxaf/fzf-tab fzf-tab"; do
    set -- $repo
    url=$1
    name=$2
    dest="$ZSH_CUSTOM_DIR/plugins/$name"
    if [ -d "$dest/.git" ]; then
      echo "Updating $name..."
      git -C "$dest" pull --quiet --ff-only || true
    elif [ ! -d "$dest" ]; then
      echo "Installing $name..."
      git clone --depth 1 --quiet "$url" "$dest" || true
    fi
  done
else
  echo "zsh not found, skipping oh-my-zsh plugin setup."
fi

# 7. Hook the remote-session snippet into bash/zsh so SSH logins land in
#    tmux + fish without changing the login shell.
HOOK_MARKER="# >>> dotfiles remote-session >>>"
HOOK_LINE='[ -f "$HOME/.config/shell/remote-session.sh" ] && . "$HOME/.config/shell/remote-session.sh"'
# (.zshrc is stowed from this repo and already sources the snippet itself,
#  so only ~/.bashrc needs patching here.)
for rc in "$HOME/.bashrc"; do
  if [ -e "$rc" ] && grep -qF "$HOOK_MARKER" "$rc"; then
    echo "Remote-session hook already present in $rc"
    continue
  fi
  echo "Adding remote-session hook to $rc..."
  {
    echo ""
    echo "$HOOK_MARKER"
    echo "$HOOK_LINE"
    echo "# <<< dotfiles remote-session <<<"
  } >> "$rc"
done

# 8. Pick a default login shell.
#    Codespaces gets zsh: a non-POSIX login shell breaks the VS Code Remote-SSH
#    / Codespaces server bootstrap, and the plugins installed above give zsh the
#    fish-style editing anyway. Everywhere else, fish.
#    Override with DOTFILES_SHELL=/path/to/shell, or DOTFILES_SHELL=none to
#    leave the login shell alone entirely.
if [ -n "${DOTFILES_SHELL:-}" ]; then
  TARGET_SHELL="$DOTFILES_SHELL"
elif [ "${CODESPACES:-}" = "true" ]; then
  TARGET_SHELL=$(command -v zsh || true)
else
  TARGET_SHELL=$(command -v fish || true)
fi

if [ "$TARGET_SHELL" = "none" ]; then
  echo "Leaving default login shell as $SHELL (DOTFILES_SHELL=none)."
elif [ -n "$TARGET_SHELL" ] && [ "$SHELL" != "$TARGET_SHELL" ]; then
  echo "Setting $TARGET_SHELL as the default shell..."
  sudo chsh -s "$TARGET_SHELL" "$(whoami)" || chsh -s "$TARGET_SHELL" || true
fi

echo "=== Dotfiles setup complete! ==="

