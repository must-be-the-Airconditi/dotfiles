#!/bin/sh
grim -g "$(slurp)" - | satty -f - --copy-command wl-copy
