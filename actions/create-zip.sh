#!/usr/bin/env bash
# Usage: create-zip.sh FOLDER...
set -u

unique_zip() {
    local base=$1 zip="$1.zip" n=2
    while [[ -e $zip ]]; do
        zip="$base ($n).zip"
        n=$((n + 1))
    done
    printf '%s' "$zip"
}

errors=()
created=()
for folder in "$@"; do
    folder=${folder%/}
    zip=$(unique_zip "$folder")

    (cd "$(dirname "$folder")" && 7z a -tzip -bso0 -bsp0 "$zip" "$(basename "$folder")" </dev/null 2>&1) |
        zenity --progress --pulsate --auto-close --no-cancel --title="Creating ZIP" --text="Compressing $(basename "$folder")…"
    if ((PIPESTATUS[0] != 0)); then
        rm -f "$zip"
        errors+=("$(basename "$folder")")
    else
        created+=("$(basename "$zip")")
    fi
done

if ((${#errors[@]})); then
    zenity --error --no-markup --title="Create ZIP" --text="Could not compress:"$'\n'"$(printf '%s\n' "${errors[@]}")" --width=400
    exit 1
fi
if ((${#created[@]})); then
    notify-send -i package-x-generic "ZIP created" "$(printf '%s\n' "${created[@]}")"
fi
