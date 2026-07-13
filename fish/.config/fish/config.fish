if status is-interactive
    # Commands to run in interactive sessions can go here
    fish_add_path /opt/homebrew/bin
end

set TERM xterm-256color

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
# julia
set --export PATH $HOME/.juliaup/bin $PATH

# opencode
fish_add_path /Users/tore.erdmann/.opencode/bin

# Added by Antigravity
fish_add_path /Users/tore.erdmann/.antigravity/antigravity/bin

# Added by Antigravity CLI installer
set -gx PATH "/Users/tore.erdmann/.local/bin" $PATH

# Activate mise-en-place
if test -d "$HOME/.local/share/mise/bin"
    fish_add_path "$HOME/.local/share/mise/bin"
end

if status is-interactive
    and type -q mise
    mise activate fish | source
end
