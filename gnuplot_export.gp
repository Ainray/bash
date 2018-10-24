#!/usr/bin/gnuplot
set terminal push # push current terminal setting
set terminal png # select the file format
set output "$0" # specify the output filename
replot # repeat the most recent plot command,
# with the output now going to the
# specified file.
set output # send output to the screen again,
# by using an empty filename.
set terminal pop # restore the terminal
