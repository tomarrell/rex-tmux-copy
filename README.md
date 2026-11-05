# rex-tmux-copy

tmux copy mode for [Rex](https://www.superlogical.com/rex) panes.

This is a stopgap until Rex has its own copy mode. The Rex team has accepted the feature request on the beta Discord.

Press `Ctrl-A [` and the focused pane's scrollback opens in tmux copy mode, in a floating pane over the original. Select text with the vi keys you'd use in tmux. `y` copies it to the clipboard and closes copy mode.

## Requirements

- Rex with a Lua config (tested on the Rex for Mac beta, November 2026)
- tmux 3.2 or newer

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

Copied text goes to `pbcopy`. To use another command, such as on Linux, pass it as a list:

```lua
require("tmux-copy").setup({ clipboard = { "wl-copy" } })
```

## Customize

Copy mode reads `~/.config/rex/tmux-copy.conf` after its own `tmux.conf`, if the file exists. Put your own tmux settings and `copy-mode-vi` bindings there. A binding copies to the clipboard only if it sets `@yank`, as `y` does:

```tmux
bind -T copy-mode-vi Y { set -g @yank 1 ; send -X copy-line-and-cancel }
```

## Keys

Copy mode uses tmux's `copy-mode-vi` table, so `hjkl`, `w`, `b`, `/`, `?`, `n`, `g` and `G` work as usual. The selection keys are:

| Key | Action |
| --- | --- |
| `v` | Start a selection |
| `V` | Select whole lines |
| `Ctrl-V`, `r` | Rectangle selection |
| `y`, `Enter` | Copy and close |
| `q` | Close without copying |
| `Esc` | Clear the selection, or close if there is none |

## How it works

The action opens a floating pane at the same position as the focused pane. The floating pane captures the original with `rex capture`, replays the capture into a tmux server on a private socket and enters copy mode once the replay ends. When you leave copy mode, the script copies the yanked text, focuses the original pane and exits, which closes the floating pane. Your own tmux sessions are not touched.

## Limitations

- Copy mode shows a snapshot. Output that arrives after you open it doesn't appear.
- It opens at the bottom of the scrollback, not where the pane is scrolled to.
- Full-screen programs such as vim and lazygit have no scrollback, so copy mode shows only their current screen.
- On very large scrollbacks the replay takes up to a second.
- tmux and Rex disagree on the width of some emoji, so lines with emoji can be drawn a cell or two off. The copied text is unaffected.

## License

MIT
