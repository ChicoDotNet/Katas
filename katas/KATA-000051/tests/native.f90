program native_tests
  use, intrinsic :: iso_fortran_env, only: int64
  use spiral_matrix, only: make_spiral
  implicit none
  integer(int64), allocatable :: a(:,:)
  integer :: n, i, j, tests
  integer(int64) :: v
  tests = 0
  call make_spiral(0,a)
  call check(size(a)==0, 'empty size')
  call make_spiral(1,a)
  call check(size(a)==1 .and. a(1,1)==1_int64,'one cell')
  call make_spiral(2,a)
  call check(all(a(1,:)==[1_int64,2_int64]),'2 top')
  call check(all(a(2,:)==[4_int64,3_int64]),'2 bottom')
  call make_spiral(3,a)
  call check(all(a(1,:)==[1_int64,2_int64,3_int64]),'3 top')
  call check(all(a(2,:)==[8_int64,9_int64,4_int64]),'3 middle')
  call check(all(a(3,:)==[7_int64,6_int64,5_int64]),'3 bottom')
  call make_spiral(4,a)
  call check(all(a(1,:)==[1_int64,2_int64,3_int64,4_int64]),'4 top')
  call check(all(a(2,:)==[12_int64,13_int64,14_int64,5_int64]),'4 second')
  call check(all(a(3,:)==[11_int64,16_int64,15_int64,6_int64]),'4 third')
  call check(all(a(4,:)==[10_int64,9_int64,8_int64,7_int64]),'4 bottom')
  do n = 5, 60
    call make_spiral(n,a)
    call check(a(1,1)==1_int64,'origin')
    call check(a(n,1)==int(3*n-2,int64),'bottom left')
    call check(a(n,n)==int(2*n-1,int64),'bottom right')
    call check(a(1,n)==int(n,int64),'top right')
    call check(count(a==0_int64)==0,'no zero cells')
    call check(maxval(a)==int(n,int64)**2,'max n squared')
    do i=1,n
      do j=1,n
        v=a(i,j)
        call check(count(a==v)==1,'unique number')
      end do
    end do
  end do
  print '(A,I0)', 'PASS native Fortran assertions: ',tests
contains
  subroutine check(ok,what)
    logical,intent(in)::ok
    character(len=*),intent(in)::what
    tests=tests+1
    if (.not.ok) then
      print '(A,A)', 'FAIL native: ',what
      stop 1
    end if
  end subroutine
end program native_tests
