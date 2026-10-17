/* SPDX-License-Identifier: MIT */
#include "bowling.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main(void){
 char line[256];
 while(fgets(line,sizeof(line),stdin)){
  Game g;game_init(&g);
  int valid=1;
  for(char *p=strtok(line,",\r\n ");p;p=strtok(NULL,",\r\n ")){
   char *end;long val=strtol(p,&end,10);
   if(*end||val<0||val>10||!game_roll(&g,(int)val)){valid=0;break;}
  }
  printf("%d\n",valid?game_score(&g):-1);
 }
}
