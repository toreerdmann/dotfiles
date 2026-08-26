# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# zsh-syntax-highlighting must come last of the highlighting-related ones.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Autosuggestion settings must be set before the plugin is sourced -- it wraps
# the accept/partial-accept widgets at load time.
# Accepting works like fish out of the box: Right-arrow or Ctrl-F takes the
# whole suggestion, Alt-F / Alt-Right takes one word. (Don't bind Ctrl-Space
# here -- that's the tmux prefix, so tmux eats it before zsh sees it.)
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

source $ZSH/oh-my-zsh.sh

# fzf-tab replaces zsh's completion menu with an fzf picker. It has to be
# sourced after compinit, i.e. after oh-my-zsh.sh, and before any widget that
# wraps the completion system.
if [ -f "$ZSH_CUSTOM/plugins/fzf-tab/fzf-tab.plugin.zsh" ]; then
	source "$ZSH_CUSTOM/plugins/fzf-tab/fzf-tab.plugin.zsh"
elif [ -f "$ZSH/custom/plugins/fzf-tab/fzf-tab.plugin.zsh" ]; then
	source "$ZSH/custom/plugins/fzf-tab/fzf-tab.plugin.zsh"
fi

# Accept the whole autosuggestion with Ctrl-Y. (This replaces the default
# emacs `yank`. Ctrl-Space would collide with the tmux prefix.) Right-arrow
# and Ctrl-F still accept it too, Alt-F accepts a single word.
bindkey '^Y' autosuggest-accept
bindkey -M viins '^Y' autosuggest-accept

# Edit the current command line in an editor -- the sane way to fix up a long
# or multi-line command. Ctrl-X Ctrl-E in the default emacs keymap, and `v` in
# vi command mode for when vi keys are on.
# Deliberately vim (or vi), not $EDITOR: this pops up constantly for a
# one-command buffer, and nvim's plugin loading makes that startup noticeable.
# $EDITOR/$VISUAL stay on nvim for git commits and friends.
autoload -Uz edit-command-line
CMDLINE_EDITOR=${commands[vim]:-${commands[vi]:-${EDITOR:-vi}}}
edit-command-line-fast() {
	local VISUAL=$CMDLINE_EDITOR EDITOR=$CMDLINE_EDITOR
	edit-command-line
}
zle -N edit-command-line-fast
bindkey '^X^E' edit-command-line-fast
bindkey -M vicmd 'v' edit-command-line-fast

# GNU ls paints other-writable directories blue-on-green (ow=34;42), which is
# unreadable -- and in a Codespace almost every directory is other-writable.
# Override ow and tw (sticky + other-writable) with plain bold blue. Keys we
# don't mention keep ls's built-in defaults.
export LS_COLORS="${LS_COLORS:+$LS_COLORS:}ow=01;34:tw=01;34"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# fzf-tab presentation
zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath 2>/dev/null || ls -1 $realpath'
zstyle ':completion:*' menu no

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='nvim'
export VISUAL='nvim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# alias quarto="~/quarto-cli/package/dist/bin/quarto"

#alias ff="nvim \$(fzf --preview='cat {}')"
#alias fd="cd ~ && cd \$(find * -type d | fzf)"
function ff() {
	nvim $(fzf --preview='cat {}')
}
function fd() {
	cd ~ && cd $(find * -type d | fzf)
}

function nvimq() {
	NVIM_APPNAME="nvim_quarto" nvim
}
#alias quarto="~/quarto-cli/package/dist/bin/quarto"
#eval "$(nodenv init -)"


# Activate mise-en-place
if [ -d "$HOME/.local/bin" ]; then
	export PATH="$HOME/.local/bin:$PATH"
fi
if [ -d "$HOME/.local/share/mise/bin" ]; then
	export PATH="$HOME/.local/share/mise/bin:$PATH"
fi
if [ -d "$HOME/.local/share/mise/shims" ]; then
	export PATH="$HOME/.local/share/mise/shims:$PATH"
fi
if command -v mise &> /dev/null; then
	eval "$(mise activate zsh)"
fi

# setup fzf: Ctrl-R history search, Ctrl-T file picker, Alt-C cd.
# `fzf --zsh` (fzf >= 0.48) is preferred; ~/.fzf.zsh is the older installer.
if command -v fzf &> /dev/null && fzf --zsh &> /dev/null; then
	source <(fzf --zsh)
elif [ -f ~/.fzf.zsh ]; then
	source ~/.fzf.zsh
fi

# On remote sessions (Codespaces et al) hand over to tmux right away
[ -f ~/.config/shell/remote-session.sh ] && source ~/.config/shell/remote-session.sh

# Load local overrides
[ -f ~/.zshrc.local ] && source ~/.zshrc.local


