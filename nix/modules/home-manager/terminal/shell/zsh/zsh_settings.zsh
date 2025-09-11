###############################################################################
#     _____  _____ __  _ _   _____ _______________________   _____________    #
#    /__  / / ___// / / /   / ___// ____/_  __/_  __/  _/ | / / ____/ ___/    #
#      / /  \__ \/ /_/ /    \__ \/ __/   / /   / /  / //  |/ / / __ \__ \     #
#     / /_____/ / __  /    ___/ / /___  / /   / / _/ // /|  / /_/ /___/ /     #
#    /____/____/_/ /_/    /____/_____/ /_/   /_/ /___/_/ |_/\____//____/      #
#                                                                             #
###############################################################################

enable-fzf-tab
# Enable terragrunt autocompletion
if command -v terragrunt > /dev/null 2>&1; then
    complete -o nospace -C "$(which terragrunt)" terragrunt

    alias tg="terragrunt"
fi


#                    _       __    __
#  _   ______ ______(_)___ _/ /_  / /__  _____
# | | / / __ `/ ___/ / __ `/ __ \/ / _ \/ ___/
# | |/ / /_/ / /  / / /_/ / /_/ / /  __(__  )
# |___/\__,_/_/  /_/\__,_/_.___/_/\___/____/

# START Set PATH
# Following snippet appends to PATH but ensures PATH is not appending itself
# while resourcing the shell configuration.
# Shamelessly stolen from /etc/profile on Void Linux.
appendpath () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="${PATH:+$PATH:}$1"
    esac
}

# Set our default path (/usr/sbin:/sbin:/bin included for non-Void chroots)
appendpath "$HOME/.local/bin"
appendpath "$HOME/.local/ovftool"
appendpath "$HOME/.krew/bin"
appendpath "$HOME/.local/bin/scripts"
appendpath "$HOME/go/bin"

unset appendpath
# END Set PATH

export KUBECONFIG="$(find ~/.kube/configs/ -type f -exec printf '%s:' '{}' +)"
export EDITOR="vim"
export BROWSER="firefox"

# Fix java GUI issues with wayland
_JAVA_AWT_WM_NONEREPARENTING=1

#                  __
#  _      ______ _/ /
# | | /| / / __ `/ /
# | |/ |/ / /_/ / /
# |__/|__/\__,_/_/

#if [ "$(uname)" = "Linux" ] && [ "$(command -v wal)" ]; then
#    # Set wal theme if not done yet.
#    if ! [ -d "$HOME/.cache/wal" ]; then
#        wal --theme base16-gruvbox-hard
#    fi
#
#    # &   # Run the process in the background.
#    # ( ) # Hide shell job control messages.
#    (cat ~/.cache/wal/sequences &)
#
#    # To add support for TTYs this line can be optionally added.
#    # shellcheck source=/home/oliverwiegers/.cache/wal/colors-tty.sh
#    . "${HOME}/.cache/wal/colors-tty.sh"
#fi

#         _                  __
#  _   __(_)______  ______ _/ /____
# | | / / / ___/ / / / __ `/ / ___/
# | |/ / (__  ) /_/ / /_/ / (__  )
# |___/_/____/\__,_/\__,_/_/____/
[[ ! ~/.p10k.zsh ]] || source ~/.p10k.zsh

#     __              __    _           ___
#    / /_____  __  __/ /_  (_)___  ____/ (_)___  ____ ______
#   / //_/ _ \/ / / / __ \/ / __ \/ __  / / __ \/ __ `/ ___/
#  / ,< /  __/ /_/ / /_/ / / / / / /_/ / / / / / /_/ (__  )
# /_/|_|\___/\__, /_.___/_/_/ /_/\__,_/_/_/ /_/\__, /____/
#           /____/                            /____/

# Bind key for autosuggestions
bindkey '^ ' autosuggest-accept

bindkey '^B' backward-word
bindkey '^F' forward-word
