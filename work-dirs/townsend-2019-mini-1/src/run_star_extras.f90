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

  implicit none

  ! >>> Insert module variables below

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

    how_many_extra_history_columns = 0

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

    how_many_extra_profile_columns = 0

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

  end subroutine data_for_extra_profile_columns

  ! >>> Insert additional subroutines/functions below

end module run_star_extras
