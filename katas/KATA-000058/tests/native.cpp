// SPDX-License-Identifier: MIT
#include "../src/ledger.hpp"
#include <iostream>
#include <random>
#include <stdexcept>
#include <set>
using namespace ledger;
static std::uint64_t checks=0;
void expect(bool ok,const char* message) {++checks;if(!ok) throw std::runtime_error(message);}
template<class F> void rejects(F f) {bool caught=false;try{f();}catch(const std::exception&){caught=true;}expect(caught,"expected rejection");}
int main() {
 try {
  auto us=Locale::US; auto nl=Locale::NL;auto usd=Currency::USD;auto eur=Currency::EUR;
  expect(format({},us,usd).size()==1,"empty ledger");
  expect(format({},nl,eur)[0].substr(0,5)=="Datum","NL heading");
  expect(date_display("2024-02-29",us)=="02/29/2024","leap date");
  expect(date_display("2000-02-29",nl)=="29-02-2000","century leap");
  rejects([&]{date_display("1900-02-29",us);});
  rejects([&]{date_display("2023-02-29",us);});
  rejects([&]{date_display("2024-13-01",us);});
  rejects([&]{date_display("2024-04-31",us);});
  rejects([&]{date_display("2024-00-01",us);});
  rejects([&]{date_display("2024-01-00",us);});
  rejects([&]{date_display("0000-01-01",us);});
  rejects([&]{date_display("2024-01-1x",us);});
  rejects([&]{locale_of("en_GB");});
  rejects([&]{currency_of("JPY");});
  expect(description_display(std::string(30,'a'))==std::string(22,'a')+"...","description truncate");
  expect(description_display("abc").size()==25,"description width");
  rejects([&]{description_display("bad\tvalue");});
  expect(amount_display(-1000,us,usd)=="     ($10.00)","negative USD");
  expect(amount_display(1000,us,eur)=="      €10.00 ","positive EUR");
  expect(amount_display(-12345,nl,usd)=="   $ -123,45 ","negative NL");
  expect(amount_display(123456,nl,eur)=="  € 1.234,56 ","positive NL");
  expect(amount_display(0,us,usd)=="       $0.00 ","zero US");
  rejects([&]{amount_display(INT64_MIN,us,usd);});
  auto ordered=format({{"2015-01-02","B",100},{"2015-01-01","B",20},{"2015-01-01","A",-5},{"2015-01-01","B",-5}},us,usd);
  expect(ordered.size()==5,"sort size");
  expect(ordered[1].find(" | A ")!=std::string::npos,"sort description");
  expect(ordered[2].find("($0.05)")!=std::string::npos,"sort amount");
  expect(ordered[4].find("01/02/2015")!=std::string::npos,"sort date");
  std::mt19937_64 rng(20261028);
  for(int i=0;i<25000;i++) {
    auto c=std::int64_t(rng()%9999999); if(i%2)c=-c;
    auto a=amount_display(c,i%3?us:nl,i%5?usd:eur);
    expect(a.size()==(i%5?13:15),"money width bytes; euro UTF8 occupies extra byte");
    expect(a.find(i%5?"$":"€")!=std::string::npos,"currency symbol");
    expect(a.find(i%3?".":",")!=std::string::npos,"decimal separator");
  }
  std::cout<<"PASS native C++ assertions: "<<checks<<"\n";
 }catch(const std::exception& e){std::cerr<<"FAIL native: "<<e.what()<<'\n';return 1;}
}
