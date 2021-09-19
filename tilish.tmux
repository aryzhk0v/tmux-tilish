#!/bin/sh
# Project: tmux-tilish
# Author:  Jabir Ali Ouassou <jabirali@switzerlandmail.ch>
# Licence: MIT licence
#
# This file contains the `tmux` plugin `tilish`, which implements keybindings
# that turns `tmux` into a more typical tiling window manger for your terminal.
# The keybindings are taken nearly directly from `i3wm` and `sway`, but with
# minor adaptation to fit better with `vim` and `tmux`. See also the README.
# Check input parameters {{{
	# Get version and options.
	options="$(tmux show-options -g | sed -ne 's/^@tilish-\([[:alpha:]]*\)\s\s*.\(\S*\).\s*$/\1=\2/p')"
	version=$(tmux select-layout -E 2>/dev/null && echo 2 || echo 1)

	# Set option variables.
	for n in $options
	do
		export $n
	done
# }}}

# Define core functionality {{{
bind_switch () {
	# Bind keys to switch between workspaces.
	tmux bind -n "$1" \
		if-shell "tmux select-window -t :$2" "" "new-window -t :$2"
}

bind_move () {
	# Bind keys to move panes between workspaces.
	if [ "$version" -ge 2 ]
	then
		tmux bind -n "$1" \
			if-shell "tmux join-pane -h -t :$2" \
				"" \
				"new-window -dt :$2; join-pane -t :$2; select-pane -t top-left; kill-pane" \\\;\
			select-layout \\\;\
			select-layout -E
	else
		tmux bind -n "$1" \
			if-shell "tmux new-window -dt :$2" \
				"join-pane -t :$2; select-pane -t top-left; kill-pane" \
				"send escape; join-pane -t :$2" \\\;\
			select-layout
	fi
}

# Define keybindings {{{
# Switch to workspace via Alt + #.
bind_switch 'M-1' 1
bind_switch 'M-2' 2
bind_switch 'M-3' 3
bind_switch 'M-4' 4
bind_switch 'M-5' 5
bind_switch 'M-6' 6
bind_switch 'M-7' 7
bind_switch 'M-8' 8
bind_switch 'M-9' 9
bind_switch 'M-0' 10

# Move pane to workspace via Alt + Shift + #.
bind_move 'M-!' 1
bind_move 'M-@' 2
bind_move 'M-#' 3
bind_move 'M-$' 4
bind_move 'M-%' 5
bind_move 'M-^' 6
bind_move 'M-&' 7
bind_move 'M-*' 8
bind_move 'M-(' 9
bind_move 'M-)' 10

# Split a window
#tmux bind '|' split-window -h
#tmux bind '\' split-window -v
#tmux bind -n 'M-|' split-window -h
#tmux bind -n 'M-\' split-window -v
tmux bind '|' split-window -h -c '#{pane_current_path}'
tmux bind '\' split-window -v -c '#{pane_current_path}'
tmux bind -n 'M-|' split-window -h -c '#{pane_current_path}'
tmux bind -n 'M-\' split-window -v -c '#{pane_current_path}'

# Refresh the current layout (e.g. after deleting a pane).
if [ "$version" -ge 2 ]
then
	tmux bind -n 'M-r' select-layout -E
else
	tmux bind -n 'M-r' run-shell 'tmux select-layout'\\\; send escape
fi

# Move a pane via Alt + Shift + hjkl.
if [ "$version" -ge 2 ]
then
	tmux bind -n 'M-H' swap-pane -s '{left-of}'
	tmux bind -n 'M-J' swap-pane -s '{down-of}'
	tmux bind -n 'M-K' swap-pane -s '{up-of}'
	tmux bind -n 'M-L' swap-pane -s '{right-of}'
