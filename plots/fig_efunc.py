#!/usr/bin/env python

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as plticker
import scipy.interpolate as ip

from gyre import *
from colors import *

plt.style.use('web.mplstyle')

# Read data

d1, r1 = read_output('det.l0.n+1.h5')
d2, r2 = read_output('det.l0.n+2.h5')
d3, r3 = read_output('det.l0.n+3.h5')

# Plot

fig, ax = plt.subplots()

ax.plot(r1['x'], r1['xi_r']/r1['xi_r'][-1], label=r'$n=1\, (\sigma = {:3.1f})$'.format(d1['omega'].real), color=BLACK)
ax.plot(r2['x'], r2['xi_r']/r2['xi_r'][-1], label=r'$n=2\, (\sigma = {:3.1f})$'.format(d2['omega'].real), color=ORANGE)
ax.plot(r3['x'], r3['xi_r']/r3['xi_r'][-1], label=r'$n=3\, (\sigma = {:3.1f})$'.format(d3['omega'].real), color=SKY_BLUE)

ax.axhline(dashes=(4,2), color=BLACK, lw=1)

ax.set_xlabel(r'$x \equiv r/R$')
ax.set_ylabel(r'$\xi_{r}/R$')

ax.set_xlim(0,1)

ax.legend(loc=2)

fig.tight_layout()
fig.savefig('fig_efunc.png')
