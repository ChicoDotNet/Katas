// SPDX-License-Identifier: MIT
// Input: rate|A,qty,cents|P|S|R. Output: state;subtotal;tax;total;accepted;refused.
#include "orders.hpp"
#include <iostream>
#include <sstream>
#include <string>
#include <vector>
using namespace ninja_orders;
static std::vector<std::string> split(std::string value,char delim){
 std::vector<std::string> out;std::istringstream stream(value);std::string token;
 while(std::getline(stream,token,delim))out.push_back(token);
 return out;
}
int main(){
 std::string scenario;
 while(std::getline(std::cin,scenario)){
  if(scenario.empty())continue;
  try{
   auto fields=split(scenario,'|');int rate=std::stoi(fields.at(0));Order order(rate);
   for(std::size_t i=1;i<fields.size();++i){
    auto op=split(fields[i],',');
    if(op.size()==3&&op[0]=="A")order.apply('A',{std::stoll(op[1]),std::stoll(op[2])});
    else if(op.size()==1&&op[0].size()==1)order.apply(op[0][0]);
    else order.apply('?');
   }
   auto s=order.snapshot();
   std::cout<<static_cast<int>(s.state)<<';'<<s.subtotal<<';'<<s.tax<<';'<<s.total<<';'<<s.accepted<<';'<<s.refused<<'\n';
  }catch(const std::exception&){std::cout<<"ERROR\n";}
 }
}
