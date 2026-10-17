// SPDX-License-Identifier: MIT
#pragma once
#include <cstdint>
#include <stdexcept>
#include <vector>
#include <string>
namespace ninja_orders {
struct Line { std::int64_t quantity; std::int64_t cents; };
enum class State { draft, approved, rejected, shipped };
inline std::int64_t subtotal_of(const std::vector<Line>& lines) {
 std::int64_t subtotal=0;
 for(auto line:lines){subtotal+=line.quantity*line.cents;}
 return subtotal;
}
inline std::int64_t tax_of(std::int64_t subtotal,int rate_bps){
 return (subtotal*rate_bps+5000)/10000; // nearest cent, half up
}
struct Snapshot { State state; std::int64_t subtotal,tax,total; int accepted,refused; };
// Deliberately anemic, procedural teaching specimen, original to this repo.
struct LegacyOrder { State state=State::draft;std::vector<Line> lines;int rate;int accepted=0,refused=0; };
inline bool legacy_apply(LegacyOrder& order,char command,Line line={}){
 bool success=false;
 if(command=='A'&&order.state==State::draft&&line.quantity>0&&line.cents>=0){
  order.lines.push_back(line);success=true;
 }else if(command=='P'&&order.state==State::draft&&!order.lines.empty()){
  order.state=State::approved;success=true;
 }else if(command=='R'&&(order.state==State::draft||order.state==State::approved)){
  order.state=State::rejected;success=true;
 }else if(command=='S'&&order.state==State::approved){
  order.state=State::shipped;success=true;
 }
 success?++order.accepted:++order.refused;return success;
}
inline Snapshot legacy_snapshot(const LegacyOrder& o){auto sub=subtotal_of(o.lines);auto tax=tax_of(sub,o.rate);return{o.state,sub,tax,sub+tax,o.accepted,o.refused};}
// Domain model encapsulates all state changes and validates transitions.
class Order {
public:
 explicit Order(int tax_rate_bps):rate_(tax_rate_bps){if(rate_<0||rate_>2000)throw std::invalid_argument("tax rate");}
 bool apply(char command,Line line={}){
#ifdef KATA_RED
  (void)command;(void)line;++rejected_;return false;
#else
  bool allowed=false;
  switch(command){
  case 'A':if(state_==State::draft&&line.quantity>0&&line.cents>=0){lines_.push_back(line);allowed=true;}break;
  case 'P':if(state_==State::draft&&!lines_.empty()){state_=State::approved;allowed=true;}break;
  case 'R':if(state_==State::draft||state_==State::approved){state_=State::rejected;allowed=true;}break;
  case 'S':if(state_==State::approved){state_=State::shipped;allowed=true;}break;
  default:break;
  }
  allowed?++accepted_:++rejected_;return allowed;
#endif
 }
 [[nodiscard]] Snapshot snapshot() const{
  auto sub=subtotal_of(lines_);auto tax=tax_of(sub,rate_);
  return{state_,sub,tax,sub+tax,accepted_,rejected_};
 }
private:
 State state_=State::draft;
 std::vector<Line> lines_;
 int rate_;
 int accepted_=0,rejected_=0;
};
}
