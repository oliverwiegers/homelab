#!/usr/bin/env bash

set -eou pipefail

_source="$HOME/Applications/Home Manager Apps"
_target="$HOME/Applications/Home Manager Trampolines"

# shellcheck disable=SC2329
_remove_stale_app_files() {
    while read -r _app; do
        if [ ! -d "${_source}/${_app}" ]; then
            rm -rf "${_target:?}/${_app:?}"
        fi
    done < "${1:-/dev/stdin}"
}

# shellcheck disable=SC2329
_copy_app_files() {
    while read -r _app; do
        /usr/bin/osacompile \
            -o "${_target}/${_app}" \
            -e "do shell script \"open '${_source}/${_app}'\""
        # Just clobber the applet icon laid down by osacompile rather than do
        # surgery on the plist.
        cp \
            "${_source}/${_app}/Contents/Resources"/*.icns \
            "${_target}/${_app}/Contents/Resources/"
    done < "${1:-/dev/stdin}"
}

export _source
export _target
export -f _copy_app_files
export -f _remove_stale_app_files

mkdir -p "${_target}"

cd "${_source}" || exit 1
find . -name '*.app' -exec bash -c \
    'app="$1"; echo "${app}" | sed "s/.\///g" | _copy_app_files' shell {} \;
find "${_target}" -name '*.icns' -exec chmod 0660 {} \;

cd "${_target}" || exit 1
find . -name '*.app' -exec bash -c \
    'app="$1"; echo "${app}" | sed "s/.\///g" | _remove_stale_app_files' shell {} \;

unset _source
unset _target
unset _copy_app_files
unset _remove_stale_app_files
