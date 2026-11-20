#!/usr/bin/env bash
set -euo pipefail

# Available Nerd Fonts mapping: key -> Name in Nerd Fonts releases -> Homebrew cask
declare -A FONT_NAMES=(
  ["jetbrainsmono"]="JetBrainsMono"
  ["firacode"]="FiraCode"
  ["iosevka"]="Iosevka"
  ["iosevkaterm"]="IosevkaTerm"
  ["hack"]="Hack"
  ["cascadiacode"]="CascadiaCode"
  ["meslo"]="Meslo"
  ["monaspace"]="Monaspace"
  ["geistmono"]="GeistMono"
  ["victormono"]="VictorMono"
  ["sourcecodepro"]="SourceCodePro"
)

declare -A CASKS=(
  ["jetbrainsmono"]="font-jetbrains-mono-nerd-font"
  ["firacode"]="font-fira-code-nerd-font"
  ["iosevka"]="font-iosevka-nerd-font"
  ["iosevkaterm"]="font-iosevka-term-nerd-font"
  ["hack"]="font-hack-nerd-font"
  ["cascadiacode"]="font-cascadia-code-nerd-font"
  ["meslo"]="font-meslo-lg-nerd-font"
  ["monaspace"]="font-monaspace-nerd-font"
  ["geistmono"]="font-geist-mono-nerd-font"
  ["victormono"]="font-victor-mono-nerd-font"
  ["sourcecodepro"]="font-sauce-code-pro-nerd-font"
)

# Detect OS and font directory
OS="$(uname -s)"
if [ "$OS" = "Darwin" ]; then
  FONT_DIR="$HOME/Library/Fonts"
  INSTALLED_CASKS="$(brew list --cask 2>/dev/null || true)"
else
  FONT_DIR="$HOME/.local/share/fonts"
  INSTALLED_CASKS=""
fi

print_usage() {
  cat << EOF
Usage: ./install_fonts.sh [OPTIONS] [FONT_NAME ...]

Install developer & Nerd Fonts on macOS or Linux.

Options:
  -a, --all        Install all available curated Nerd Fonts
  -l, --list       List all available fonts and installation status
  -b, --brew       On macOS, use Homebrew casks instead of direct download
  -h, --help       Show this help message

Available Fonts:
  • jetbrainsmono  (JetBrains Mono Nerd Font)
  • firacode       (Fira Code Nerd Font)
  • iosevka        (Iosevka Nerd Font)
  • iosevkaterm    (Iosevka Term Nerd Font)
  • hack           (Hack Nerd Font)
  • cascadiacode   (Cascadia Code / CaskaydiaCove Nerd Font)
  • meslo          (MesloLGS Nerd Font)
  • monaspace      (GitHub Monaspace Nerd Font)
  • geistmono      (Vercel GeistMono Nerd Font)
  • victormono     (VictorMono Nerd Font)
  • sourcecodepro  (Adobe Source Code Pro Nerd Font)

Examples:
  ./install_fonts.sh jetbrainsmono firacode   # Install specific fonts
  ./install_fonts.sh --all                   # Install all curated fonts
  ./install_fonts.sh --list                  # Check what's installed
  ./install_fonts.sh                         # Interactive picker (fzf)
EOF
}

is_font_installed() {
  local font_key="$1"
  local font_name="${FONT_NAMES[$font_key]}"

  if [ "$OS" = "Darwin" ]; then
    find "$FONT_DIR" /Library/Fonts -maxdepth 1 -iname "*${font_name}*Nerd*" 2>/dev/null | grep -q . && return 0
    if [ -n "$INSTALLED_CASKS" ]; then
      echo "$INSTALLED_CASKS" | grep -q "^${CASKS[$font_key]}$" && return 0
    fi
  else
    fc-list : family 2>/dev/null | grep -qi "${font_name}" && return 0
  fi
  return 1
}

