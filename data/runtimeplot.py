#!/usr/bin/env python

import corporate_design
corporate_design.set_layout(layout_type='text', size='small')

import matplotlib
matplotlib.use('PDF')

import matplotlib.pyplot as plt
import numpy as np

import sys, math
from subprocess import call

import colorsys

########################
# the magical function #
########################
def pmax(size, workerdensity, Tmd, TE, mdsize):
# too accurate version:    return min(math.ceil(math.floor(size/mdsize)**2 * workerdensity), Tmd/TE)
    return min(math.ceil(math.floor((size/mdsize)**2) * workerdensity), Tmd/TE)
################
# end of magic #
################

def runtime(size, workerdensity=0.1, Tmd=20, TE=0.03, mdsize=37, steps=100):
    NE=math.ceil(steps*size*size/550)
    p=pmax(size, workerdensity, Tmd, TE, mdsize)
    if p == 0:
        return 0
    return max(TE+Tmd, NE*TE + NE*Tmd/p)

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

def plotfunctions(functions, pdfname, xmin, xmax):
    indices=[ i for i in functions ]
    indices.sort()

    numfiles = len(functions)

    colors = colormaps['default'](numfiles)

    base=1.02
    sizes = [base**x for x in range(int(math.log(xmin)/math.log(base)), int(math.log(xmax)/math.log(base)))]

    for index, function in enumerate(indices):
        data = np.array([ functions[function](x) for x in sizes ])
        plt.plot(sizes, data, '-', color=colors(index), label=function)

    ###############
    # show legend #
    ###############
    plt.legend()

    #plt.xlabel(r'Substratbreite (\AA)')
    plt.xlabel(r'$w_\text{sim}$ (\AA)')
    #plt.ylabel(r'Parallele Worker')
    plt.ylabel(r'$T_p$')

    ax = plt.axes()
    ax.set_xscale('log')
    ax.set_yscale('log')

    plt.xlim(0, sizes[-1])
    #plt.ylim(1, 100000)
    
    ##################################
    # adjust plot position on canvas #
    ##################################
    plt.subplots_adjust(bottom=0.24, left=0.19)
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
    print('saving to %s'%pdfname)
    plt.savefig(pdfname)
    plt.close()
    call(["pdf2png.sh", pdfname])


###########################
# plot runtime by density #
###########################

functions={
    r'$\rho_\text{worker}=0.1$':lambda x: runtime(x, workerdensity=0.1),
    r'$\rho_\text{worker}=0.4$':lambda y: runtime(y, workerdensity=0.4),
    r'$\rho_\text{worker}=1.0$':lambda z: runtime(z, workerdensity=1.0),
}
plotfunctions(functions, 'runtimebydensity.pdf', 100, 30000)

###############################
# plot runtime by MD duration #
###############################

functions={
    r'$T_\text{MD}=05$':lambda x: runtime(x, Tmd=5),
    r'$T_\text{MD}=15$':lambda y: runtime(y, Tmd=15),
    r'$T_\text{MD}=60$':lambda z: runtime(z, Tmd=60),
}
plotfunctions(functions, 'runtimebymdtime.pdf', 100, 40000)

################################
# plot runtime by KMC duration #
################################

functions={
    r'$T_\text{E}=0.03$':lambda x: runtime(x, TE=0.03),
    r'$T_\text{E}=0.01$':lambda y: runtime(y, TE=0.01),
    r'$T_\text{E}=0.003$':lambda z: runtime(z, TE=0.003),
}
plotfunctions(functions, 'runtimebykmctime.pdf', 200, 50000)

###########################
# plot runtime by MD size #
###########################

functions={
    r'$w_\text{MD}=25$':lambda x: runtime(x, mdsize=25, TE=0.02, Tmd=3),
    r'$w_\text{MD}=37$':lambda y: runtime(y, mdsize=37, TE=0.03, Tmd=5),
    r'$w_\text{MD}=50$':lambda z: runtime(z, mdsize=50, TE=0.04, Tmd=9)
}
plotfunctions(functions, 'runtimebymdsize.pdf', 100, 15000)
