module flower_field
  implicit none
  private
  public :: annotate
contains
  pure function annotate(board) result(marked)
    character(len=1), intent(in) :: board(:,:)
    character(len=1), allocatable :: marked(:,:)
    integer, allocatable :: flowers(:,:)
    integer :: rows, cols, row, col, adjacent

    rows = size(board, 1)
    cols = size(board, 2)
    allocate(marked(rows, cols), flowers(0:rows+1, 0:cols+1))
    flowers = 0
    do col = 1, cols
      do row = 1, rows
        if (board(row, col) == '*') flowers(row, col) = 1
      end do
    end do
    do col = 1, cols
      do row = 1, rows
        if (board(row, col) == '*') then
          marked(row, col) = '*'
        else
          adjacent = sum(flowers(row-1:row+1, col-1:col+1))
          if (adjacent == 0) then
            marked(row, col) = '.'
          else
            marked(row, col) = achar(iachar('0') + adjacent)
          end if
        end if
      end do
    end do
  end function annotate
end module flower_field
