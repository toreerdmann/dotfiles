# Helper to add directories to PATH compatibly across all fish versions
function safe_add_path
    if test -d $argv[1]
        if not contains $argv[1] $PATH
            set -gx PATH $argv[1] $PATH
        end
    end
end

if status is-interactive
    safe_add_path /opt/homebrew/bin
end

if not set -q TERM; or test "$TERM" = "dumb"
    set -gx TERM xterm-256color
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
safe_add_path "$BUN_INSTALL/bin"

# julia
safe_add_path "$HOME/.juliaup/bin"

# opencode
safe_add_path "$HOME/.opencode/bin"

# Antigravity
safe_add_path "$HOME/.antigravity/antigravity/bin"

# Local bin
safe_add_path "$HOME/.local/bin"
safe_add_path "$HOME/.local/share/mise/bin"
safe_add_path "$HOME/.local/share/mise/shims"

# Activate mise-en-place
if status is-interactive
    and type -q mise
    mise activate fish | source
end

# GNU ls paints other-writable dirs blue-on-green, which is unreadable
set -gx LS_COLORS "$LS_COLORS:ow=01;34:tw=01;34"

# Source dynamic Base16 theme variables if available
if test -f "$HOME/.config/theme/base16.fish"
    source "$HOME/.config/theme/base16.fish"
end
