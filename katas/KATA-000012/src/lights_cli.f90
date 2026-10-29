program lights_cli
  use iso_fortran_env, only: int64
  use christmas_lights
  implicit none
  type(light_grid) :: board
  integer :: n, m, k, op, x1, y1, x2, y2, ios
  integer(int64) :: lit, bright
  logical :: ok
  read(*,*,iostat=ios) n, m
  if (ios /= 0) error stop 'invalid header'
  if (n < 1 .or. n > 1000 .or. m < 0 .or. m > 10000) error stop 'invalid dimensions/count'
  call board%init(n)
  do k = 1, m
    read(*,*,iostat=ios) op, x1, y1, x2, y2
    if (ios /= 0) error stop 'invalid command input'
    call board%apply(op,x1,y1,x2,y2,ok)
    if (.not. ok) error stop 'invalid command'
  end do
  call board%totals(lit,bright)
  print '(I0,1X,I0)', lit, bright
end program
