! SPDX-License-Identifier: MIT
module ninja_knapsack
  use iso_fortran_env, only: int64
  implicit none
  private
  public :: maximize
contains
  function maximize(capacity, weights, values) result(best)
    integer, intent(in) :: capacity
    integer, intent(in) :: weights(:)
    integer(int64), intent(in) :: values(:)
    integer(int64) :: best, dp(0:max(0,capacity))
    integer :: i, c, w
    if (capacity < 0 .or. capacity > 10000) error stop 'invalid capacity'
    if (size(weights) /= size(values)) error stop 'item dimensions mismatch'
    if (size(weights) > 256) error stop 'too many items'
    if (any(weights < 0) .or. any(values < 0_int64)) error stop 'negative weight or value'
    if (any(values > 1000000000_int64)) error stop 'item value too large'
    dp = 0_int64
    do i = 1, size(weights)
      w = weights(i)
      if (w > capacity) cycle
      ! Descending capacity ensures each item is used once, including zero-weight items.
      do c = capacity, w, -1
        dp(c) = max(dp(c), dp(c-w) + values(i))
      end do
    end do
    best = dp(capacity)
  end function maximize
end module ninja_knapsack
