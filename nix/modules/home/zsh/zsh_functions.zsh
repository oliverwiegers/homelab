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

unalias gb
gb() {
    if ! [ "$#" -gt 0 ]; then
        # Collect branches and descriptions
        _branches="$(git branch | sed 's|[* ]||g' | while read -r _branch; do
            _prefix="$(\
                if [ "${_branch}" = "$(git rev-parse --abbrev-ref HEAD)" ]; then
                    printf '\e[32m_*'
                else
                    printf '__'
                fi\
            )"
            _description="$(git config "branch.${_branch}.description" \
                | head -n1)"

            printf '%s %s %s\n\e[0m' \
                "${_prefix}" "${_branch}" "${_description}"
        done)"

        # Print out spaced like a table
        _spacing="$(\
            printf '%s' "${_branches}" \
            | awk '{ if (length($2) > max) max = length($2) } END { print max }'\
            )"

        printf '%s' "$_branches" | while read -r _prefix _branch _desc; do
            printf "%s %-${_spacing}s %s\n" \
                "${_prefix//_/ }" "${_branch}" "${_desc}"
        done
    else
        git branch $@
    fi
}

unalias gcb
gcb() {
    git checkout -b "$1"

    _branch="$(git rev-parse --abbrev-ref HEAD)"
    git config "branch.${_branch}.description" "$2"
}

# Get revision hash for external resource in home manager.
hgh() {
    home-manager switch --flake ".#${whoami}@$(hostname)" \
        | grep 'got:' \
        | cut -d ' ' -f 2 \
        | cut -d '-' -f 2
}

daily() {
    _datestring="$(date +%d-%m-%Y)"
    _monthstring="$(date +%m_%b)"
    _daily_dir="$HOME/Documents/notes/nlx/daily"
    _month_dir="${_daily_dir}/${_monthstring}"
    _daily_file="${_month_dir}/${_datestring}.md"

    if ! [ -d "${_month_dir}" ]; then
        mkdir "${_month_dir}"
    fi

    if ! [ -f "${_daily_file}" ]; then
        cp "${_daily_dir}/_template.md" "${_daily_file}"
    fi

    vim "${_daily_file}"
}
