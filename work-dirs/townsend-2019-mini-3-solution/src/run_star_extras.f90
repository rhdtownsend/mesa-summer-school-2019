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

  ! Frequencies of fundamental and first overtone

  real(dp), save :: period_f
  real(dp), save :: period_1o

  ! Radial displacements wavefunctions of fundamental and first overtone

  real(dp), allocatable, save :: xi_r_f(:)
  real(dp), allocatable, save :: xi_r_1o(:)

  ! Flag to check if GYRE has run

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

    how_many_extra_history_columns = 2

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

    if (s%x_logical_ctrl(1)) then

       vals(1) = period_f
       vals(2) = period_1o

    else

       vals(1) = 0.
       vals(2) = 0.

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

    how_many_extra_profile_columns = 2

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
    integer :: k

    ierr = 0

    call star_ptr(id, s, ierr)
    if (ierr /= 0) return

    ! >>> Insert code to set history column names/values below

    names(1) = 'xi_r_f'
    names(2) = 'xi_r_1o'

    if (s%x_logical_ctrl(1)) then

       if (.NOT. gyre_has_run) call run_gyre(id, ierr)

       vals(:,1) = xi_r_f
       vals(:,2) = xi_r_1o

    else

       vals(:,1) = 0.
       vals(:,2) = 0.

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

    call star_get_pulse_data(id, 'GYRE', .FALSE., .TRUE., .FALSE., global_data, point_data, ierr)
    if (ierr /= 0) then
       print *,'Failed when calling star_get_pulse_data'
       return
    end if

    call gyre_set_model(global_data, point_data, 101)

    ! Run GYRE to get modes

    call gyre_get_modes(0, process_mode, ipar, rpar)

    ! Indicate that GYRE has run

    gyre_has_run = .true.

  contains

    subroutine process_mode (md, ipar, rpar, retcode)

      type(mode_t), intent(in) :: md
      integer, intent(inout)   :: ipar(:)
      real(dp), intent(inout)  :: rpar(:)
      integer, intent(out)     :: retcode

      integer :: k

      ! Print out radial order and eigenfrequency

      print *, 'Found mode: radial order, frequency = ', md%n_pg, REAL(md%freq('HZ'))

      ! If this is the fundamental mode, store the period

      if (md%n_pg == 1) then
         period_f = 1./REAL(md%freq('HZ'))
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

      ! If this is the first overtone mode, store the period
      
      if (md%n_pg == 2) then
         period_1o = 1./REAL(md%freq('HZ'))
      end if

      ! If this is the fundamental mode, store the radial displacement
      ! wavefunction

      if (md%n_pg == 2) then

         if (allocated(xi_r_1o)) deallocate(xi_r_1o)
         allocate(xi_r_1o(md%n_k))

         do k = 1, md%n_k
            xi_r_1o(k) = md%xi_r(k)
         end do

         xi_r_1o = xi_r_1o(md%n_k:1:-1)

      endif

      ! Set return code

      retcode = 0

    end subroutine process_mode

  end subroutine run_gyre

end module run_star_extras
