program test_lights
  use iso_fortran_env, only: int64
  use christmas_lights
  implicit none
  type(light_grid) :: g
  integer(int64) :: lit, bright
  logical :: ok
  integer :: assertions
  assertions = 0
  call g%init(3)
  call check(0_int64,0_int64)
  call g%apply(1,0,0,2,2,ok)
  call yes(ok)
  call check(9_int64,9_int64)
  call g%apply(3,0,0,0,2,ok)
  call yes(ok)
  call check(6_int64,15_int64)
  call g%apply(2,1,1,2,2,ok)
  call yes(ok)
  call check(2_int64,11_int64)
  call g%apply(2,1,1,2,2,ok)
  call yes(ok)
  call check(2_int64,11_int64)
  call g%apply(0,0,0,2,2,ok)
  call no(ok)
  call check(2_int64,11_int64)
  call g%apply(3,0,0,3,2,ok)
  call no(ok)
  call check(2_int64,11_int64)
  call g%apply(1,2,2,1,1,ok)
  call no(ok)
  call check(2_int64,11_int64)
  call g%init(1)
  call check(0_int64,0_int64)
  call g%apply(2,0,0,0,0,ok)
  call yes(ok)
  call check(0_int64,0_int64)
  call g%apply(3,0,0,0,0,ok)
  call yes(ok)
  call check(1_int64,2_int64)
  call g%apply(3,0,0,0,0,ok)
  call yes(ok)
  call check(0_int64,4_int64)
  print '(A,I0,A)', 'GREEN PASS ', assertions, ' native assertions'
contains
  subroutine check(a,b)
    integer(int64), intent(in) :: a,b
    call g%totals(lit,bright)
    assertions = assertions + 1
    if (lit /= a .or. bright /= b) then
      print *, 'FAIL totals expected ', a,b, ' actual ', lit,bright
      stop 1
    end if
  end subroutine
  subroutine yes(value)
    logical, intent(in) :: value
    assertions = assertions + 1
    if (.not. value) error stop 'expected accepted command'
  end subroutine
  subroutine no(value)
    logical, intent(in) :: value
    assertions = assertions + 1
    if (value) error stop 'expected atomic rejection'
  end subroutine
end program
