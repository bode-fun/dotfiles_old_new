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
# have taken this from somewhere, but I don't remember where

# Check if the shell is interactive, if not, don't do anything
# Not needed for zsh, but for other shells
# case $- in
# *i*) ;;
# *) return ;;
# esac

source "$HOME/.shell/utils.sh"
source "$HOME/.shell/plugins/sleep.sh"

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
(
    start_shell=0
    if ensure_installed "git" "fzf" "curl" "awk"; then
        start_shell=1
    fi

    if is_wsl; then
        if (! ensure_installed "wslpath" "keychain"); then # || (! suggest_installed "wslvar" "wslu")
            start_shell=0
        fi
    fi

    if [ "$start_shell" -eq 0 ]; then
        echo "Please install the above programs before continuing."
        return 1
    fi
) || return 1

# Suggest basic programs
suggest_multiple_installed "nvim" "brew" "fd" "bat" "gpg" "tldr"

##################################################
# Setup
##################################################

if is_installed "brew"; then
    # TODO: Remove this when changing to another zsh plugin manager
    export ZPLUG_HOME="$HOMEBREW_PREFIX/opt/zplug"
    if [ -f "$ZPLUG_HOME/init.zsh" ]; then
        # source "$HOMEBREW_PREFIX/opt/antidote/share/antidote/antidote.zsh"
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

# Vim keybindings as god intended
bindkey -v

# lesspipe?

##################################################
# SSH
##################################################

fix_ssh_permissions

# Start ssh-agent, supress output
eval "$(ssh-agent -s  | sed 's/^echo/#echo/')"


# SSH Add on darwin
# https://superuser.com/a/1721414
if is_darwin; then
    # Load ssh keys into ssh-agent, supress output
    ssh-add --apple-load-keychain -q
elif is_wsl; then
    eval "$(keychain --quiet --eval --agents ssh)"
fi

if ! ssh-add -l >/dev/null 2>&1; then
    public_key_count="$(\find $HOME/.ssh/ -type f \( -name "*.pub" \) | wc -l)"
    if [ "$public_key_count" -gt 0 ]; then
        echo "SSH keys not added, adding..."

        if is_darwin; then
            # Add keys
            ssh-add --apple-use-keychain
            # Refresh keychain
            ssh-add --apple-load-keychain -q
        else
            echo "Please run `ssh-add` to add your ssh keys"
        fi
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

# To avvoid brew fomulars to accidentally link against a Pyenv-provided Python
# alias brew='env PATH="${PATH//$(pyenv root)\/shims:/}" brew'

# grep with ripgrep
suggest_installed "rg" "ripgrep"

if suggest_installed "ranger"; then
    alias ranger=". ranger"
fi

##################################################
# Editor
##################################################

# Maybe set an editor for ssh connections

if is_installed "nvim"; then
    alias vi="nvim"
    alias vim="nvim"
    export EDITOR="nvim"
    export VISUAL="$EDITOR"
else
    echo "nvim not installed, using vim"
    export EDITOR="vim"
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

# If automatic langugagemanagement does not work

# export LANG="${LANG:-de_DE.UTF-8}"
# export LANGUAGE="${LANGUAGE:-de}"
# export LC_ALL="${LC_ALL:-de_DE.UTF-8}"

if is_darwin; then
    # Always use the newest version of swift
    export TOOLCHAINS=swift
fi

# Uncomment the following line if the terminal does not display the colors correctly
#export TERM="xterm-256color"

# Used for signing with gpg (gpg-keys and ssh)
export GPG_TTY=$(tty)

##################################################
# Path
##################################################

# Add homebrew to fpath
fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)


add_multiple_to_path "$HOME/.local/bin" "$HOME/.rd/bin" "$HOME/sdk" "$HOME/go/bin"

# Composer
# PATH="$HOME/.config/composer/vendor/bin/:$PATH"

if is_wsl; then
    # Get the userdirectory on windows.
    WINDOWS_USER_PATH="$(wslpath "$(wslenv USERPROFILE)")"
    add_to_path "$WINDOWS_USER_PATH/AppData/Local/Programs/Microsoft VS Code/bin"
fi

add_to_path "$HOME/.deno/bin"

if is_linux; then
    add_to_path "$HOME/bin"
fi

