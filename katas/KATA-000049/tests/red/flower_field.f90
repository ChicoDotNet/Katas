module flower_field
  implicit none
  private
  public :: annotate
contains
  pure function annotate(board) result(marked)
    character(len=1), intent(in) :: board(:,:)
    character(len=1), allocatable :: marked(:,:)
    allocate(marked(size(board,1),size(board,2)))
    marked = board
  end function annotate
end module flower_field
