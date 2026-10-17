! SPDX-License-Identifier: MIT
! Deliberately incorrect baseline used to demonstrate behavioral RED.
module life_core
  implicit none
contains
  pure function next_generation(board) result(next)
    logical, intent(in) :: board(:,:)
    logical, allocatable :: next(:,:)
    allocate(next(size(board,1), size(board,2)))
    next = .false.
  end function next_generation
end module life_core
