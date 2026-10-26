! Compilable, intentionally behaviorally incorrect RED baseline.
module spiral_matrix
  use, intrinsic :: iso_fortran_env, only: int64
  implicit none
contains
  subroutine make_spiral(n, grid)
    integer, intent(in) :: n
    integer(int64), allocatable, intent(out) :: grid(:,:)
    allocate(grid(n,n))
    grid = 0_int64
  end subroutine
end module
