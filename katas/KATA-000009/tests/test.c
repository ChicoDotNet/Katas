/* SPDX-License-Identifier: MIT */
#include "../src/bowling.h"
#include <assert.h>
#include <stdio.h>
static int result(const int *rolls,int n){
 Game g;game_init(&g);
 for(int i=0;i<n;i++)assert(game_roll(&g,rolls[i]));
 return game_score(&g);
}
int main(void){
 int misses[20]={0};assert(result(misses,20)==0);
 int nines[20];for(int i=0;i<20;i++)nines[i]=(i%2)?0:9;assert(result(nines,20)==90);
 int spares[21];for(int i=0;i<21;i++)spares[i]=5;assert(result(spares,21)==150);
 int strikes[12];for(int i=0;i<12;i++)strikes[i]=10;assert(result(strikes,12)==300);
 int mixed[]={10,7,3,9,0,10,0,8,8,2,0,6,10,10,10,8,1};
 assert(result(mixed,17)==167);
 int incomplete[]={10,10};assert(result(incomplete,2)==-1);
 int illegal[]={8,5};assert(result(illegal,2)==-1);
 Game g;game_init(&g);assert(!game_roll(&g,-1));assert(!game_roll(&g,11));
 puts("PASS: 8 C bowling score and validation assertions");
}
