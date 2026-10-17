! SPDX-License-Identifier: MIT
module ninja_knapsack
 use iso_fortran_env, only: int64
 implicit none
contains
 function maximize(capacity, weights, values) result(best)
 integer, intent(in) :: capacity
 integer, intent(in) :: weights(:)
 integer(int64), intent(in) :: values(:)
 integer(int64) :: best
 if (capacity < 0 .or. size(weights) /= size(values)) error stop "invalid argument"
 best = 0_int64
 end function maximize
end module ninja_knapsack
