// SPDX-License-Identifier: MIT
#include "ledger.hpp"
#include <iostream>
int main(int argc,char** argv) {
  try {
    if(argc!=3) throw std::invalid_argument("usage: ledger LOCALE CURRENCY < TAB_SEPARATED_ENTRIES");
    auto loc=ledger::locale_of(argv[1]); auto curr=ledger::currency_of(argv[2]);
    std::vector<ledger::Entry> entries;
    std::string line;
    while(std::getline(std::cin,line)) {
      auto a=line.find('\t'); auto b=a==std::string::npos?a:line.find('\t',a+1);
      if(a==std::string::npos || b==std::string::npos || line.find('\t',b+1)!=std::string::npos) throw std::invalid_argument("bad TSV row");
      std::string value=line.substr(b+1);
      std::size_t used=0;
      auto cents=std::stoll(value,&used,10);
      if(used!=value.size()) throw std::invalid_argument("invalid cents");
      entries.push_back({line.substr(0,a),line.substr(a+1,b-a-1),cents});
    }
    for(const auto& row:ledger::format(entries,loc,curr)) std::cout<<row<<'\n';
  } catch(const std::exception& e) { std::cerr<<"ledger error: "<<e.what()<<'\n'; return 2; }
}
