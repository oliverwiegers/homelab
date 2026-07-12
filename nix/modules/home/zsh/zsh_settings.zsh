###############################################################################
#     _____  _____ __  _ _   _____ _______________________   _____________    #
#    /__  / / ___// / / /   / ___// ____/_  __/_  __/  _/ | / / ____/ ___/    #
#      / /  \__ \/ /_/ /    \__ \/ __/   / /   / /  / //  |/ / / __ \__ \     #
#     / /_____/ / __  /    ___/ / /___  / /   / / _/ // /|  / /_/ /___/ /     #
#    /____/____/_/ /_/    /____/_____/ /_/   /_/ /___/_/ |_/\____//____/      #
#                                                                             #
###############################################################################

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

function after_init() {
    # Bind key for autosuggestions
    zvm_bindkey viins '^@' autosuggest-accept

    # Source fzf keybindings when using nix to install software.
    source "$(\
        ls -1 $HOME/.nix-profile/bin/fzf \
        | awk 'sub(/(\/bin\/fzf)/,"", $3) {print $3}'\
        )/share/fzf/key-bindings.zsh"

    enable-fzf-tab
}

zvm_after_init_commands+=(after_init)
