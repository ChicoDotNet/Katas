! Original MIT implementation: bounded binary lights and saturating brightness.
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
  subroutine init(self, n)
    class(light_grid), intent(inout) :: self
    integer, intent(in) :: n
    if (n < 1 .or. n > 1000) error stop 'invalid dimension'
    if (allocated(self%on)) deallocate(self%on)
    if (allocated(self%brightness)) deallocate(self%brightness)
    allocate(self%on(n,n), self%brightness(n,n))
    self%on = .false.
    self%brightness = 0_int64
  end subroutine

  subroutine apply(self, op, x1, y1, x2, y2, ok)
    class(light_grid), intent(inout) :: self
    integer, intent(in) :: op, x1, y1, x2, y2
    logical, intent(out) :: ok
    integer :: i, j, n
    ok = .false.
    if (.not. allocated(self%on)) return
    n = size(self%on, 1)
    if (op < 1 .or. op > 3) return
    if (x1 < 0 .or. y1 < 0 .or. x2 < x1 .or. y2 < y1) return
    if (x2 >= n .or. y2 >= n) return
    ! Validate the entire rectangle before any mutation (atomic rejection).
    do j = y1 + 1, y2 + 1
      do i = x1 + 1, x2 + 1
        select case(op)
        case (1) ! on
          self%on(i,j) = .true.
          self%brightness(i,j) = self%brightness(i,j) + 1_int64
        case (2) ! off
          self%on(i,j) = .false.
          self%brightness(i,j) = max(0_int64, self%brightness(i,j) - 1_int64)
        case (3) ! toggle
          self%on(i,j) = .not. self%on(i,j)
          self%brightness(i,j) = self%brightness(i,j) + 2_int64
        end select
      end do
    end do
    ok = .true.
  end subroutine

  subroutine totals(self, lit, bright)
    class(light_grid), intent(in) :: self
    integer(int64), intent(out) :: lit, bright
    lit = count(self%on, kind=int64)
    bright = sum(self%brightness)
  end subroutine
end module
