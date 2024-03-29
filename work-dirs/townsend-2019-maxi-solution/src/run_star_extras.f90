! ********************************************
!
!   run_star_extras file for GYRE-in-MESA Labs
!
! ********************************************

module run_star_extras

  use star_lib
  use star_def
  use const_def
  use crlibm_lib

  ! >>> Insert additional use statements below

  use gyre_lib

  implicit none

  ! >>> Insert module variables below

  ! Periods of F and 1-O modes

  real(dp), save :: period_f
  real(dp), save :: period_1o

  ! Growth rates of F and 1-O modes

  real(dp), save :: growth_f
  real(dp), save :: growth_1o

  ! Displacement wavefunctions of F and 1-O modes

  real(dp), allocatable, save :: xi_r_f(:)
  real(dp), allocatable, save :: xi_r_1o(:)

  ! Differential work functions of F and 1-O modes

  real(dp), allocatable, save :: dW_dx_f(:)
  real(dp), allocatable, save :: dW_dx_1o(:)

  real(dp), allocatable, save :: dW_dlnT_f(:)
  real(dp), allocatable, save :: dW_dlnT_1o(:)

  ! Flag to indicate if GYRE has run

  logical, save :: gyre_has_run

contains

  subroutine extras_controls(id, ierr)

    integer, intent(in) :: id
    integer, intent(out) :: ierr
    type (star_info), pointer :: s

    ierr = 0

    call star_ptr(id, s, ierr)
    if (ierr /= 0) return

    ! Set procedure pointers

    s%extras_startup => extras_startup
    s%extras_start_step => extras_start_step
    s%extras_check_model => extras_check_model

    s%how_many_extra_history_columns => how_many_extra_history_columns
    s%data_for_extra_history_columns => data_for_extra_history_columns
    s%how_many_extra_profile_columns => how_many_extra_profile_columns
    s%data_for_extra_profile_columns => data_for_extra_profile_columns  

    ! Disable printed warning message

    s%job%warn_run_star_extras =.false.       

  end subroutine extras_controls

  !****

  integer function extras_startup(id, restart, ierr)

    integer, intent(in) :: id
    logical, intent(in) :: restart
    integer, intent(out) :: ierr

    type (star_info), pointer :: s

    ierr = 0

    call star_ptr(id, s, ierr)
    if (ierr /= 0) return

    ! >>> Insert additional code below

    ! Initialize GYRE

    call gyre_init('gyre.in')

    ! Set constants

    call gyre_set_constant('G_GRAVITY', standard_cgrav)
    call gyre_set_constant('C_LIGHT', clight)
    call gyre_set_constant('A_RADIATION', crad)

    call gyre_set_constant('M_SUN', msol)
    call gyre_set_constant('R_SUN', rsol)
    call gyre_set_constant('L_SUN', lsol)

    ! Set return value

    extras_startup = 0

  end function extras_startup

  !****

  integer function extras_start_step(id, id_extra)

    integer, intent(in) :: id, id_extra
    integer :: ierr
    type (star_info), pointer :: s

    ierr = 0

    call star_ptr(id, s, ierr)
    if (ierr /= 0) return

    ! >>> Insert additional code below

    ! Reset the gyre_has_run flag

    gyre_has_run = .false.

    ! Set return value

    extras_start_step = 0

  end function extras_start_step

  !****

  integer function extras_check_model(id, id_extra)

    integer, intent(in) :: id, id_extra
    integer :: ierr

    type (star_info), pointer :: s

    ierr = 0

    call star_ptr(id, s, ierr)
    if (ierr /= 0) return

    ! >>> Insert additional code below

    if (s%x_logical_ctrl(1)) then
       call run_gyre(id, ierr)
    endif

    ! Set return value

    extras_check_model = keep_going

  end function extras_check_model

  !****

  integer function how_many_extra_history_columns(id, id_extra)

    integer, intent(in) :: id, id_extra
    integer :: ierr

    type (star_info), pointer :: s

    ierr = 0

    call star_ptr(id, s, ierr)
    if (ierr /= 0) return

    ! >>> Change number of history columns below

    how_many_extra_history_columns = 4

  end function how_many_extra_history_columns

  !****

  subroutine data_for_extra_history_columns(id, id_extra, n, names, vals, ierr)

    integer, intent(in) :: id, id_extra, n
    character (len=maxlen_history_column_name) :: names(n)
    real(dp) :: vals(n)
    integer, intent(out) :: ierr

    type (star_info), pointer :: s

    ierr = 0
    call star_ptr(id, s, ierr)

    if (ierr /= 0) return

    ! >>> Insert code to set history column names/values below

    names(1) = 'period_f'
    names(2) = 'period_1o'

    names(3) = 'growth_f'
    names(4) = 'growth_1o'

    if (s%x_logical_ctrl(1)) then

       vals(1) = period_f
       vals(2) = period_1o

       vals(3) = growth_f
       vals(4) = growth_1o

    else

       vals(1) = 0.
       vals(2) = 0.

       vals(3) = 0.
       vals(4) = 0.

    endif

  end subroutine data_for_extra_history_columns

  !****

  integer function how_many_extra_profile_columns(id, id_extra)

    use star_def, only: star_info

    integer, intent(in) :: id, id_extra
    integer :: ierr

    type (star_info), pointer :: s

    ierr = 0

    call star_ptr(id, s, ierr)
    if (ierr /= 0) return

    ! >>> Change number of profile columns below

    how_many_extra_profile_columns = 6

  end function how_many_extra_profile_columns

  !****

  subroutine data_for_extra_profile_columns(id, id_extra, n, nz, names, vals, ierr)

    use star_def, only: star_info, maxlen_profile_column_name
    use const_def, only: dp

    integer, intent(in) :: id, id_extra, n, nz
    character (len=maxlen_profile_column_name) :: names(n)
    real(dp) :: vals(nz,n)
    integer, intent(out) :: ierr

    type (star_info), pointer :: s

    ierr = 0

    call star_ptr(id, s, ierr)
    if (ierr /= 0) return

    ! >>> Insert code to set history column names/values below

    names(1) = 'xi_r_f'
    names(2) = 'xi_r_1o'

    names(3) = 'dW_dx_f'
    names(4) = 'dW_dx_1o'

    names(5) = 'dW_dlnT_f'
    names(6) = 'dW_dlnT_1o'

    if (s%x_logical_ctrl(1)) then

       if (.NOT. gyre_has_run) call run_gyre(id, ierr)

       vals(:,1) = xi_r_f
       vals(:,2) = xi_r_1o

       vals(:,3) = dW_dx_f
       vals(:,4) = dW_dx_1o

       vals(:,5) = dW_dlnT_f
       vals(:,6) = dW_dlnT_1o

    else

       vals(:,1) = 0.
       vals(:,2) = 0.

       vals(:,3) = 0.
       vals(:,4) = 0.

       vals(:,5) = 0.
       vals(:,6) = 0.

    endif

  end subroutine data_for_extra_profile_columns

  ! >>> Insert additional subroutines/functions below

  subroutine run_gyre (id, ierr)

    integer, intent(in)  :: id
    integer, intent(out) :: ierr

    real(dp), allocatable :: global_data(:)
    real(dp), allocatable :: point_data(:,:)
    integer               :: ipar(0)
    real(dp)              :: rpar(0)

    ! Pass model data to GYRE

    call star_get_pulse_data(id, 'GYRE', .FALSE., .TRUE., .FALSE., &
         global_data, point_data, ierr)
    if (ierr /= 0) then
       print *,'Failed when calling star_get_pulse_data'
       return
    end if

    call gyre_set_model(global_data, point_data, 101)

    ! Run GYRE to get modes

    call gyre_get_modes(0, process_mode, ipar, rpar)

    ! Set the gyre_has_run flag

    gyre_has_run = .true.

  contains

    subroutine process_mode (md, ipar, rpar, retcode)

      type(mode_t), intent(in) :: md
      integer, intent(inout)   :: ipar(:)
      real(dp), intent(inout)  :: rpar(:)
      integer, intent(out)     :: retcode

      integer :: k
      type (star_info), pointer :: s

      ierr = 0

      call star_ptr(id, s, ierr)
      if (ierr /= 0) return

      ! Print out radial order, frequency and growth rate

      print *, 'Found mode: radial order, frequency, growth rate = ', &
           md%n_pg, REAL(md%freq('HZ')), 2.*PI*AIMAG(md%freq('HZ'))

      ! If this is the F mode, store the period and growth rate

      if (md%n_pg == 1) then
         period_f = 1. / (3600.*REAL(md%freq('HZ')))
         growth_f = 2.*PI*AIMAG(md%freq('HZ')) * secyer
      end if

      ! If this is the F mode, store the displacement wavefunction and
      ! differential work functions

      if (md%n_pg == 1) then

         if (allocated(xi_r_f)) deallocate(xi_r_f)
         allocate(xi_r_f(md%n_k))

         if (allocated(dW_dx_f)) deallocate(dW_dx_f)
         allocate(dW_dx_f(md%n_k))

         if (allocated(dW_dlnT_f)) deallocate(dW_dlnT_f)
         allocate(dW_dlnT_f(md%n_k))

         do k = 1, md%n_k
            xi_r_f(k) = md%xi_r(k)
            dW_dx_f(k) = md%dW_dx(k)
         end do

         xi_r_f = xi_r_f(md%n_k:1:-1)
         dW_dx_f = dW_dx_f(md%n_k:1:-1)
  
         dW_dlnT_f = dW_dx_f*s%scale_height(1:s%nz)/(s%photosphere_r*s%gradT(1:s%nz))         

      end if

      ! If this is the 1-O mode, store the period and growth rate

      if (md%n_pg == 2) then
         period_1o = 1. / (3600.*REAL(md%freq('HZ')))
         growth_1o = 2.*PI*AIMAG(md%freq('HZ')) * secyer
      end if

      ! If this is the 1-O mode, store the displacement wavefunction

      if (md%n_pg == 2) then

         if (allocated(xi_r_1o)) deallocate(xi_r_1o)
         allocate(xi_r_1o(md%n_k))

         if (allocated(dW_dx_1o)) deallocate(dW_dx_1o)
         allocate(dW_dx_1o(md%n_k))

         if (allocated(dW_dlnT_1o)) deallocate(dW_dlnT_1o)
         allocate(dW_dlnT_1o(md%n_k))

         do k = 1, md%n_k
            xi_r_1o(k) = md%xi_r(k)
            dW_dx_1o(k) = md%dW_dx(k)
         end do

         xi_r_1o = xi_r_1o(md%n_k:1:-1)
         dW_dx_1o = dW_dx_1o(md%n_k:1:-1)

         dW_dlnT_1o = dW_dx_1o*s%scale_height(1:s%nz)/(s%photosphere_r*s%gradT(1:s%nz))         

      end if

      ! Set return code

      retcode = 0

    end subroutine process_mode

  end subroutine run_gyre

end module run_star_extras
