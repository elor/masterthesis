#!/usr/bin/env python

import argparse

class floatrange(object):
    min = 0
    max = 0
    def __init__(self, s): 
        tmpval = s.split(':')
        self.min=float(tmpval[0])
        self.max=float(tmpval[1])
        if (self.min > self.max):
            raise argparse.ArgumentTypeError("range: min must be lower than or equal to max")

parser = argparse.ArgumentParser(description='Plot two columns from arbitrary data files against each other')
parser.add_argument('files', metavar='data.txt', type=str, nargs='+', help='data files, containing columns of numerical data')
parser.add_argument('-x', '--xcolumn', dest='xcolumn', type=int, default=1, help='column for x-axis data')
parser.add_argument('-y', '--ycolumn', dest='ycolumn', type=int, default=2, help='column for y-axis data')
parser.add_argument('-f', '--to-file', dest='tofile', action='store_true', help='print to pdf and png files instead of interactive output')
parser.add_argument('--xrange', dest='xrange', type=floatrange, help='x range. Format: "min:max"')
parser.add_argument('--yrange', dest='yrange', type=floatrange, help='y range. Format: "min:max"')
parser.add_argument('--xlog', dest='xlog', action='store_true', help='use a logarithmic scale for the x axis')
parser.add_argument('--ylog', dest='ylog', action='store_true', help='use a logarithmic scale for the y axis')
parser.add_argument('--xlabel', dest='xlabel', type=str, help='x label (LaTeX compatible)')
parser.add_argument('--ylabel', dest='ylabel', type=str, help='y label (LaTeX compatible)')
parser.add_argument('--legend-from-column', dest='legendindex', type=int, help='read legend names from column instead of using the file names. Useful for bar plots. Doesnt do nothing yet')
parser.add_argument('--bar', dest='bar', action='store_true', help='produce a bar plot instead of lines')
parser.add_argument('--style', dest='linestyle', type=str, default='-', help='line style to use for a line plot')

args = parser.parse_args()

import corporate_design
corporate_design.set_layout(layout_type='text', size='small')

import matplotlib
if args.tofile:
    matplotlib.use('PDF')
else:
    pass
    #    matplotlib.use('GTK')

import matplotlib.pyplot as plt
import numpy as np

import sys, re, math
from subprocess import call

import colorsys
#######################################################################################################
# Create colormap.                                                                                    #
# Keyword arguments:                                                                                  #
# h: array of length 2, containing start and end for value for the hue range (default: [0.7, 0.15])   #
# l: same as h but for lightness (default: [0.3, 0.7) )                                               #
# s: same as h but for the saturation (default: [1, 1]) )                                             #
# ncolor: Number of different colors for the color gradient. (default: 100)                           #
# endpoint: shall the second value of the input array be included into the gradient? (default: False) #
#######################################################################################################
def hls_colormap(ncolor=100, endpoint=True, h=[0.0, 1.0], l=[0.5, 0.5], s=[0.8, 0.8]):
    h = np.linspace(h[0], h[1], ncolor, endpoint=endpoint)
    l = np.linspace(l[0], l[1], ncolor, endpoint=endpoint)
    s = np.linspace(s[0], s[1], ncolor, endpoint=endpoint)
    cmap = np.array([h, l, s]).T
    cmap = map(lambda x: colorsys.hls_to_rgb(x[0], x[1], x[2]), cmap)
    cmap = matplotlib.colors.ListedColormap(cmap)
    return cmap

colormaps = {
    'default' : lambda n: hls_colormap(n, False),
}

numfiles = len(args.files)+1
if args.bar and numfiles > 0:
    if numfiles == 1:
        xright = 0.5
    else:
        xright = 0.4
    xleft = -xright
    xwidth = (xright - xleft) / numfiles

colors = colormaps['default'](numfiles)

xmin=1e4
xmax=5e9
base=1.02
sizes = [base**x for x in range(int(math.log(xmin)/math.log(base)), int(math.log(xmax)/math.log(base)))]
data = [ 253+x*94/1024**2 for x in sizes]
plt.plot(sizes, data, '-', color='black', label='Modell')
        
for index, filename in enumerate(args.files):
    data = np.genfromtxt(filename)
    data = np.insert(data, 0, range(0, len(data)), axis=1).transpose()
    tex_compatible_filename = filename.encode('string-escape').replace('_', '\_')
    if args.bar:
        xoffset = xleft + xwidth*index
        plt.bar(data[args.xcolumn]+xoffset, data[args.ycolumn], width=xwidth, color=colors(index+1), label=tex_compatible_filename)
    else:
        plt.plot(data[args.xcolumn], data[args.ycolumn], args.linestyle, color=colors(index+1), label=tex_compatible_filename)

###############
# show legend #
###############
plt.legend()

if args.xlabel:
    plt.xlabel(args.xlabel)
if args.ylabel:
    plt.ylabel(args.ylabel)

ax = plt.axes()
if args.xlog:
    ax.set_xscale('log')
if args.ylog:
    ax.set_yscale('log')

if args.xrange:
    plt.xlim(args.xrange.min, args.xrange.max)

if args.yrange:
    plt.ylim(args.yrange.min, args.yrange.max)

##################################
# adjust plot position on canvas #
##################################
plt.subplots_adjust(bottom=0.22, left=0.17)
plt.minorticks_on()

#########################
# axes labels and ticks #
#########################
#ax = plt.axes()
#ax.xaxis.set_major_locator(MultipleLocator(500))
#ax.xaxis.set_minor_locator(MultipleLocator(100))
#ax.yaxis.set_major_locator(MultipleLocator(0.5))
#ax.yaxis.set_minor_locator(MultipleLocator(0.125))

#ax.xaxis.set_major_formatter (FormatStrFormatter("%3.1f"))
#ax.yaxis.set_major_formatter (FormatStrFormatter("%3.2f"))

#######################
# save as pdf and png #
#######################
if args.tofile:
    print('saving to pdf')
    plt.savefig('plot.pdf')
    plt.close()
    call(["pdf2png.sh", 'plot.pdf'])
else:
    plt.show()
