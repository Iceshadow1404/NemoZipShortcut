#!/usr/bin/env bash
# Usage: extract-archive.sh here|folder|choose ARCHIVE...
set -u

mode=$1
shift

fail() {
    zenity --error --no-markup --title="Extract" --text="$1" --width=400
    exit 1
}

ask_password() {
    local archive=$1 pw prompt="Password for $(basename "$archive"):"
    if ! 7z l -slt -p "$archive" </dev/null 2>&1 | grep -qE 'Encrypted = \+|Wrong password'; then
        printf ''
        return 0
    fi
    while true; do
        pw=$(zenity --entry --hide-text --title="Encrypted archive" --text="$prompt") || return 1
        if 7z t -p"$pw" "$archive" </dev/null >/dev/null 2>&1; then
            printf '%s' "$pw"
            return 0
        fi
        prompt="Wrong password. Try again for $(basename "$archive"):"
    done
}

unique_dir() {
    local base=$1 dir=$1 n=2
    while [[ -e $dir ]]; do
        dir="$base ($n)"
        n=$((n + 1))
    done
    printf '%s' "$dir"
}

strip_ext() {
    local name
    name=$(basename "$1")
    printf '%s' "${name%.*}"
}

if [[ $mode == choose ]]; then
    target=$(zenity --file-selection --directory --title="Extract to…" --filename="$(dirname "$1")/") || exit 0
fi

errors=()
extracted=()
for archive in "$@"; do
    case $mode in
        here) dest=$(dirname "$archive") ;;
        folder) dest=$(unique_dir "$(dirname "$archive")/$(strip_ext "$archive")") ;;
        choose) dest=$target ;;
        *) fail "Unknown mode: $mode" ;;
    esac

    pw=$(ask_password "$archive") || continue

    7z x -aou -bso0 -bsp0 -p"$pw" -o"$dest" "$archive" </dev/null 2>&1 |
        zenity --progress --pulsate --auto-close --no-cancel --title="Extracting" --text="Extracting $(basename "$archive")…"
    if ((PIPESTATUS[0] != 0)); then
        errors+=("$(basename "$archive")")
    else
        extracted+=("$(basename "$archive")")
    fi
done

if ((${#errors[@]})); then
    fail "Could not extract:"$'\n'"$(printf '%s\n' "${errors[@]}")"
fi
if ((${#extracted[@]})); then
    notify-send -i extract-archive "Extraction finished" "$(printf '%s\n' "${extracted[@]}")"
fi
