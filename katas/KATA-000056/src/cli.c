/* SPDX-License-Identifier: MIT */
#include "ring.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main(void){
 char line[8192];
 while(fgets(line,sizeof line,stdin)){
  char*sep=strchr(line,'|');if(!sep){puts("ERROR");continue;}
  *sep=0;long cap=strtol(line,NULL,10);Ring r;
  if(cap<1||cap>128||!ring_init(&r,(size_t)cap)){puts("ERROR");continue;}
  int first=1;
  for(char*t=strtok(sep+1,";\r\n");t;t=strtok(NULL,";\r\n")){
   if(!first){putchar(';');}first=0;
   int v=0,ok=0;
   if(t[0]=='W'||t[0]=='O'){
    long n=strtol(t+1,NULL,10);
    ok=ring_write(&r,(int)n,t[0]=='O');printf("%d",ok);
   }else if(t[0]=='R'){
    ok=ring_read(&r,&v);if(ok)printf("1:%d",v);else putchar('0');
   }else if(t[0]=='C'){ring_clear(&r);putchar('1');}
   else{putchar('0');}
  }
  int values[128];size_t n=ring_snapshot(&r,values);
  printf("|%zu|",n);
  for(size_t i=0;i<n;i++){if(i)putchar(',');printf("%d",values[i]);}
  putchar('\n');
 }
}
