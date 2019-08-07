.. _maxilab:

****************************************
MaxiLab: Exploring the Instability Strip
****************************************

Overview
========

In the MiniLabs, we've been running GYRE within the adiabatic
approximation, where thermal exchanges between neighboring oscillating
elements are neglected. For main-sequence stars, these exchanges
typically have only a small effect on the periods/frequencies of
oscillation modes; and so, if we're interested mainly in interpreting
these periods, the approximation is usually a good one.

In the MaxiLab, we're going to move beyond the adiabatic
approximation. This will allow us to explore which modes are unstable
in our model star, and by what mechanism. Then, by extending these
non-adiabatic calculations to stars with other masses, we will map out
the :math:`\beta` Cephei instability strip.

As the very first step, make a copy of your
working directory from MiniLab 3 (with all the changes you have made):

.. code-block:: console

   $ cp -a townsend-2019-mini-3 townsend-2019-maxi
   $ cd townsend-2019-maxi

Alternatively, if you were unable to get things working with MiniLab
3, then you can grab a working directory for the MaxiLab from `here
<http://www.astro.wisc.edu/~townsend/resource/teaching/mesa-summer-school-2019/townsend-2019-maxi.tar.gz>`__.

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
as mentioned above, the mode periods are scarcely affected by thermal
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
unstable, modify the ``print`` statement in the ``process_mode``
callback of ``run_star_extras.f90`` to display growth rates:

.. code-block:: fortran
      :emphasize-lines: 3-

      ! Print out radial order, frequency and growth rate

      print *, 'Found mode: radial order, frequency, growth rate = ', &
           md%n_pg, REAL(md%freq('HZ')), 2.*PI*AIMAG(md%freq('HZ'))

(The extra factor of ``2.*PI`` appears because the
``md%freq('HZ')`` function returns the linear frequency, rather
than the angular frequency).

.. admonition:: Exercise

   With the above modification, repeat the ZAMS-to-TAMS run. Where in
   the run do the F and 1-O modes transition from stable to unstable?

Adding Growth Rates to History Output
-------------------------------------

As the next step, we'll add two extra columns to history output, to
store the growth rates for the F and 1-O modes.

.. admonition:: Exercise

   Using a similar approach as we did for the mode periods in
   :ref:`MiniLab 2 <minilab-2>`, modify ``run_star_extras.f90`` to add
   the growth rates.  In brief,

   - create two new module variables to store the growth rates (call
     them ``growth_f`` and ``growth_1o``).

   - change the ``process_mode`` callback to store data into these variables.

   - change the ``how_many_extra_history_columns`` and
     ``data_for_extra_history_columns`` hooks to copy data from these
     variables into the new columns.

Once you've made these changes, do a ZAMS-to-TAMS run and confirm that
the columns appear correctly in the history file.

Plotting the Growth Rates
-------------------------

Let's now update the PGstar plots to show the growth rates.

.. admonition:: Exercise

   Edit ``inlist_to_tams_pgstar``, changing the history panel so that
   it shows the growth rates on the right-hand axes instead of the
   dynamical timescale. Be sure to remove (or comment out) the
   ``History_Panels1_other_ymin(1)`` and
   ``History_Panels1_other_ymin(2)``, to ensure the plots show
   positive *and* negative growth rates.

Exploring the Driving
=====================

If all went well, the preceding steps will have established that the F
and 1-O modes become unstable when the star reaches an age
:math:`\approx 9\,{\rm Myr}`, about three-quarters of the way through
its main-sequence evolution. Because our model is representative of a
:math:`\beta` Cephei star, we expect the :math:`\kappa` mechanism
operating on the iron opacity bump is responsible for driving the
modes toward instability. We're going to confirm that this is the
case.

Adding Differential Work to Profile Output
------------------------------------------

To analyze where in the star a given mode is being driven and/or
damped, we study the differential work :math:`{\rm d}W/{\rm d}x`. The change
:math:`W` in the mode energy over one pulsation cycle is given by the integral

.. math::

   W = \int_{0}^{1} \frac{{\rm d}W}{{\rm d}x} \, {\rm d} x,

where :math:`x \equiv r/R` is the fractional radius.

It can be shown that :math:`W \propto \sigma_{\rm I}`; it therefore
follows that if :math:`W > 0` then the mode is unstable. Clearly,
regions of the star where :math:`{\rm d}W/{\rm d}x > 0` contribute
toward driving the mode, while regions with :math:`{\rm d}W/{\rm d}x <
0` contribute toward damping.

.. admonition:: Exercise

   Using a similar approach as we did for the displacement
   wavefunctions in :ref:`MiniLab 3 <minilab-3>`, modify
   ``run_star_extras.f90`` to add the differential work for the F and
   1-O modes to the profile output.  In brief,

   - create two new module variables to store the differential work (call
     them ``work_f`` and ``work_1o``).

   - change the ``process_mode`` callback to store data into these
     variables. (GYRE provides the differential work at the ``k``'th
     grid point via the ``md%dW_dx(k)`` function).

   - change the ``how_many_extra_profile_columns`` and
     ``data_for_extra_profile_columns`` hooks to copy data from these
     variables into the new columns.

Plotting the Differential Work
------------------------------

To view the fruits of our labor, let's now add a profile panel to show
the differential work data.

.. admonition:: Exercise

   Edit ``inlist_to_tams_pgstar``, adding a second profile panel that
   plots the differential work for the two modes. For the x-axis, use
   ``logT`` instead of ``logxm`` (this allows us to see what the
   temperature is in the driving/damping regions). On the right-hand
   axes, plot the log of the opacity.

Repeat the ZAMS-to-TAMS run, and think about the following questions:

- Where in the star is the driving strongest?

- How does this driving region relate to the peak in the opacity data
  around :math:`\log T \approx 5.3` (the 'iron bump')?

- Where in the star does damping occur?

- What happens as the star evolves?

To get a better sense of the relative strengths of the driving and
damping, it's better to plot :math:`{\rm d}W/{\rm d}\ln T` instead of
:math:`{\rm d}W/{\rm d}x`; this is because, when we use :math:`\log T`
on the x-axis, the area under the former is directly proportional to
the amount of driving or damping. If we know the local pressure scale height

.. math::

   H_{P} \equiv \left( \frac{{\rm d}\ln P}{{\rm d}r} \right)^{-1}

and dimensionless temperature gradient

.. math::

   \nabla \equiv \left( \frac{{\rm d}\ln T}{{\rm d}\ln P} \right),

then we can easily calculate :math:`{\rm d}W/d\ln T` from :math:`{\rm
d}W/{\rm d}x` via

.. math::

   \frac{{\rm d}W}{{\rm d}\ln T} = \frac{{\rm d}W}{{\rm d}x} \frac{H_P}{R \nabla}

(here, :math:`R` is the stellar radius).

 .. admonition:: Optional Exercise

    Modify ``run_star_extras.f90`` to store :math:`{\rm d}W/{\rm d}\ln
    T` instead of :math:`{\rm d}W/{\rm d}x` in the ``work_f`` and
    ``work_1f`` variables.

Mapping the Instability Strip
=============================

As the final part of the MaxiLab, we're going to use GYRE and MESA to
map out the extent of the :math:`beta` Cephei instability strip for
radial modes.

Picking a Mass
--------------

Visit the Google docs spreadsheet `here
<https://docs.google.com/spreadsheets/d/1c3WuXlwzN944kdXWkwg7bO526MdZxiZeHAC4iK4T0NA/edit?usp=sharing>`__,
and claim a stellar mass (listed in the first column) by adding your
name in the second column.

