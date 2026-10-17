! SPDX-License-Identifier: MIT
program killer_cli
 use killer_cages
 implicit none
 character(len=4096)::line
 integer::ios,digits,target,excluded,results(512),found,i,p1,p2
 logical::valid
 do
  read(*,'(A)',iostat=ios)line
  if(ios/=0)exit
  p1=index(line,',')
  if(p1==0)then
   print '(A)','ERROR'
   cycle
  end if
  p2=index(line(p1+1:),',')+p1
  if(p2<=p1)then
   print '(A)','ERROR'
   cycle
  end if
  read(line(:p1-1),*,iostat=ios)digits
  if(ios/=0)then
   print '(A)','ERROR'
   cycle
  end if
  read(line(p1+1:p2-1),*,iostat=ios)target
  if(ios/=0)then
   print '(A)','ERROR'
   cycle
  end if
  read(line(p2+1:),*,iostat=ios)excluded
  if(ios/=0)then
   print '(A)','ERROR'
   cycle
  end if
  call combinations(digits,target,excluded,results,found,valid)
  if(.not.valid)then
   print '(A)','ERROR'
   cycle
  end if
  write(*,'(I0,A)',advance='no')found,'|'
  do i=1,found
   if(i>1)write(*,'(A)',advance='no')','
   write(*,'(I0)',advance='no')results(i)
  end do
  print '(A)',''
 end do
end program
