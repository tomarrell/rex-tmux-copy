# rex-tmux-copy

tmux copy mode for [Rex](https://www.superlogical.com/rex) panes.

Press `Ctrl-A [` and the focused pane's scrollback opens in tmux copy mode, in a floating pane over the original. Select text with the vi keys you'd use in tmux. `y` copies it to the clipboard and closes copy mode.

## Requirements

- Rex with Lua config (tested with Rex for Mac 0.1.0)
- tmux 3.0 or newer
- jq
- `pbcopy`, `wl-copy`, `xclip` or `xsel`

## Install

```sh
git clone https://github.com/tomarrell/rex-tmux-copy ~/.config/rex/tmux-copy
```

Add this line to `~/.config/rex/init.lua`, then run `rex config reload`:

```lua
require("tmux-copy").setup()
```

To use a different key, pass it to `setup`:

```lua
require("tmux-copy").setup({ key = "ctrl+b>[" })
```

With `key = false`, nothing is bound and you can bind the `tmux_copy_mode` action yourself.

## Keys

Copy mode uses tmux's `copy-mode-vi` table, so `hjkl`, `w`, `b`, `/`, `?`, `n`, `gg` and `G` work as usual. The selection keys are:

| Key | Action |
| --- | --- |
| `v` | Start a selection |
| `V` | Select whole lines |
| `Ctrl-V`, `r` | Rectangle selection |
| `y`, `Enter` | Copy and close |
| `q` | Close without copying |

## How it works

The action captures the pane with `rex capture` and opens a floating pane at the same position. The floating pane replays the capture into a tmux server on a private socket and enters copy mode once the replay ends. When you leave copy mode, the script copies the yanked text, closes the floating pane and focuses the original pane. Your own tmux sessions are not touched.

## Limitations

- Copy mode shows a snapshot. Output that arrives after you open it doesn't appear.
- It opens at the bottom of the scrollback, not where the pane is scrolled to.
- On very large scrollbacks the replay takes up to a second.

## License

MIT
