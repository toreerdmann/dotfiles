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

set TERM xterm-256color

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

set -gx LS_COLORS "$LS_COLORS:ow=01;34"