list_fonts() {
  echo "Available Nerd Fonts (Destination: $FONT_DIR):"
  for key in "${!FONT_NAMES[@]}"; do
    local name="${FONT_NAMES[$key]}"
    if is_font_installed "$key"; then
      printf "  \033[1;32m✓\033[0m %-14s (%s)\n" "$key" "$name"
    else
      printf "  \033[2m○\033[0m %-14s (%s)\n" "$key" "$name"
    fi
  done | sort
}

install_via_brew() {
  local font_key="$1"
  local cask="${CASKS[$font_key]}"
  echo "==> Installing $cask via Homebrew..."
  brew install --cask "$cask"
}

install_via_download() {
  local font_key="$1"
  local font_name="${FONT_NAMES[$font_key]}"
  local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.tar.xz"

  mkdir -p "$FONT_DIR"
  local tmp_dir
  tmp_dir=$(mktemp -d)
  trap 'rm -rf "$tmp_dir"' EXIT

  echo "==> Downloading $font_name from GitHub Nerd Fonts..."
  if curl -fL --progress-bar "$url" -o "$tmp_dir/${font_name}.tar.xz"; then
    echo "==> Extracting to $FONT_DIR..."
    tar -xJf "$tmp_dir/${font_name}.tar.xz" -C "$FONT_DIR"
    echo "✓ Successfully installed $font_name"
  else
    echo "✗ Failed to download $font_name from $url" >&2
    return 1
  fi
}

install_font() {
  local font_key
  font_key="$(echo "$1" | tr '[:upper:]' '[:lower:]')"

  if [[ -z "${FONT_NAMES[$font_key]:-}" ]]; then
    echo "Warning: Unknown font '$1'. Skipping. Run with --list to see options." >&2
    return 1
  fi

  if [ "$USE_BREW" = true ]; then
    install_via_brew "$font_key"
  else
    install_via_download "$font_key"
  fi
}

# Parse command line options
USE_BREW=false
INSTALL_ALL=false
FONTS_TO_INSTALL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      print_usage
      exit 0
      ;;
    -l|--list)
      list_fonts
      exit 0
      ;;
    -a|--all)
      INSTALL_ALL=true
      shift
      ;;
    -b|--brew)
      if [ "$OS" != "Darwin" ]; then
        echo "Error: --brew is only supported on macOS." >&2
        exit 1
      fi
      USE_BREW=true
      shift
      ;;
    -*)
      echo "Unknown option: $1" >&2
      print_usage
      exit 1
      ;;
    *)
      FONTS_TO_INSTALL+=("$1")
      shift
      ;;
  esac
done

# If --all requested, queue all fonts
if [ "$INSTALL_ALL" = true ]; then
  FONTS_TO_INSTALL=("${!FONT_NAMES[@]}")
fi

# If no fonts specified, open interactive fzf multi-select if available
if [ ${#FONTS_TO_INSTALL[@]} -eq 0 ]; then
  if [ -t 0 ] && command -v fzf &>/dev/null; then
    echo "Select fonts to install (Tab to toggle multiple, Enter to confirm):"
    mapfile -t SELECTED < <(
      for key in "${!FONT_NAMES[@]}"; do
        local_name="${FONT_NAMES[$key]}"
        if is_font_installed "$key"; then
          echo "$key (installed)"
        else
          echo "$key"
        fi
      done | sort | fzf -m --prompt="Install fonts > " --header="Tab = select multiple | Enter = install"
    )

    for item in "${SELECTED[@]}"; do
      font_key="$(echo "$item" | awk '{print $1}')"
      if [ -n "$font_key" ]; then
        FONTS_TO_INSTALL+=("$font_key")
      fi
    done
  fi
fi

# Fallback if still empty
if [ ${#FONTS_TO_INSTALL[@]} -eq 0 ]; then
  print_usage
  exit 0
fi

# Install selected fonts
echo "=== Installing Fonts ==="
for f in "${FONTS_TO_INSTALL[@]}"; do
  install_font "$f"
done

# Update Linux font cache if on Linux
if [ "$OS" = "Linux" ] && command -v fc-cache &>/dev/null; then
  echo "==> Updating Linux font cache..."
  fc-cache -f "$FONT_DIR"
fi

echo "=== Font installation complete! ==="
