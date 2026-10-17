! SPDX-License-Identifier: MIT
program knapsack_cli
  use iso_fortran_env, only: int64
  use ninja_knapsack, only: maximize
  implicit none
  integer :: cases, case_num, cap, n, i, err
  integer, allocatable :: weights(:)
  integer(int64), allocatable :: values(:)
  read(*, *, iostat=err) cases
  if (err /= 0 .or. cases < 0 .or. cases > 10000) error stop 'invalid case count'
  do case_num = 1, cases
    read(*, *, iostat=err) cap, n
    if (err /= 0 .or. n < 0 .or. n > 256) error stop 'invalid item count'
    allocate(weights(n), values(n))
    do i=1, n
      read(*, *, iostat=err) weights(i), values(i)
      if (err /= 0) error stop 'invalid item'
    end do
    print '(I0)', maximize(cap, weights, values)
    deallocate(weights, values)
  end do
end program knapsack_cli
