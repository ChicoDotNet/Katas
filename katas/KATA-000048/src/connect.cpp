// SPDX-License-Identifier: MIT
#include "connect.hpp"
#include <array>
#include <queue>
#include <stdexcept>
namespace ninja_hex {
char winner(const std::vector<std::string>& board){
 if(board.empty()||board.size()>64||board[0].empty()||board[0].size()>64)throw std::invalid_argument("board size");
 const int height=static_cast<int>(board.size()),width=static_cast<int>(board[0].size());
 for(const auto& row:board){
  if(static_cast<int>(row.size())!=width)throw std::invalid_argument("ragged board");
  for(char ch:row)if(ch!='.'&&ch!='O'&&ch!='X')throw std::invalid_argument("invalid symbol");
 }
#ifdef KATA_RED
 (void)height;
 return '.';
#else
 static constexpr std::array<std::pair<int,int>,6> offsets={{{-1,0},{-1,1},{0,-1},{0,1},{1,-1},{1,0}}};
 const auto connected=[&](char who){
  std::queue<std::pair<int,int>> queue;
  std::vector<std::vector<bool>> seen(height,std::vector<bool>(width));
  for(int i=0;i<(who=='O'?width:height);++i){
   const int r=who=='O'?0:i,c=who=='O'?i:0;
   if(board[r][c]==who){queue.emplace(r,c);seen[r][c]=true;}
  }
  while(!queue.empty()){
   auto [r,c]=queue.front();queue.pop();
   if((who=='O'&&r==height-1)||(who=='X'&&c==width-1))return true;
   for(const auto& [dr,dc]:offsets){
    const int nr=r+dr,nc=c+dc;
    if(nr<0||nc<0||nr>=height||nc>=width||seen[nr][nc]||board[nr][nc]!=who)continue;
    seen[nr][nc]=true;queue.emplace(nr,nc);
   }
  }
  return false;
 };
 const bool o=connected('O'),x=connected('X');
 if(o&&x)throw std::invalid_argument("dual winner impossible under planar hex");
 return o?'O':x?'X':'.';
#endif
}
}
