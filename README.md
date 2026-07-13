# Dotfiles

My personal dotfiles managed with GNU Stow and mise-en-place.

## Automatic Setup (GitHub Codespaces)

When you clone this repository into a GitHub Codespaces instance or configure it as your dotfiles repository in GitHub settings, the [setup.sh](file:///Users/tore.erdmann/dotfiles/setup.sh) script will execute automatically. 

It handles:
1. Installing GNU Stow and the `fish` shell.
2. Installing `mise` (if not already installed).
3. Backing up conflicting physical configs to resolve stow clashes.
4. Symlinking all configuration directories to your home directory (using the `Makefile` and `stow`).
5. Installing all configured tools from `mise.toml` (`tmux`, `ripgrep`, `lazygit`, and `neovim`).
6. Setting the default system shell to `fish`.

## Manual Setup

To bootstrap this setup manually on a new machine:

1. Clone this repository:
   ```bash
   git clone https://github.com/tore-erdmann/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. Run the setup script:
   ```bash
   ./setup.sh
   ```

## Shells Configuration

Both Zsh and Fish shells are configured to automatically load `mise`:
- **Zsh**: Configured in [zsh/.zshrc](file:///Users/tore.erdmann/dotfiles/zsh/.zshrc)
- **Fish**: Configured in [fish/.config/fish/config.fish](file:///Users/tore.erdmann/dotfiles/fish/.config/fish/config.fish)

To switch to Fish, simply execute `fish` or set it as your default shell.

## Managing Tools with Mise

Tools are declared in [mise/.config/mise/config.toml](file:///Users/tore.erdmann/dotfiles/mise/.config/mise/config.toml). You can add, remove, or pin tool versions there.

To install a new tool globally via `mise`:
```bash
mise use -g <tool>@latest
```
To update all tools:
```bash
mise upgrade
```

