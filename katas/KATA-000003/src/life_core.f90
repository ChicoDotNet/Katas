! SPDX-License-Identifier: MIT
module life_core
  implicit none
  private
  public :: next_generation
contains
  pure function next_generation(board) result(next)
    ! Simultaneous generation, finite boundary (cells outside are dead).
    logical, intent(in) :: board(:,:)
    logical, allocatable :: next(:,:)
    integer :: x, y, dx, dy, nx, ny, neighbors

    allocate(next(size(board,1), size(board,2)))
    next = .false.
    do y = 1, size(board,2)
      do x = 1, size(board,1)
        neighbors = 0
        do dy = -1, 1
          do dx = -1, 1
            if (dx == 0 .and. dy == 0) cycle
            nx = x + dx
            ny = y + dy
            if (nx < 1 .or. nx > size(board,1)) cycle
            if (ny < 1 .or. ny > size(board,2)) cycle
            if (board(nx,ny)) neighbors = neighbors + 1
          end do
        end do
        next(x,y) = (neighbors == 3) .or. (board(x,y) .and. neighbors == 2)
      end do
    end do
  end function next_generation
end module life_core
