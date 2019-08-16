#!/usr/bin/env python

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as plticker
import scipy.interpolate as ip

from mesa import *
from colors import *

plt.style.use('web.mplstyle')

# Read data

data_g, data_p = read_mesa_profile('profile3.data')

# Interpolate opacity data onto radius grid

r = data_p['radius']
r_mid = data_p['rmid']

kap_mid = data_p['opacity']
kapT = data_p['dkap_dlnT_face']
kapd = data_p['dkap_dlnrho_face']

kapi = ip.interp1d(r_mid, kap_mid, kind='linear', fill_value='extrapolate')

kap = kapi(r)

logT = data_p['logT']

# Plot

fig, ax = plt.subplots(2, sharex=True)

ax[0].plot(logT, np.log10(kap), color=BLACK)
ax[1].plot(logT, kapT/kap, color=ORANGE)
#ax[2].plot(logT, kapd/kap, color=SKY_BLUE)

ax[1].set_xlim(7.4, 4.49)

ax[1].set_xlabel(r'$\log T$')

ax[0].set_ylabel(r'$\log \kappa$')
ax[1].set_ylabel(r'$(\partial \ln \kappa/\partial \ln T)_{\rho}$')
#ax[2].set_ylabel(r'$(\partial \ln \kappa/\partial \ln \rho)_{T}$')

#ax.xaxis.set_major_locator(plticker.MultipleLocator(0.5))
#ax.yaxis.set_major_locator(plticker.MultipleLocator(50))

fig.tight_layout()
fig.savefig('fig_opacity.png')
