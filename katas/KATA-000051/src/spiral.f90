! Original MIT implementation. No upstream starter or fixtures copied.
module spiral_matrix
  use, intrinsic :: iso_fortran_env, only: int64
  implicit none
  private
  public :: make_spiral
contains
  subroutine make_spiral(n, grid)
    integer, intent(in) :: n
    integer(int64), allocatable, intent(out) :: grid(:,:)
    integer :: top, bottom, left, right, row, col
    integer(int64) :: value
    if (n < 0 .or. n > 512) error stop 'size out of supported range'
    allocate(grid(n,n))
    grid = 0_int64
    top = 1; bottom = n; left = 1; right = n
    value = 1_int64
    do while (top <= bottom .and. left <= right)
      do col = left, right
        grid(top,col) = value; value = value + 1_int64
      end do
      top = top + 1
      do row = top, bottom
        grid(row,right) = value; value = value + 1_int64
      end do
      right = right - 1
      if (top <= bottom) then
        do col = right, left, -1
          grid(bottom,col) = value; value = value + 1_int64
        end do
        bottom = bottom - 1
      end if
      if (left <= right) then
        do row = bottom, top, -1
          grid(row,left) = value; value = value + 1_int64
        end do
        left = left + 1
      end if
    end do
  end subroutine make_spiral
end module spiral_matrix
