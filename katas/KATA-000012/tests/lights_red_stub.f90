! Deliberately wrong but type-correct RED fixture; never used for GREEN.
module christmas_lights
  use iso_fortran_env, only: int64
  implicit none
  private
  public :: light_grid
  type :: light_grid
    logical, allocatable :: on(:,:)
    integer(int64), allocatable :: brightness(:,:)
  contains
    procedure :: init
    procedure :: apply
    procedure :: totals
  end type
contains
  subroutine init(self,n)
    class(light_grid), intent(inout) :: self
    integer, intent(in) :: n
    if (allocated(self%on)) deallocate(self%on)
    if (allocated(self%brightness)) deallocate(self%brightness)
    allocate(self%on(n,n),self%brightness(n,n))
    self%on=.false.
    self%brightness=0_int64
  end subroutine
  subroutine apply(self,op,x1,y1,x2,y2,ok)
    class(light_grid), intent(inout) :: self
    integer, intent(in) :: op,x1,y1,x2,y2
    logical, intent(out) :: ok
    ok = .true.
    ! The stub intentionally never updates the board.
  end subroutine
  subroutine totals(self,lit,bright)
    class(light_grid), intent(in) :: self
    integer(int64), intent(out) :: lit,bright
    lit=count(self%on,kind=int64)
    bright=sum(self%brightness)
  end subroutine
end module
