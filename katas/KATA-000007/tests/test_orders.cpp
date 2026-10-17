// SPDX-License-Identifier: MIT
#include "../src/orders.hpp"
#include <cstdlib>
#include <iostream>
#include <string>
using namespace ninja_orders;
void ensure(bool cond,const char* label){if(!cond){std::cerr<<"FAIL behavioral invariant: "<<label<<'\n';std::exit(1);}}
void compare(Snapshot a,Snapshot b){ensure(a.state==b.state&&a.subtotal==b.subtotal&&a.tax==b.tax&&a.total==b.total&&a.accepted==b.accepted&&a.refused==b.refused,"legacy-vs-domain state parity");}
int main(){
 Order empty{1600};ensure(!empty.apply('P'),"empty cannot approve");ensure(empty.snapshot().state==State::draft,"failed command does not advance state");
 Order order{1600};LegacyOrder legacy{};legacy.rate=1600;
 auto run=[&](char code,Line line=Line{}){ensure(order.apply(code,line)==legacy_apply(legacy,code,line),"same transition outcome");compare(order.snapshot(),legacy_snapshot(legacy));};
 run('A',{2,250});run('A',{1,150});
 ensure(order.snapshot().subtotal==650,"integer subtotal");
 ensure(order.snapshot().tax==104,"16 percent exact tax");
 run('P');ensure(order.snapshot().state==State::approved,"approved");
 run('A',{1,1});ensure(order.snapshot().subtotal==650,"no modification post-approval");
 run('S');ensure(order.snapshot().state==State::shipped,"shipping needs approval");
 run('R');ensure(order.snapshot().state==State::shipped,"shipped is terminal");
 run('S');ensure(order.snapshot().accepted==4&&order.snapshot().refused==3,"accepted and rejected commands counted");
 Order rejected{500};ensure(rejected.apply('R'),"draft can reject");ensure(!rejected.apply('A',{1,10}),"rejected immutable");
 Order half{125};ensure(half.apply('A',{1,4}),"small sale");ensure(half.snapshot().tax==0,"fractional cents round down");
 Order rounded{125};ensure(rounded.apply('A',{1,40}),"half-cent sale");ensure(rounded.snapshot().tax==1,"half cent rounds up");
 std::cout<<"PASS: domain lifecycle, invariant and parity assertions\n";
}
