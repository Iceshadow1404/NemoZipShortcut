# NemoZipShortcut

WinRAR-style extract entries for the right-click menu of the [Nemo](https://github.com/linuxmint/nemo) file manager.

Right-click a `.zip`, `.7z` or `.rar` file:

- **Extract Here** – extract into the current folder
- **Extract To ▸**
  - **Extract to "archive-name/"** – extract into a new folder named after the archive (`name (2)`, `name (3)`, … if it already exists)
  - **Choose Folder…** – pick a destination in a folder dialog

Behaviour:

- Existing files are never overwritten; clashing files are saved with a suffix (`file_1.txt`).
- Password-protected archives (including 7z with encrypted file names) prompt for the password and re-ask when it is wrong. Cancel skips that archive.
- A progress window is shown while extracting, a desktop notification when done, and an error dialog for archives that fail.
- *Extract Here* and *Choose Folder…* work on multiple selected archives; *Extract to "archive-name/"* appears only for a single selection.

## Requirements

- Nemo 5.x or newer (tested with 6.6.4)
- `7z` (the `7zip` package on Arch; RAR support included)
- `zenity`
- `notify-send` (`libnotify`)

On Arch: `sudo pacman -S 7zip zenity libnotify`

## Install

```bash
git clone https://github.com/Iceshadow1404/NemoZipShortcut.git
cd NemoZipShortcut
./install.sh
nemo -q
```

`install.sh` copies the files to:

| File | Destination |
| --- | --- |
| `actions/*` | `~/.local/share/nemo/actions/` |
| `actions-tree.json` | `~/.config/nemo/actions-tree.json` (submenu layout) |

If you already have a custom `actions-tree.json`, it is backed up to `actions-tree.json.bak` first. You can rearrange entries afterwards with `nemo-action-layout-editor`.

## Uninstall

```bash
rm ~/.local/share/nemo/actions/{extract-archive.sh,extract-here.nemo_action,extract-to-folder.nemo_action,extract-to-choose.nemo_action}
rm ~/.config/nemo/actions-tree.json   # or restore actions-tree.json.bak
nemo -q
```
