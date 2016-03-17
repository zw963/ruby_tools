# -*- coding: utf-8; mode:ruby; -*-

# Copy this file as $HOME/.rbindkeys.rb.

# NOTICE: REMOVE ALL your's .Xmodmap, .inputrc before use this.

#
# ============================== global default binding start ==============================
#

# capslock as ctrl, and rightalt as capslock, replace .Xmodmap.
pre_bind_key KEY_CAPSLOCK, KEY_LEFTCTRL
pre_bind_key KEY_RIGHTALT, KEY_CAPSLOCK

bind_key [KEY_LEFTCTRL, KEY_J], KEY_LEFT
bind_key [KEY_LEFTCTRL, KEY_L], KEY_RIGHT

bind_key [KEY_LEFTALT, KEY_J], [KEY_LEFTCTRL, KEY_LEFT]
bind_key [KEY_LEFTALT, KEY_L], [KEY_LEFTCTRL, KEY_RIGHT]

#
# ============================== global default binding end ==============================
#

# For browser.
window(@default_bind_resolver, :app_class => /Firefox$|^chromium-browser$|^google-chrome$/) do
  # search bar
  bind_key [KEY_LEFTCTRL, KEY_S], [KEY_LEFTCTRL, KEY_K]
  # address bar
  bind_key [KEY_LEFTALT, KEY_E], [KEY_LEFTCTRL, KEY_L]
end

def terminal_global
  bind_key [KEY_LEFTCTRL, KEY_EQUAL], [KEY_LEFTSHIFT, KEY_LEFTCTRL, KEY_EQUAL]

  # When press Ctrl+., can output ` => '.
  bind_key [KEY_LEFTCTRL, KEY_DOT] do |_ev, op|
    op.release_key KEY_LEFTCTRL

    op.press_key KEY_SPACE
    op.release_key KEY_SPACE

    op.press_key KEY_EQUAL
    op.release_key KEY_EQUAL

    op.press_key KEY_LEFTSHIFT
    op.press_key KEY_DOT
    op.release_key KEY_DOT
    op.release_key KEY_LEFTSHIFT

    op.send_event EV_SYN, 0, 0 # flush the event buffer
    sleep 0.01

    op.press_key KEY_SPACE
    op.release_key KEY_SPACE
  end
end

terminal_app_class = /(terminal|Xterm|Terminator)$/

# special config must be defined before general.
# e.g. nano is run in terminal, must be defined before terminal.
# for following script is take effect, you need change current termianl title
# to `nano', you can do this with following bash function.

# function set_terminal_title () {
#   echo -en "\033]0;$*\a"
# }

# set_termianl_title nano

# For nano, app_class is Terminal, name is nano.
window(@default_bind_resolver, :title => /nano/, :app_class => terminal_app_class) do
  bind_key [KEY_LEFTALT, KEY_P], [KEY_LEFTALT, KEY_MINUS]
  bind_key [KEY_LEFTALT, KEY_N], [KEY_LEFTALT, KEY_EQUAL]

  bind_key [KEY_LEFTSHIFT, KEY_LEFTALT, KEY_COMMA], [KEY_LEFTALT, KEY_BACKSLASH]
  bind_key [KEY_LEFTSHIFT, KEY_LEFTALT, KEY_DOT], [KEY_LEFTALT, KEY_SLASH]

  terminal_global
end

# For Terminal, must defined after nano
window(@default_bind_resolver, :app_class => terminal_app_class) do
  bind_key [KEY_LEFTALT, KEY_W], [KEY_LEFTSHIFT, KEY_LEFTCTRL, KEY_C]
  bind_key [KEY_LEFTCTRL, KEY_Y], [KEY_LEFTSHIFT, KEY_LEFTCTRL, KEY_V]
  bind_key [KEY_LEFTCTRL, KEY_W], [KEY_LEFTSHIFT, KEY_LEFTCTRL, KEY_X]

  terminal_global
end
