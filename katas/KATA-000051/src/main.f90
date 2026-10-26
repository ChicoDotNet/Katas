program spiral_cli
  use, intrinsic :: iso_fortran_env, only: int64, error_unit
  use spiral_matrix, only: make_spiral
  implicit none
  integer :: n, stat, i, j
  integer(int64), allocatable :: grid(:,:)
  character(len=64) :: arg
  if (command_argument_count() /= 1) then
    write(error_unit,'(A)') 'usage: spiral N (0 <= N <= 512)'
    stop 2
  end if
  call get_command_argument(1, arg, status=stat)
  if (stat /= 0) stop 2
  read(arg,*,iostat=stat) n
  if (stat /= 0) stop 2
  if (n < 0 .or. n > 512) stop 2
  call make_spiral(n, grid)
  do i = 1, n
    do j = 1, n
      if (j > 1) write(*,'(A)',advance='no') ' '
      write(*,'(I0)',advance='no') grid(i,j)
    end do
    write(*,'(A)') ''
  end do
end program spiral_cli
