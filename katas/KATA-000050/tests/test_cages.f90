! SPDX-License-Identifier: MIT
program test_cages
 use killer_cages
 implicit none
 integer::results(512),count
 logical::valid
 call check(3,7,0,[124])
 call check(2,10,0,[19,28,37,46])
 call check(2,10,9,[28,37])
 call check(1,1,0,[1])
 call check(1,9,0,[9])
 call check(9,45,0,[123456789])
 call check(9,45,1,[integer::])
 call check(2,3,0,[12])
 call check(2,17,0,[89])
 call check(2,2,0,[integer::])
 call check(3,8,0,[125,134])
 call check(3,8,2,[134])
 call combinations(0,10,0,results,count,valid)
 if(valid)error stop 'zero digits accepted'
 call combinations(2,10,512,results,count,valid)
 if(valid)error stop 'bad mask accepted'
 print '(A)','PASS: 12 fixed combinations and 2 invalid-input cases'
contains
 subroutine check(n,s,excluded,wanted)
  integer,intent(in)::n,s,excluded,wanted(:)
  integer::got(512),amount
  logical::ok
  call combinations(n,s,excluded,got,amount,ok)
  if(.not.ok)error stop 'valid scenario rejected'
  if(amount/=size(wanted))error stop 'FAIL behavioral assertion: unexpected count'
  if(any(got(1:amount)/=wanted))error stop 'FAIL behavioral assertion: unexpected combinations'
 end subroutine
end program