if is_darwin; then
    # Remember to upgrade this when upgrading python
    add_to_path "/Users/janfooken/Library/Python/3.9/bin"
fi

##################################################
# Pyenv
##################################################

# export PYENV_ROOT="$HOME/.pyenv"
# if is_installed "pyenv"; then
#    add_to_path "$PYENV_ROOT/bin"
#    eval "$(pyenv init -)"
#    #eval "$(pyenv virtualenv-init -)"
# fi

##################################################
# Dotbare
##################################################

suggest_multiple_installed "bat" "tree"
suggest_installed "delta" "git-delta"

if [ -f "$HOME/.dotbare/dotbare.plugin.zsh" ]; then
    source "$HOME/.dotbare/dotbare.plugin.zsh"
fi

if ! is_installed "dotbare"; then
    echo "Installing dotbare via git..."
    git clone https://github.com/kazhala/dotbare.git "$HOME/.dotbare"
    source "$HOME/.dotbare/dotbare.plugin.zsh"
fi
alias dot="dotbare"

##################################################
# Banner
##################################################

if ! is_installed "pfetch-with-kitties"; then
    echo "Installing pfetch-with-kitties..."
    mkdir -p "$HOME/.local/bin"
    add_to_path "$HOME/.local/bin"
    # I use my own fork, becaus I audited it
    curl -sL https://raw.githubusercontent.com/bode-fun/pfetch-with-kitties/main/pfetch >"$HOME/.local/bin/pfetch-with-kitties"
    chmod +x "$HOME/.local/bin/pfetch-with-kitties"
fi

if is_installed "pfetch-with-kitties"; then
    if is_wsl; then
        echo ""
        HOSTNAME="wsl" PF_INFO="ascii title os uptime memory" PF_ASCII="Catppuccin" pfetch-with-kitties
    else
        echo ""
        HOSTNAME="mac" PF_INFO="ascii title os uptime memory" PF_ASCII="Catppuccin" pfetch-with-kitties
    fi
fi

##################################################
# Plugin conf
##################################################

#####################################
# Taken from
# https://github.com/mattmc3/zephyr
#####################################

# zsh-autosuggestions

#
# Variables
#

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'

#
# Keybinds
#

if [[ -n "$key_info" ]]; then
    # vi
    bindkey -M viins "$key_info[Control]F" vi-forward-word
    bindkey -M viins "$key_info[Control]E" vi-add-eol
fi

# zsh-completions

# zsh-syntax-highlighting

# zsh-substring-search

# emacs
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# vi
bindkey -M vicmd "k" history-substring-search-up
bindkey -M vicmd "j" history-substring-search-down

# up/down
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

##################################################
# Plugins
##################################################

# TODO: Move to another manager. Zplug seems to be abandoned. (https://github.com/mattmc3/zsh_unplugged)
# Cool and in zsh:  https://getantidote.github.io/ # Mad respect to the author, I take inspiration from his dotfiles
# Rust????:         https://sheldon.cli.rs/

# Take inspiration from:
#
# https://github.com/mattmc3/dotfiles
# https://github.com/mattmc3/zdotdir
# https://github.com/mattmc3/zephyr (zsh config, maybe use it?)
# https://github.com/mattmc3/zebrafish (zsh config, suuuuper barebones and simple)
# https://github.com/tjdevries/config_manager (dotfiles from tjdevries, core maintainer of neovim)
# https://github.com/ThePrimeagen/.dotfiles (dotfiles from ThePrimeagen... cool dude, I guess)

source "$HOME/.shell/plugins/autols.sh"

if is_installed "zplug"; then # damn zplug, the author didn't even archive the repo or put out a deprecation notice

    zplug "zsh-users/zsh-history-substring-search"
    zplug "zsh-users/zsh-autosuggestions"
    zplug "zsh-users/zsh-completions"
    zplug "zsh-users/zsh-syntax-highlighting", defer:2

    #zplug "lib/clipboard", from:oh-my-zsh
    # TODO: port this, because it calls bashcompinit :)
    #zplug "lib/completion", from:oh-my-zsh, defer:2 # This calls bashcompinit
    #zplug "mattmc3/zephyr"
    zplug "bode-fun/zephyr"

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
compinit     # defering with 2 in zplug means that these plugins are loaded after compinit
bashcompinit # already called by oh-my-zsh, defered by zplug
