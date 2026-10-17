/* SPDX-License-Identifier: MIT */
#include "ring.h"
int ring_init(Ring*r,size_t n){if(!r||n<1||n>128)return 0;r->capacity=n;r->head=0;r->size=0;return 1;}
int ring_write(Ring*r,int v,int overwrite){
 if(!r||r->capacity==0)return 0;
 if(r->size==r->capacity){
  if(!overwrite)return 0;
  r->data[r->head]=v;r->head=(r->head+1)%r->capacity;return 1;
 }
 r->data[(r->head+r->size)%r->capacity]=v;r->size++;return 1;
}
int ring_read(Ring*r,int*v){
 if(!r||!v||r->size==0)return 0;
 *v=r->data[r->head];r->head=(r->head+1)%r->capacity;r->size--;return 1;
}
void ring_clear(Ring*r){if(r){r->head=0;r->size=0;}}
size_t ring_snapshot(const Ring*r,int*out){
 if(!r||!out)return 0;
 for(size_t i=0;i<r->size;i++)out[i]=r->data[(r->head+i)%r->capacity];
 return r->size;
}
