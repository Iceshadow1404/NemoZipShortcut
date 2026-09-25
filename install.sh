#!/usr/bin/env bash
set -euo pipefail

repo=$(cd "$(dirname "$0")" && pwd)
actions_dir=${XDG_DATA_HOME:-$HOME/.local/share}/nemo/actions
layout=${XDG_CONFIG_HOME:-$HOME/.config}/nemo/actions-tree.json

for dep in nemo 7z zenity notify-send; do
    command -v "$dep" >/dev/null || echo "Warning: '$dep' not found, the menu entries stay hidden until it is installed." >&2
done

mkdir -p "$actions_dir" "$(dirname "$layout")"
install -m 755 "$repo/actions/extract-archive.sh" "$actions_dir/"
install -m 644 "$repo"/actions/*.nemo_action "$actions_dir/"

if [[ -f $layout ]] && ! cmp -s "$repo/actions-tree.json" "$layout"; then
    cp "$layout" "$layout.bak"
    echo "Existing menu layout backed up to $layout.bak"
fi
install -m 644 "$repo/actions-tree.json" "$layout"

echo "Installed. Restart Nemo with: nemo -q"
