#!/bin/bash
#
# BL-Fever_Room theme colours
#
# written for BunsenLabs by damo <damo@bunsenlabs.org> May 2015
# modified July 2017
#
# -nb    normal background colour
# -nf    normal foreground colour
# -sb    selected background colour
# -sf    selected foreground colour
#
# -b    place menu at bottom (otherwise appears at top)
#
# See 'man dmenu' for more information.

USAGE="\n  To start dmenu at the top or bottom of the screen,\n\
  add or remove -b in the dmenu_run command in dmenu-bind.sh.\n\
  -b     locate at bottom\n\n\
  To change colours, edit the options:\n\n\
  -nb    normal background colour\n\
  -nf    normal foreground colour\n\
  -sb    selected background colour\n\
  -sf    selected foreground colour\n\n\
  Get all configuration options with 'man dmenu'.\n"

if [[ $# = 1 ]]; then
    case $1 in
        -h|--help   ) echo -e "$USAGE"
        exit 0;;
        *           ) echo -e "\n  Invalid command argument\n"
        exit 1;;
    esac
fi

# BL-Fever_Room
# Top
dmenu_run -i -nb '#3F2B1B' -nf '#CCB9A3' -sb '#B76529' -sf '#151617'
# Bottom
#dmenu_run -i -b -nb '#3F2B1B' -nf '#CCB9A3' -sb '#B76529' -sf '#151617'

