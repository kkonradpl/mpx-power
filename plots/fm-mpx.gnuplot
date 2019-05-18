#!/usr/bin/gnuplot
# Author: Konrad Kosmatka, 2019

# Configuration
deviation_limit = 75
deviation_alert = 77
mpxpower_limit = 3.0
mpxpower_alert = NaN

name = "881"; title = "88.1 RPL FM (Płock – Radziwie)"
#name = "904"; title = "90.4 VOX FM (Płock – Kochanowskiego)"
#name = "910"; title = "91.0 RMF FM (Warszawa – Raszyn)"
#name = "922"; title = "92.2 PR 1 (Sierpc – Rachocin)"
#name = "931"; title = "93.1 RMF Classic (Płock – Radziwie)"
#name = "943"; title = "94.3 RMF FM (Sierpc – Rachocin)"
#name = "952"; title = "95.2 Eska Płock (Płock – Kochanowskiego)"
#name = "961"; title = "96.1 PR 3 (Sierpc – Rachocin)"
#name = "973"; title = "97.3 Radio Zet (Sierpc – Rachocin)"
#name = "981"; title = "98.1 PR 2 (Sierpc – Rachocin)"
#name = "992"; title = "99.2 PR Łódź (Łódź – EC4)"
#name = "1012"; title = "101.2 TOK FM (Płock – Radziwie)"
#name = "1016"; title = "101.6 PR 1 (Kutno – Komin)"
#name = "1019"; title = "101.9 RDC (Sierpc – Rachocin)"
#name = "1035"; title = "103.5 Radio Victoria (Łowicz – Seminaryjna)"
#name = "1043"; title = "104.3 KRDP (Płock – Orlen)"
#name = "1063"; title = "106.3 Radio Maryja (Sierpc – Rachocin)"
#name = "1078"; title = "107.8 PR 1 (Łódź – EC4)"

path_dev = sprintf("./%s/deviation.raw", name)
path_mpx = sprintf("./%s/mpxpower.raw", name)
path_output = sprintf("%s.png", name)

font_title = "SF Pro Text, 18"
font_desc = "SF Pro Text, 14"
font_axis = "DejaVu Sans, 11"

color_grid = "#000000"
color_plot = "#0066FF"
color_limit = "#F96F14"
color_alert = "#FF0000"

hist_min = 0
hist_max = 100
hist_count = 100
hist_width = (hist_max-hist_min)/hist_count
hist(x,width)=width*floor(x/width)+width/2.0

# Output format
set terminal pngcairo size (hist_max*10)+125,700
set output path_output
set multiplot layout 2, 1 title title font font_title offset 0, -0.25

# Load stats
stats path_dev binary format="%float" u (DEVlast=$1) prefix "DEV"
stats path_mpx binary format="%float" u (MPXlast=$1) prefix "MPX"


# First plot (deviation)
reset
set size 1,0.5
set origin 0.0,0.45

set style line 1 linecolor rgbcolor color_plot linewidth 2.0
set style line 2 linecolor rgbcolor color_limit linewidth 1.5 dt '_'
set style line 3 linecolor rgbcolor color_alert linewidth 1.5 dt '_'
set style fill solid 0.5
set boxwidth hist_width

set grid linewidth 1 linecolor rgb color_grid
set xlabel sprintf("Peak deviation [kHz] /max: {/:Bold %.1f}, min: {/:Bold %.1f}, avg: {/:Bold %.1f}, last: {/:Bold %.1f} kHz/", DEV_max, DEV_min, DEV_mean, DEVlast) font font_desc
set ylabel sprintf("Number of samples (total: %d)", DEV_records) font font_desc

set tics front
set xtics border 5 nomirror out font font_axis scale 0.75 
set ytics axis font font_axis scale 0.75

set xrange [hist_min:hist_max]

set arrow from deviation_limit, graph 0 to deviation_limit, graph 1 nohead front ls 2
set arrow from deviation_alert, graph 0 to deviation_alert, graph 1 nohead front ls 3
plot path_dev binary format="%float" u (hist($1,hist_width)) smooth freq w boxes ls 1 notitle 


# Second plot (MPX power)
reset
set size 1, 0.45

set style line 1 linecolor rgbcolor color_plot linewidth 2.0
set style line 2 linecolor rgbcolor color_limit linewidth 1.5 dt '_'
set style line 3 linecolor rgbcolor color_alert linewidth 1.5 dt '_'

set grid linewidth 1 linecolor rgb color_grid
set xlabel sprintf("Time [minutes] /max: {/:Bold %.2f}, min: {/:Bold %.2f}, avg: {/:Bold %.2f}, last: {/:Bold %.2f} dBr/", MPX_max, MPX_min, MPX_mean, MPXlast) font font_desc
set ylabel "MPX power [dBr]"

set tics front
set xtics border ceil(MPX_records/1800.0) nomirror out font font_axis scale 0.75 
set ytics axis font font_axis scale 0.75

set format x "%.0f"

if(MPXlast != MPXlast) set xrange [0:0] # NaN
if(MPX_max < mpxpower_limit || MPX_max < mpxpower_alert) set yrange [:mpxpower_limit+(mpxpower_limit-MPX_min)*0.05]
if(MPX_min > mpxpower_limit || MPX_min > mpxpower_alert) set yrange [mpxpower_limit-(MPX_max-mpxpower_limit)*0.05:]

set arrow from graph 0, first mpxpower_limit to graph 1, first mpxpower_limit nohead ls 2
if(MPX_max >= mpxpower_alert) set arrow from graph 0, first mpxpower_alert to graph 1, first mpxpower_alert nohead ls 3
plot path_mpx binary format="%float" u ($0/60.0):1 with line ls 1 notitle
