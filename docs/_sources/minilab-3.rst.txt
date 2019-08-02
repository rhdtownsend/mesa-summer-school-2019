.. _minilab-3:

*********************************
MiniLab 3: Plotting Wavefunctions
*********************************

Overview
========

In Minilab 2, we found that the periods of the fundamental and
first-overtone radial modes scale approximately with the dynamical
timescale, :math:`P \propto \tau_{\rm dyn}`. In MiniLab 3, we're going
to examine the mode radial displacement wavefunctions :math:`\xi_{r}`,
which set the constant of proportionality in this scaling. The steps
are similar to before: first we'll add the :math:`\xi_{r}` data to
MESA's profile output, and then modify ``inlist_to_tams_pgstar`` to
plot these wavefunctions. As the very first step, make a copy of your
working directory from MiniLab 2 (with all the changes you have made):

.. code-block:: console

   $ cp -a townsend-2019-mini-2 townsend-2019-mini-3
   $ cd townsend-2019-mini-3

Alternatively, if you were unable to get things working with MiniLab
2, then you can grab a working directory for MiniLab 3 from `here
<http://www.astro.wisc.edu/~townsend/resource/teaching/summer-school-2019/townsend-2019-mini-3.tar.gz>`_.

Adding Wavefunctions to Profile Output
======================================

As with the mode periods, to communicate data from ``process_mode`` to
other routines in ``run_star_extras.f90``, we'll make use of module
variables.

Adding Module Variables
-----------------------

Add the following highlighted code at the appropriate place near the
top of ``run_star_extras.f90``:

.. code-block:: fortran
    :emphasize-lines: 8-

    ! >>> Insert module variables below

    ! Periods of fundamental and first overtone

    real(dp), save :: period_f
    real(dp), save :: period_1o

    real(dp), allocatable, save :: xi_r_f(:)
    real(dp), allocatable, save :: xi_r_1o(:)

Note that we declare the variables as allocatable arrays --- that's
because the displacement wavefunctions are functions of position
within the star.

Setting Module Variables
------------------------

Next, modify the ``process_mode`` callback routine to set the two two
module variables. GYRE provides the radial displacement wavefunction
at the ``k``'th grid point via the ``md%xi_r(k)`` function. However, a
wrinkle here is that GYRE indexes its grid points in the opposite
order to MESA. With this in mind, the following highlighted code
illustrates how to set up the ``xi_r_f`` variable for the fundamental
mode:

.. code-block:: fortran
     :emphasize-lines: 11-

     ! Print out radial order and eigenfrequency

     print *, 'Found mode: radial order, frequency = ', md%n_pg, REAL(md%freq('HZ'))

      ! If this is the fundamental mode, store the period

      if (md%n_pg == 1) then
         period_f = 1. / (3600.*REAL(md%freq('HZ')))
      end if

      ! If this is the fundamental mode, store the radial displacement
      ! wavefunction

      if (md%n_pg == 1) then

         if (allocated(xi_r_f)) deallocate(xi_r_f)
         allocate(xi_r_f(md%n_k))

         do k = 1, md%n_k
            xi_r_f(k) = md%xi_r(k)
         end do

	 xi_r_f = xi_r_f(md%n_k:1:-1)

      endif

Note how we first deallocate ``xi_r_f`` (if currently allocated), and
then allocate it at the correct size (``md%n_k`` is the number of grid
points). Note also how we reverse the order of elements in ``xi_r_f``
after setting it up.

.. admonition:: Exercise
      
   Add further code to ``process_mode``, to store the radial
   displacement wavefunction of the first overtone into ``xi_r_1o``.
   
Adding Profile Columns
----------------------

Next, we'll add two extra columns to history output, in
which we'll store the radial displacement wavefunctions we've calculated.

.. admonition:: Exercise

   Modify ``how_many_extra_profile_columns`` to set the number of
   columns, and ``data_for_extra_profile_columns`` to set up the names
   and values of the columns.

Running the Code
================

With these changes to ``run_star_extras.f90``, re-compile and re-run
the code.

.. admonition:: Exercise

   Check that the profile files written to ``LOGS/history.data`` contain
   two extra columns, containing the radial displacement wavefunction data.

Plotting the Wavefunctions
==========================

Our final step is to add a PGstar window to our ZAMS-to-TAMS run,
showing how the mode radial displacement wavefunctions change as the
star evolves. For this window, we'll use a 'profile panel'.

.. admonition:: Exercise

   Have a look through ``$MESA_DIR/star/defaults/pgstar.defaults`` to
   get an idea how profile panels work. Then, add a profile panel
   window showing ``xi_r_f`` on the y-axis, and ``xi_r_1o`` on the
   'other' y-axis. Plot these quantities versus :math:`\log(1-m/M)`, which
   is available in profile data as ``logxq``.

Looking at the wavefunctions, we can clearly see the key difference
between the radial and first-overtone modes: the latter changes sign
somewhere between the center and the surface, while the former does
not. This sign change means that the effective wavelength of the first
overtone is shorter --- and hence, its frequency is higher, and its
period shorter.
