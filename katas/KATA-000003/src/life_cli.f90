! SPDX-License-Identifier: MIT
! Text protocol: rows cols followed by rows strings of 0/1; outputs next grid.
program life_cli
  use life_core, only: next_generation
  implicit none
  integer :: rows, cols, i, j, ios
  logical, allocatable :: grid(:,:), evolved(:,:)
  character(len=:), allocatable :: line
  read(*,*,iostat=ios) rows, cols
  if (ios /= 0 .or. rows < 0 .or. cols < 0 .or. rows > 256 .or. cols > 256) error stop 'invalid grid dimensions'
  allocate(grid(rows,cols))
  allocate(character(len=cols) :: line)
  do i = 1, rows
    read(*,'(A)',iostat=ios) line
    if (ios /= 0) error stop 'incomplete board'
    do j = 1, cols
      select case (line(j:j))
      case ('0')
        grid(i,j) = .false.
      case ('1')
        grid(i,j) = .true.
      case default
        error stop 'only 0 or 1 allowed'
      end select
    end do
  end do
  evolved = next_generation(grid)
  do i = 1, rows
    do j = 1, cols
      if (evolved(i,j)) then
        line(j:j) = '1'
      else
        line(j:j) = '0'
      end if
    end do
    print '(A)',line
  end do
end program life_cli
