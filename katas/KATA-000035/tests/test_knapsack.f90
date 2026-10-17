! SPDX-License-Identifier: MIT
program test_knapsack
  use iso_fortran_env, only: int64
  use ninja_knapsack, only: maximize
  implicit none
  call same(90_int64, maximize(10, [5,4,6,4], [10_int64,40_int64,30_int64,50_int64]), 'source case')
  call same(0_int64, maximize(0, [2,3], [4_int64,5_int64]), 'zero capacity')
  call same(8_int64, maximize(0, [0,2], [8_int64,100_int64]), 'zero-weight item used once')
  call same(35_int64, maximize(4, [2,2,2], [10_int64,20_int64,15_int64]), '0-1 one use')
  call same(9_int64, maximize(10, [9,10], [9_int64,8_int64]), 'different weight')
  call same(0_int64, maximize(10, [integer::], [integer(int64)::]), 'empty items')
  call same(6_int64, maximize(100, [1,2,3], [1_int64,2_int64,3_int64]), 'oversized capacity')
  call same(7_int64, maximize(5, [0,0,9], [3_int64,4_int64,20_int64]), 'two zero weight')
  print '(A)', 'PASS: 8 Fortran 0-1 knapsack acceptance scenarios'
contains
  subroutine same(expected, actual, name)
    integer(int64), intent(in) :: expected, actual
    character(*), intent(in) :: name
    if (expected /= actual) then
      print '(A,1X,A,1X,I0,1X,I0)', 'FAIL behavioral:', name, expected, actual
      stop 1
    end if
  end subroutine same
end program test_knapsack
