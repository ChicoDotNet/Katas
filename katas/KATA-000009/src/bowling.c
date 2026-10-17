/* SPDX-License-Identifier: MIT */
#include "bowling.h"
void game_init(Game *g){g->count=0;}
int game_roll(Game *g,int pins){
 if(!g||pins<0||pins>10||g->count>=21)return 0;
 g->rolls[g->count++]=pins;return 1;
}
int game_score(const Game *g){
 if(!g)return -1;
 int offset=0,total=0;
 for(int frame=0;frame<10;frame++){
  if(offset>=g->count)return -1;
  int first=g->rolls[offset];if(first<0||first>10)return -1;
  if(frame==9){
   if(offset+1>=g->count)return -1;
   int second=g->rolls[offset+1];if(second<0||second>10)return -1;
   if(first<10&&first+second>10)return -1;
   total+=first+second;offset+=2;
   if(first==10||first+second==10){
    if(offset>=g->count)return -1;
    int bonus=g->rolls[offset++];if(bonus<0||bonus>10)return -1;
    if(first==10&&second<10&&second+bonus>10)return -1;
    total+=bonus;
   }
  }else if(first==10){
   if(offset+2>=g->count)return -1;
   int second=g->rolls[offset+1],third=g->rolls[offset+2];
   if(second<0||second>10||third<0||third>10)return -1;
   if(second<10&&second+third>10)return -1;
   total+=10+second+third;offset++;
  }else{
   if(offset+1>=g->count)return -1;
   int second=g->rolls[offset+1];if(second<0||second>10||first+second>10)return -1;
   if(first+second==10){
    if(offset+2>=g->count)return -1;
    int bonus=g->rolls[offset+2];if(bonus<0||bonus>10)return -1;
    total+=10+bonus;
   }else total+=first+second;
   offset+=2;
  }
 }
 return offset==g->count?total:-1;
}
