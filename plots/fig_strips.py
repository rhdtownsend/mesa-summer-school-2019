#!/usr/bin/env python

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as plticker
import scipy.interpolate as ip

import pandas
import mesa

from colors import *

# Read data

# Spreadsheet

df = pandas.read_csv('strips.csv', 
                     header=0,
                     skiprows=1,
                     names=['Task', 'Name',
                            'logT_a_1.00', 'logT_b_1.00', 'logL_a_1.00', 'logL_b_1.00',
                            'logT_a_0.75', 'logT_b_0.75', 'logL_a_0.75', 'logL_b_0.75',
                            'logT_a_0.50', 'logT_b_0.50', 'logL_a_0.50', 'logL_b_0.50'])

# Tracks

# Solar

tracks_solar = ['6.0_history.data',
                '7.67_history.data',
                '10.07_history.data',
                '10_23_history.data',
                '17.39_history.data',
                '22.84_history.data',
                '30_history.data']

d_solar = []
r_solar = []

for i, track in enumerate(tracks_solar):
    d, r = mesa.read_mesa_log('data_solar/{:s}'.format(track))
    d_solar += [d]
    r_solar += [r]

# 75

tracks_75 = ['6.0_history.data',
             '7.67_history.data',
             '10.07_history.data',
             '10_23_history.data',
             '17.39_history.data',
             '22.84_history.data',
             '30_history.data']

d_75 = []
r_75 = []

for i, track in enumerate(tracks_75):
    d, r = mesa.read_mesa_log('data_solar/{:s}'.format(track))
    d_75 += [d]
    r_75 += [r]

# 50

tracks_50 = ['6.0_history.data',
             '7.67_history.data',
             '10.07_history.data',
             '10_23_history.data',
             '17.39_history.data',
             '22.84_history.data',
             '30_history.data']

d_50 = []
r_50 = []

for i, track in enumerate(tracks_50):
    d, r = mesa.read_mesa_log('data_solar/{:s}'.format(track))
    d_50 += [d]
    r_50 += [r]

# Create the plots

def do_plot (ax, r, df, suffix):

    for i in range(len(r)):

        ax.plot(r[i]['log_Teff'], r[i]['log_L'], color=BLACK, lw=1)

        label = r'${:3.1f}\,{{\rm M_{{\odot}}}}$'.format(r[i]['star_mass'][0])
        xy = (r[i]['log_Teff'][0], r[i]['log_L'][0])
        xytext = (-3,-5)
        ax.annotate(label, xy, xytext=xytext, ha='right', textcoords='offset points')

    ax.set_xlabel(r'$\log [T_{\rm eff}/{\rm K}]$')
    ax.set_ylabel(r'$\log [L/{\rm L_{\odot}}]$')

    ax.xaxis.set_minor_locator(plticker.MultipleLocator(0.01))
    ax.yaxis.set_minor_locator(plticker.MultipleLocator(0.1))

    logT_a = np.array(df['logT_a_{:s}'.format(suffix)])
    logT_b = np.array(df['logT_b_{:s}'.format(suffix)])

    logL_a = np.array(df['logL_a_{:s}'.format(suffix)])
    logL_b = np.array(df['logL_b_{:s}'.format(suffix)])

    names = np.array(df['Name'])

    ax.scatter(logT_a, logL_a, color=ORANGE, label='Hot Edge')
    ax.scatter(logT_b, logL_b, color=SKY_BLUE, label='Cool Edge')

    for i in range(len(logT_a)):
        if not np.isnan(logT_a[i]):
            xy = (logT_a[i], logL_a[i])
            xytext = (-2,0)
#            ax.annotate(names[i], xy, xytext=xytext, textcoords='offset points', ha='right', fontsize=4)

    for i in range(len(logT_b)):
        if not np.isnan(logT_b[i]):
            xy = (logT_b[i], logL_b[i])
            xytext = (-2,0)
#            ax.annotate(names[i], xy, xytext=xytext, textcoords='offset points', ha='right', fontsize=4)

    ax.legend(loc=1)

# Solar

fig, ax = plt.subplots()

do_plot(ax, r_solar, df, '1.00')

ax.set_xlim(4.67, 4.17)
ax.set_ylim(2.9, 5.5)

ax.set_title('Solar Metallicity')

fig.tight_layout()
fig.savefig('output/fig_strips_1.00.pdf')
fig.savefig('output/fig_strips_1.00.png')

# 75% solar

fig, ax = plt.subplots()

do_plot(ax, r_75, df, '0.75')

ax.set_xlim(4.67, 4.17)
ax.set_ylim(2.9, 5.5)

ax.set_title('75% Solar Metallicity')

fig.tight_layout()
fig.savefig('output/fig_strips_0.75.pdf')
fig.savefig('output/fig_strips_0.75.png')

# 50% solar

fig, ax = plt.subplots()

do_plot(ax, r_50, df, '0.50')

ax.set_xlim(4.67, 4.17)
ax.set_ylim(2.9, 5.5)

ax.set_title('50% Solar Metallicity')

fig.tight_layout()
fig.savefig('output/fig_strips_0.50.pdf')
fig.savefig('output/fig_strips_0.50.png')



