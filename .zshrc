# Evals
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(ssh-agent | sed 's/^echo/#echo/')"

#########
# Alias #
#########

# ls with exa
alias ls="exa --icons"
alias la="ls -a"
alias ld="la -D"
alias lt="la -l -g --git"
alias ll="lt --no-time"
alias lld="lt -D"

source "$HOME/.shell/plugins/autols.zsh"

# grep with ripgrep
alias grep="ripgrep"

# fd as find
# cat with bat
#alias cat="bat"

# editor
alias nano="nvim"
alias vi="nvim"
alias vim="nvim"

# Env
export TOOLCHAINS=swift
export EDITOR="code"
export VISUAL="$EDITOR"
#export TERM="xterm-256color"
# export GPG_TTY=$(tty)

export PF_INFO="ascii"
export PF_ASCII="Catppuccin"

# Path
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$HOME/.rd/bin:$PATH"

echo ""
pfetch

source ~/.dotbare/dotbare.plugin.zsh
