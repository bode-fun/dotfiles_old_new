#! /usr/bin/sh

# Checks if the host platform is Darwin
# Takes:    void
# Returns:  0 if true, 1 if false
is_darwin() {
    [ "$(uname -s)" = "Darwin" ]
}

# Checks if the host platform is Linux
# Takes:    void
# Returns:  0 if true, 1 if false
is_linux() {
    [ "$(uname -s)" = "Linux" ]
}

# Adds a directory to the PATH if it exists and isn't already in the PATH.
# Takes:    $1 - The directory to add to the PATH
# Returns:  void
add_to_path() {
    if [ -d "$1" ]; then
        case :$PATH: in
        *:"$1":*) : ;;        # already there
        *) PATH="$1:$PATH" ;; # or PATH="$PATH:$1"
        esac
    fi
}

# Adds multiple directories to the PATH if they exist and aren't already in the PATH.
# Takes:    $@ - The directories to add to the PATH
# Returns:  void
add_multiple_to_path() {
    for dir in "$@"; do
        add_to_path "$dir"
    done
}

# Checks if a command is installed.
# Takes:    $1 - The command to check
# Returns:  0 if the command is installed, 1 if not
# Example:  if is_installed "git"; then
#               echo "Git is installed"
#           fi
is_installed() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Checks if one or more commands are installed.
# Takes:    $@ - The commands to check
# Returns:  0 if all commands are installed, 1 if not
# Example:  ensure_installed "git" "brew"
ensure_installed() {
    all_installed=0
    for cmd in "$@"; do
        if ! is_installed "$cmd"; then
            all_installed=1
            echo "Command '$cmd' not found. Please install it."
        fi
    done
    [ "$all_installed" -eq 0 ]
}

# Checks if a command is installed and suggests to install it if it isn't.
# Takes:    $1 - The command to check
#           $2 - The command to install
# Returns:  0 if the command is installed, 1 if not
# Example:  suggest_installed "git"
suggest_installed() {
    if ! is_installed "$1"; then
        echo "Command '$1' not found. Please install it."
        if [ -n "$2" ]; then
            echo "You can install it with '$2'."
        fi
        return 1
    fi
    return 0
}

# Checks if one or more commands are installed and suggests to install them if they aren't.
# Takes:    $@ - The commands to check
# Returns:  0 if all commands are installed, 1 if not
# Example:
#   if suggest_multiple_installed "git" "brew"; then
#       echo "All commands are installed"
#   fi
suggest_multiple_installed() {
    all_installed=0
    for cmd in "$@"; do
        if ! suggest_installed "$cmd"; then
            all_installed=1
        fi
    done
    [ "$all_installed" -eq 0 ]
}