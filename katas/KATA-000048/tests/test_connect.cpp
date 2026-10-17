// SPDX-License-Identifier: MIT
#include "../src/connect.hpp"
#include <cassert>
#include <iostream>
#include <stdexcept>
using ninja_hex::winner;
int main(){
 assert(winner({"."})=='.');
 assert(winner({"O"})=='O');
 assert(winner({"X"})=='X');
 assert(winner({"O.","O."})=='O');
 assert(winner({"XX",".."})=='X');
 assert(winner({"X.","OX"})=='.');
 assert(winner({".X.","XO.","O.O"})=='.');
 assert(winner({"O..",".O.","..O"})=='.');
 assert(winner({"O..","O..","O.."})=='O');
 assert(winner({".X.",".X.",".X."})=='.');
 assert(winner({"XX.","..."})=='.');
 assert(winner({".X.","XX.","..X"})=='.');
 try{winner({"XX","X"});assert(false);}catch(const std::invalid_argument&){}
 try{winner({"OY"});assert(false);}catch(const std::invalid_argument&){}
 std::cout<<"PASS: 12 Hex winner checks and 2 invalid-board checks\n";
}
