// SPDX-License-Identifier: MIT
#include "connect.hpp"
#include <iostream>
#include <string>
#include <vector>
int main(){
 std::string line;
 while(std::getline(std::cin,line)){
  std::vector<std::string> board;
  std::string row;
  for(char ch:line){if(ch=='|'){board.push_back(row);row.clear();}else row.push_back(ch);}
  board.push_back(row);
  try{std::cout<<ninja_hex::winner(board)<<'\n';}catch(const std::invalid_argument&){std::cout<<"ERROR\n";}
 }
}
