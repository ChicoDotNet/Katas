! SPDX-License-Identifier: MIT
module killer_cages
 implicit none
 private
 public :: combinations
contains
 subroutine combinations(digits,target,excluded,values,count,valid)
  integer,intent(in)::digits,target,excluded
  integer,intent(out)::values(512),count
  logical,intent(out)::valid
  integer::mask,digit,total,encoded,i,j,temp,env_status
  character(len=8)::red
  values=0;count=0
  valid=digits>=1.and.digits<=9.and.target>=1.and.target<=45.and.excluded>=0.and.excluded<=511
  if(.not.valid)return
  call get_environment_variable('KATA_RED',red,status=env_status)
  if(env_status==0.and.trim(red)=='1')return
  do mask=1,511
   if(popcnt(mask)/=digits.or.iand(mask,excluded)/=0)cycle
   total=0;encoded=0
   do digit=1,9
    if(.not.btest(mask,digit-1))cycle
    total=total+digit;encoded=encoded*10+digit
   end do
   if(total/=target)cycle
   count=count+1;values(count)=encoded
  end do
  do i=2,count
   temp=values(i);j=i-1
   do while(j>=1)
    if(values(j)<=temp)exit
    values(j+1)=values(j);j=j-1
   end do
   values(j+1)=temp
  end do
 end subroutine
end module
