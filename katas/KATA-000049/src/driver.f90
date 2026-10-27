program flower_field_driver
  use flower_field, only: annotate
  implicit none
  character(len=8192) :: line
  character(len=1), allocatable :: board(:,:), result(:,:)
  character(len=:), allocatable :: output_line
  integer :: rows, cols, row, col, ios

  read(*,'(A)',iostat=ios) line
  if (ios /= 0) stop 2
  read(line,*,iostat=ios) rows, cols
  if (ios /= 0) stop 2
  if (rows < 0 .or. cols < 0 .or. rows > 512 .or. cols > 512) stop 2
  ! Transport uses '.' for empty cells; input lines are unambiguous even at edges.
  allocate(board(rows, cols))
  do row = 1, rows
    read(*,'(A)',iostat=ios) line
    if (ios /= 0) stop 2
    if (len_trim(line) /= cols) stop 2
    do col = 1, cols
      if (line(col:col) /= '.' .and. line(col:col) /= '*') stop 2
      board(row, col) = line(col:col)
    end do
  end do
  result = annotate(board)
  allocate(character(len=cols) :: output_line)
  do row = 1, rows
    do col = 1, cols
      output_line(col:col) = result(row,col)
    end do
    write(*,'(A)') output_line
  end do
end program flower_field_driver
