# .zshrc
#   zshenv -> zprofile -> zshrc (current)
#
# | zshenv   : always
# | zprofile : if login shell
# | zshrc    : if interactive shell
# | zlogin   : if login shell, after zshrc
# | zlogout  : if login shell, after logout
#
# https://zsh.sourceforge.io/Doc/Release/Files.html#Files
#

# Check if the shell is interactive, if not, don't do anything
# Not needed for zsh, but for other shells
# case $- in
# *i*) ;;
# *) return ;;
# esac

source "$HOME/.shell/utils.sh"

# Wait for dependencies to be installed
# This makes sure that the shell does not spawan multiple times
# if the dependencies are not installed
wait_for_dependencies_interactive() {
    if ! ensure_installed "git" "fzf" "curl"; then
        echo "Please install the above programs before continuing."
        echo "Do you want to enter a POSIX shell to install them? [Y/n]"
        read -r answer
        if [ "$answer" != "n" ]; then
            # spawn a posix shell and wait for it to exit
            /bin/sh
            # Check if the dependencies are installed
            wait_for_dependencies
        else
            echo "Aborting..."
            return 1
        fi
    fi
}
# wait_for_dependencies_interactive || return 1

# wait for dependencies to be installed before continuing
if ! ensure_installed "git" "fzf" "curl" "awk"; then
    echo "Please install the above programs before continuing."
    return 1
fi

# Suggest basic programs
suggest_multiple_installed "nvim" "brew" "fd" "bat" "gpg" "tldr"

##################################################
# Setup
##################################################

if is_darwin && is_installed "brew"; then
    export ZPLUG_HOME=/opt/homebrew/opt/zplug
    if [ -f "$ZPLUG_HOME/init.zsh" ]; then
        source $ZPLUG_HOME/init.zsh
    fi
fi

if suggest_installed "starship"; then
    eval "$(starship init zsh)"
fi

if suggest_installed "zoxide"; then
    eval "$(zoxide init zsh)"
fi

# Disable bell
unsetopt BEEP

# lesspipe?

##################################################
# SSH
##################################################

fix_ssh_permissions

# Start ssh-agent, supress output
eval "$(ssh-agent | sed 's/^echo/#echo/')"

# SSH Add on darwin
# https://superuser.com/a/1721414
if is_darwin; then
    # Load ssh keys into ssh-agent, supress output
    ssh-add --apple-load-keychain -q
fi

if ! ssh-add -l >/dev/null 2>&1; then
    echo "SSH keys not loaded, loading..."
    if is_darwin; then
        ssh-add --apple-use-keychain
        ssh-add --apple-load-keychain -q
    else
        ssh-add
    fi

fi

# If TERM is kitty, use kitty's ssh
if [ "$TERM" = "xterm-kitty" ]; then
    alias ssh="kitty +kitten ssh"
fi

##################################################
# Basic Aliases
##################################################

alias cd="zl"

alias gitui="gitui -t macchiato.ron"

# ls with exa
if suggest_installed "exa"; then
    alias ls="exa --icons"
    alias la="ls -a"
    alias ld="la -D"
    alias lt="la -l -g --git"
    alias ll="lt --no-time"
    alias lld="lt -D"
fi

# grep with ripgrep
if suggest_installed "rg" "ripgrep"; then
    alias grep="rg"
fi

# fd as find
# cat with bat

##################################################
# Editor
##################################################

if is_installed "nvim"; then
    alias nano="nvim"
    alias vi="nvim"
    alias vim="nvim"
    export EDITOR="nvim"
    export VISUAL="$EDITOR"
fi

##################################################
# Theme
##################################################

export BAT_THEME="Catppuccin-macchiato"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
--color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
--color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796"

##################################################
# Environment
##################################################

if is_darwin; then
    export TOOLCHAINS=swift
fi

# Uncomment the following line if the terminal does not display the colors correctly
#export TERM="xterm-256color"

export GPG_TTY=$(tty)

##################################################
# Path
##################################################

add_multiple_to_path "$HOME/.local/bin" "$HOME/.rd/bin"

##################################################
# Dotbare
##################################################

suggest_multiple_installed "bat" "tree" "delta"

if [ -f "$HOME/.dotbare/dotbare.plugin.zsh" ]; then
    source "$HOME/.dotbare/dotbare.plugin.zsh"
fi

if ! is_installed "dotbare"; then
    # Install via git, supress warnings
    echo "Installing dotbare via git..."
    git clone https://github.com/kazhala/dotbare.git "$HOME/.dotbare"
    source "$HOME/.dotbare/dotbare.plugin.zsh"
fi
alias dot="dotbare"

##################################################
# Banner
##################################################

export PF_INFO="ascii"
export PF_ASCII="Catppuccin"

if is_installed "pfetch"; then
    echo ""
    pfetch
fi

##################################################
# Plugins
##################################################

source "$HOME/.shell/plugins/autols.sh"

if is_installed "zplug"; then

    # zsh-history-substring-search
    zplug "zsh-users/zsh-history-substring-search"
    zplug "zsh-users/zsh-autosuggestions"
    zplug "zsh-users/zsh-completions"
    zplug "zsh-users/zsh-syntax-highlighting", defer:2

    zplug "lib/clipboard", from:oh-my-zsh
    # TODO: port this :)
    # zplug "lib/completion", from:oh-my-zsh
    zplug "bode-fun/pfetch-with-kitties", use:pfetch, as:command

    # Install plugins if there are plugins that have not been installed
    if ! zplug check --verbose; then
        printf "Install? [y/N]: "
        if read -q; then
            echo
            zplug install
        fi
    fi

    # Then, source plugins and add commands to $PATH
    zplug load
else
    echo "Please install zplug to use plugins."
fi

# load completions
autoload -Uz compinit bashcompinit
compinit
bashcompinit
