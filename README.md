# Tmux Tilish

A plugin based on [Jabirali's tmux-tilish](https://github.com/jabirali/tmux-tilish) I modified to fit my workflow and disable features I don't really use.
This is a plugin that makes [`tmux`][6] behave more like a typical
[dynamic window manager][7]. It is heavily inspired by [`i3wm`][8], and
most keybindings are taken [directly from there][1].

[1]: https://i3wm.org/docs/refcard.html
[6]: https://github.com/tmux/tmux/wiki/Getting-Started
[7]: https://en.wikipedia.org/wiki/Dynamic_window_manager
[8]: https://i3wm.org/docs/

## Quickstart

The easiest way to install this plugin is via the [Tmux Plugin Manager][2].
Just add the following to `~/.tmux.conf`, then press <kbd>Ctrl</kbd> + <kbd>b</kbd>
followed by <kbd>Shift</kbd> + <kbd>i</kbd> to install it (assuming default prefix key):

	set -g @plugin 'aryzhk0v/tmux-tilish'

It is also recommended that you add the following to the top of your `.tmux.conf`:

	set -s escape-time 0
	set -g base-index 1

This plugin should work fine without these settings. However, without the first one,
you may accidentally trigger e.g. the <kbd>Alt</kbd> + <kbd>h</kbd> binding by pressing
<kbd>Esc</kbd> + <kbd>h</kbd>, something that can happen often if you use `vim` in `tmux`.
Note that this setting only has to be set manually if you don't use [tmux-sensible][4].
The second one makes the window numbers go from 1-10 instead of 0-9, which IMO
makes more sense on a keyboard where the number row starts at 1. This behavior
is also more similar to how `i3wm` numbers its workspaces. However, the plugin
will check this setting explicitly when mapping keys, and works fine without it.

[2]: https://github.com/tmux-plugins/tpm
[4]: https://github.com/tmux-plugins/tmux-sensible

## Keybindings

Finally, here is a list of the actual keybindings. Most are [taken from `i3wm`][1].
Below, a "workspace" is what `tmux` would call a "window" and `vim` would call a "tab",
while a "pane" is what `i3wm` would call a "window" and `vim` would call a "split".

| Keybinding | Description |
| ---------- | ----------- |
| <kbd>Alt</kbd> + <kbd>0</kbd>-<kbd>9</kbd> | Switch to workspace number 0-9 |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>0</kbd>-<kbd>9</kbd> | Move pane to workspace 0-9 |
| <kbd>Alt</kbd> + <kbd>\\</kbd> | Split horizontally |
| <kbd>Alt</kbd> + <kbd>\|</kbd> | Split vertically |
| <kbd>Alt</kbd> + <kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd> | Move focus left/down/up/right |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd> | Move pane left/down/up/right |
| <kbd>Alt</kbd> + <kbd>f</kbd> | Fullscreen (zoom) |
| <kbd>Alt</kbd> + <kbd>r</kbd> | Refresh current layout |
| <kbd>Alt</kbd> + <kbd>x</kbd> | Quit (close) pane |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>x</kbd> | Quit (close) window |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>e</kbd> | Exit (detach) `tmux` |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>r</kbd> | Reload config |

The keybindings that move panes between workspaces assume a US keyboard layout.
As far as I know, `tmux` has no way of knowing what your keyboard layout is,
especially if you're working over `ssh`. However, if you know of a way to make
this more portable without manually adding all keyboard layouts, let me know.

## Terminal compatibility

It is worth noting that not all terminals support all keybindings. It has
been verified to work out-of-the-box on `alacritty`, `kitty`, `urxvt`,
`terminator`, and `gnome-terminal` on Linux. Note that in `gnome-terminal`,
it only works if you don't open any GUI tabs; if you do so, the terminal
itself steals the <kbd>Alt</kbd>+<kbd>0</kbd>-<kbd>9</kbd> keybindings. In
`konsole` you need to disable <kbd>Alt</kbd>+<kbd>0</kbd>-<kbd>9</kbd>
keybindings so the terminal won't steal them.
If you use `xterm`, almost none of the <kbd>Alt</kbd> keys work by default.
That can be fixed by adding the following to your `~/.Xresources`:

	XTerm*eightBitControl: false
	XTerm*eightBitInput: false
	XTerm.omitTranslation: fullscreen
	XTerm*fullscreen: never

## Integration with vim-tmux-navigator

I'm yet to figure the way to bind <kbd>Alt</kbd> + <kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd> for navigating between `vim` splits so I used a dirty hack that makes `tmux` send <kbd>Ctrl</kbd> + <kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd> keys while pressing <kbd>Alt</kbd> + <kbd>h</kbd><kbd>j</kbd><kbd>k</kbd><kbd>l</kbd> if it detects a `vim` pane.
