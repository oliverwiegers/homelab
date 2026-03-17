####################################################################################
#     _____  _____ __  __   ________  ___   ______________________  _   _______    #
#    /__  / / ___// / / /  / ____/ / / / | / / ____/_  __/  _/ __ \/ | / / ___/    #
#      / /  \__ \/ /_/ /  / /_  / / / /  |/ / /     / /  / // / / /  |/ /\__ \     #
#     / /_____/ / __  /  / __/ / /_/ / /|  / /___  / / _/ // /_/ / /|  /___/ /     #
#    /____/____/_/ /_/  /_/    \____/_/ |_/\____/ /_/ /___/\____/_/ |_//____/      #
#                                                                                  #
####################################################################################

host() {
    if [ "$(uname -s)" = "Darwin" ]; then
        # host cmd ignores local DNS changes on MacOS
        # See: https://apple.stackexchange.com/questions/158117/os-x-10-10-1-etc-hosts-private-etc-hosts-file-is-being-ignored-and-not-resol
        dscacheutil -q host -a name "$@"
    else
        host "$@"
    fi
}

# Curl time lookup
clookup() {
    lookup_file="$(mktemp)"
    cat <<EOF > "${lookup_file}"
time_namelookup:    %{time_namelookup}\n
time_connect:       %{time_connect}\n
time_appconnect:    %{time_appconnect}\n
time_pretransfer:   %{time_pretransfer}\n
time_redirect:      %{time_redirect}\n
time_starttransfer: %{time_starttransfer}\n
                    --------\n
time_total:         %{time_total}\n
EOF

    curl -s -L $@ -w "@${lookup_file}" -o /dev/null
    rm "${lookup_file}"
}

# Create header for config files.
header() {
    header=$1
    file=$2

    figlet -f slant "${header}" >> "${file}"
}

# Get latest commit hash.
glc() {
    git log --format='%H' | sed 1q
}

# Cleanup local branches
gbda() {
    ignored_branch="${1:-main}"
    remote="${2:-origin}"

    git fetch --all

    for branch in $(\
        git branch --merged "${ignored_branch}" \
        | grep -v "${ignored_branch}"); do

        git branch -d "${branch}"
    done

    # Cleanup remote tracking branches that are not locally tracked anymore.
    git remote prune "${remote}"
}

# Get revision hash for external resource in home manager.
hgh() {
    home-manager switch --flake ".#${whoami}@$(hostname)" \
        | grep 'got:' \
        | cut -d ' ' -f 2 \
        | cut -d '-' -f 2
}
