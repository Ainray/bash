#!/bin/gnuplot
# author: Ainray
# date: Sat Dec 23 13:24:26 CST 2017

set terminal push
set terminal pdfcairo transparent enhanced fontscale 0.4 size 7cm,7cm linewidth 0.5
set output 'test_dsp_fft1_spec.pdf'
set encoding utf8
set style line 1  lw 1.5 lc rgb 'blue' ps 0.3
set style line 2  lw 1.5 lc rgb 'red' pt 7 ps 0.3
set style line 3  lw 1.5 lc rgb 'green' ps 0.3
set style line 4  lw 1.5 lc rgb 'magenta' pt 5 ps 0.3
set size square
set title 'FFT\_based fourier integral of e^{-x}' offset 1 font 'Symbol Bold,24'
set key font 'Times Bold,16'
set key right center samplen 0.8 
set logscale y
set format y '10^{%+1T}'
set xrange [-1:21]
set yrange [5*10**-5:2]
set y2range [-0.52:0.02]
set tics nomirror
set ytics out
set y2tics -0.5,0.1,0.1 out
set xlabel font 'Helvetica Bold,18'
set xlabel 'Frequeny (Hz)'
set ylabel font 'Helvetica Bold,18'
set ylabel 'Real magnitude' offset -0.5
set y2label font 'Helvetica Bold,18'
set y2label 'Imaginary magnitude'
plot 'test_dsp_fft1_spec.dat'  u 1:2 axis x1y1 w  l ls 1 title 'Analytic real','' u 1:4 axis x1y1 w  p ls 2 title 'Calculated real','' u 1:3 axis x1y2 w  l ls 3 title 'Analytic imaginary','' u 1:5 axis x1y2 w  p ls 4 title 'Calculated imaginary'
set output
set terminal pop