else
	tmux bind -n 'M-H' run-shell 'old=`tmux display -p "#{pane_index}"`; tmux select-pane -L; tmux swap-pane -t $old'
	tmux bind -n 'M-J' run-shell 'old=`tmux display -p "#{pane_index}"`; tmux select-pane -D; tmux swap-pane -t $old'
	tmux bind -n 'M-K' run-shell 'old=`tmux display -p "#{pane_index}"`; tmux select-pane -U; tmux swap-pane -t $old'
	tmux bind -n 'M-L' run-shell 'old=`tmux display -p "#{pane_index}"`; tmux select-pane -R; tmux swap-pane -t $old'
fi

# Seamless navigation between tmux and vim splits
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

tmux bind -n 'M-h' if-shell "$is_vim" "send-keys C-h"  "select-pane -L"
tmux bind -n 'M-l' if-shell "$is_vim" "send-keys C-l"  "select-pane -R"
tmux bind -n 'M-j' if-shell "$is_vim" "send-keys C-j"  "select-pane -D"
tmux bind -n 'M-k' if-shell "$is_vim" "send-keys C-k"  "select-pane -U"
# tmux bind -n 'M-h' "resize-pane -L 10"
# tmux bind -n 'M-l' "resize-pane -R 10"
# tmux bind -n 'M-j' "select-pane -t :.+"
# tmux bind -n 'M-k' "select-pane -t :.-"

tmux bind-key -T copy-mode-vi 'M-h' select-pane -L
tmux bind-key -T copy-mode-vi 'M-j' select-pane -D
tmux bind-key -T copy-mode-vi 'M-k' select-pane -U
tmux bind-key -T copy-mode-vi 'M-l' select-pane -R

# Resize panes
tmux bind-key -n 'M-Left' if-shell "$is_vim" "send-keys Left"  "resize-pane -L 10"
tmux bind-key -n 'M-Down' if-shell "$is_vim" "send-keys Down"  "resize-pane -D 5"
tmux bind-key -n 'M-Up' if-shell "$is_vim" "send-keys Up"  "resize-pane -U 5"
tmux bind-key -n 'M-Right' if-shell "$is_vim" "send-keys Right"  "resize-pane -R 10"

# It's time to deal with those panes/windows!
tmux bind-key -n 'M-x' confirm-before "kill-pane"
tmux bind-key -n 'M-X' confirm-before "kill-window"

# Comfy way of switching between sessions
tmux bind-key -n 'M-s' choose-tree -s

# Comfy way of switching between windows
tmux bind-key -n 'M-w' choose-tree -w

# And even comfier way of switching between sessions
tmux bind-key -n 'M-n' switch-client -n
tmux bind-key -n 'M-p' switch-client -p

tmux bind-key -n 'M-]' switch-client -n
tmux bind-key -n 'M-[' switch-client -p
tmux bind-key -n 'M-b' switch-client -l

# Create new session
tmux bind-key -n 'M-N' command-prompt -I "#S" "new-session -s '%%'"

# Toggle fullscreen
tmux bind-key -n 'M-f' resize-pane -Z

# Rename a window
tmux bind-key 'r' command-prompt -I "" "rename-window '%%'"

# Close a connection with Alt + Shift + e.
tmux bind -n 'M-E' \
	confirm-before -p "Detach from #H:#S? (y/n)" detach-client

# Reload configuration with Alt + Shift + r.
tmux bind -n 'M-R' \
	source-file ~/.tmux.conf \\\;\
	display "Reloaded config"
# Scroll buffer with PgUp/PgDown
bind-key -n Ppage copy-mode \; send-keys -X page-up
bind-key -n Npage copy-mode \; send-keys -X page-down

# C-[ is hard to reach (
tmux bind-key -n 'M-c' copy-mode
tmux bind-key -n 'C-Space' copy-mode
# }}}

# Define hooks {{{
if [ "$version" -ge 2 ]
then
	# Autorefresh layout after deleting a pane.
	tmux set-hook after-split-window "select-layout; select-layout -E"
	tmux set-hook pane-exited "select-layout; select-layout -E"

	# Autoselect layout after creating new window.
	if [ -n "$default" ]
	then
		tmux set-hook window-linked "select-layout $default; select-layout -E"
		tmux select-layout $default
		tmux select-layout -E
	fi
fi
# }}}
# vim:foldmethod=marker:foldlevel=0
