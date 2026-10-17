program test_life
  use life_core, only: next_generation
  implicit none
  logical :: board(5,5), wanted(5,5)

  board = .false.
  call expect(board, board, 'empty grid')

  board = .false.
  board(3,3) = .true.
  wanted = .false.
  call expect(board, wanted, 'lonely cell dies')

  board = .false.
  board(2:3, 2:3) = .true.
  call expect(board, board, 'block stable')

  board = .false.
  board(3,2:4) = .true.
  wanted = .false.
  wanted(2:4,3) = .true.
  call expect(board, wanted, 'blinker horizontal to vertical')
  call expect(wanted, board, 'blinker vertical to horizontal')

  board = .false.
  board(1,1) = .true.
  board(1,2) = .true.
  board(2,1) = .true.
  wanted = .false.
  wanted(1,1) = .true.
  wanted(1,2) = .true.
  wanted(2,1) = .true.
  wanted(2,2) = .true.
  call expect(board, wanted, 'bounded corner birth')

  print *, 'PASS: 6 independent fixed-pattern assertions'
contains
  subroutine expect(input, expected, title)
    logical, intent(in) :: input(:,:), expected(:,:)
    character(len=*), intent(in) :: title
    logical, allocatable :: actual(:,:)
    actual = next_generation(input)
    if (any(shape(actual) /= shape(expected))) error stop 'shape mismatch'
    if (any(actual .neqv. expected)) then
      print *, 'FAIL: ', title
      error stop 1
    end if
  end subroutine expect
end program test_life
