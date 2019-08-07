.. _maxilab:

****************************************
MaxiLab: Exploring the Instability Strip
****************************************

Overview
========

In the MiniLabs, we've been running GYRE within the adiabatic
approximation, where thermal exchanges between neighboring oscillating
elements is neglected. For main sequence stars, these exchanges
typically have only a small effect on the periods/frequencies of
oscillation modes; and so, if we're interested mainly in interpreting
these periods, the approximation is usually a good one.

In the MaxiLab, we're going to move beyond the adiabatic
approximation. This will allow us to explore which modes are unstable
in our model star, and by what mechanism. Then, by extending these
non-adiabatic calculations to stars with other masses, we will map out
the :\math:`\beta Cepheid` instability strip.

As the very first step, make a copy of your
working directory from MiniLab 3 (with all the changes you have made):

.. code-block:: console

   $ cp -a townsend-2019-mini-2 townsend-2019-maxi
   $ cd townsend-2019-maxi

Alternatively, if you were unable to get things working with MiniLab
3, then you can grab a working directory for the MaxiLab from `here
<http://www.astro.wisc.edu/~townsend/resource/teaching/summer-school-2019/townsend-2019-maxi.tar.gz>`_.

Enabling Non-Adiabatic Effects
==============================

Enabling non-adiabatic effects in GYRE is straightforward: simply add
the following highlighted code to ``gyre.in``:

.. code-block:: fortran
   :emphasize-lines: 3
	
   &osc
	inner_bound = 'ZERO_R'
	nonadiabatic = .true.
   /
	
If you repeat the ZAMS-to-TAMS evolution with this modification,
things will appear largely unchanged from MiniLab 3; that's because,
as mentioned above, the mode periods are scarecely affected by thermal
exchanges. However, a big difference from previous runs is that the
mode frequencies calculated by GYRE are now complex quantities.

Printing Growth/Decay Rates
---------------------------

GYRE assumes that the perturbation :math:`f'(t)` to some quantity
:math:`f`, caused by an oscillation mode with angular frequency
:math:`\sigma`, takes the form

.. math::

   f'(t) \propto \exp( -{\rm i} \sigma t ).

If we decompose :math:`\sigma` into real (:math:`\sigma_{\rm R}`) and
imaginary (:math:`\sigma_{\rm I}`) parts, this becomes

.. math::

   f'(t) \propto \exp (- {\rm i} \sigma_{\rm R} t) \, \exp ( \sigma_{\rm I} t).

Hence, over time :math:`f'` oscillates with period :math:`P =
2\pi/\sigma_{\rm R}`, but also experiences exponential growth with a
rate given by :math:`\sigma_{\rm I}`. If :math:`\sigma_{\rm I}` is
negative, then decay rather than growth occurs. Hence, the sign of
:math:`\sigma_{\rm I}` indicates whether the mode is unstable
(growing) or stable (decaying).

To see whether the modes in the ZAMS-to-TAMS run are stable or
unstable, modify the ``print`` statement in the ``run_gyre`` subroutine of
``run_star_extras.f90`` to display growth rates:

.. code-block:: fortran

      ! Print out radial order, frequency and growth rate

      print *, 'Found mode: radial order, frequency, growth = ', &
               md%n_pg, REAL(md%freq('HZ')), 2.*PI*AIMAG(md%freq('HZ'))

(The extra factor of ``2.*PI`` appears because the
``md%freq('HZ')`` function returns the linear frequency, rather
than the angular frequency).

.. admonition:: Exercise

   With the above modification, repeat the ZAMS-to-TAMS run. Where in
   the run do the fundamental and first-overtone radial modes
   transition from stable to unstable?

Adding Growth Rates to History Output
-------------------------------------

As the next step, we'll add two extra columns to history output, to
store the growth rates for the fundamental and first-overtone
modes.

.. admonition:: Exercise

   Using a similar approach as we did for the mode periods in
   :ref:`MiniLab 2 <minilab-2>`, modify ``run_star_extras.f90`` to add
   the extra history columns. This will involve creating two new
   module variables to store the growth rates (call them
   ``growth_f`` and ``growth_1o``); changing the ``run_gyre``
   subroutine to store data into these columns; and changing the
   ``how_many_extra_history_columns`` and
   ``data_for_extra_history_columns`` hooks.

Once you've made these changes, do a ZAMS-to-TAMS run and confirm that
the columns appear correctly in the history file.

Plotting the Growth Rates
-------------------------

Let's now update the PGstar plots to show the growth rates.

.. admonition:: Exercise

   Edit ``inlist_to_tams_pgstar``, changing the history panel so that
   it shows the growth rates instead of the dynamical timescale. Be
   sure to remove (or comment out) the
   ``History_Panels1_other_ymin(1)`` and
   ``History_Panels1_other_ymin(2)``, to ensure the plots show
   positive *and* negative growth rates.

Exploring the Driving
=====================

The preceding steps establish that the fundamental and first-overtone
radial modes become unstable when the star reaches an age
:math:`\approx 7\,{\rm Myr}`, about halfway through its main-sequence
evolution. Because our model is representative of a :math:`\beta`
Cepheid star, we expect the :math:`kappa` mechanism operating on the
iron opacity bump is responsible for the modes' instability. We're
going to confirm that this is the case.
