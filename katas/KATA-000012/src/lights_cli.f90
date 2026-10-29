program lights_cli
  use iso_fortran_env, only: int64, input_unit, iostat_end
  use christmas_lights
  implicit none
  type(light_grid) :: board
  integer :: n, m, k, op, x1, y1, x2, y2, ios
  integer(int64) :: lit, bright
  character(len=1024) :: line
  character(len=1) :: extra
  logical :: ok

  ! Record-oriented parsing prevents silently ignoring undeclared commands.
  read(input_unit,'(A)',iostat=ios) line
  if (ios /= 0) error stop 'invalid header'
  read(line,*,iostat=ios) n, m
  if (ios /= 0) error stop 'invalid header'
  read(line,*,iostat=ios) n, m, extra
  if (ios == 0) error stop 'extra header field'
  if (ios /= iostat_end) error stop 'invalid header suffix'
  if (n < 1 .or. n > 1000 .or. m < 0 .or. m > 10000) error stop 'invalid dimensions/count'
  call board%init(n)
  do k = 1, m
    read(input_unit,'(A)',iostat=ios) line
    if (ios /= 0) error stop 'invalid command input'
    read(line,*,iostat=ios) op, x1, y1, x2, y2
    if (ios /= 0) error stop 'invalid command input'
    read(line,*,iostat=ios) op, x1, y1, x2, y2, extra
    if (ios == 0) error stop 'extra command field'
    if (ios /= iostat_end) error stop 'invalid command suffix'
    call board%apply(op,x1,y1,x2,y2,ok)
    if (.not. ok) error stop 'invalid command'
  end do
  do
    read(input_unit,'(A)',iostat=ios) line
    if (ios == iostat_end) exit
    if (ios /= 0) error stop 'invalid trailing input'
    if (len_trim(adjustl(line)) /= 0) error stop 'unexpected command after declared count'
  end do
  call board%totals(lit,bright)
  print '(I0,1X,I0)', lit, bright
end program
