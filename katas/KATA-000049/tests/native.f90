program native_tests
  use flower_field, only: annotate
  implicit none
  character(len=1), allocatable :: board(:,:), actual(:,:), transformed(:,:), expected(:,:)
  integer :: pattern, row, col, bit, cases, checks
  checks = 0
  cases = 0
  allocate(board(0,0))
  actual = annotate(board)
  call assert(size(actual,1)==0 .and. size(actual,2)==0,'empty board')
  deallocate(board)
  allocate(board(1,1))
  board(1,1)='.'
  actual=annotate(board)
  call assert(actual(1,1)=='.','empty cell')
  board(1,1)='*'
  actual=annotate(board)
  call assert(actual(1,1)=='*','flower preserved')
  deallocate(board)
  allocate(board(3,3))
  board='.'
  board(2,2)='*'
  expected=board
  expected='1'
  expected(2,2)='*'
  actual=annotate(board)
  call assert(all(actual==expected),'central flower eight neighbors')
  board='*'
  actual=annotate(board)
  call assert(all(actual=='*'),'full flowers')
  deallocate(board)
  allocate(board(4,5))
  board='.'
  board(1,2)='*'; board(1,4)='*'; board(2,3)='*'; board(3,3)='*'
  if (allocated(expected)) deallocate(expected)
  allocate(expected(4,5))
  expected='.'
  call setrow(expected,1,'1*3*1')
  call setrow(expected,2,'13*31')
  call setrow(expected,3,'.2*2.')
  call setrow(expected,4,'.111.')
  actual=annotate(board)
  call assert(all(actual==expected),'independent 4x5 hand calculation')
  deallocate(board)
  allocate(board(3,3))
  do pattern=0,511
    board='.'
    do row=1,3
      do col=1,3
        bit=(row-1)*3+col-1
        if (btest(pattern,bit)) board(row,col)='*'
      end do
    end do
    actual=annotate(board)
    call assert(all((board/='*').or.(actual=='*')),'flowers unchanged')
    call assert(all((board=='*').or.(actual=='.').or.&
      ((iachar(actual)>=iachar('1')).and.(iachar(actual)<=iachar('8')))),&
      'digits bounded')
    transformed=annotate(transpose(board))
    call assert(all(transformed==transpose(actual)),'transpose equivariance')
    transformed=annotate(board(3:1:-1,:))
    call assert(all(transformed==actual(3:1:-1,:)),'vertical reflection')
    cases=cases+1
  end do
  write(*,'(A,I0,A,I0)') 'PASS native Fortran cases=',cases,' assertions=',checks
contains
  subroutine assert(ok,what)
    logical, intent(in) :: ok
    character(len=*), intent(in) :: what
    if (.not.ok) then
      write(*,'(A,A)') 'FAIL native: ',what
      stop 1
    end if
    checks=checks+1
  end subroutine
  subroutine setrow(a,r,s)
    character(len=1), intent(inout) :: a(:,:)
    integer, intent(in) :: r
    character(len=*), intent(in) :: s
    integer :: j
    do j=1,len(s)
      a(r,j)=s(j:j)
    end do
  end subroutine
end program native_tests
