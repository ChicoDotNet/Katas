/* SPDX-License-Identifier: MIT */
#include "../src/ring.h"
int ring_init(Ring*r,size_t n){if(!r||n<1||n>128)return 0;r->capacity=n;r->head=r->size=0;return 1;}
int ring_write(Ring*r,int v,int overwrite){(void)overwrite;if(!r||r->size==r->capacity)return 0;r->data[r->size++]=v;return 1;}
int ring_read(Ring*r,int*v){if(!r||!v||!r->size)return 0;*v=r->data[r->head++];r->size--;return 1;}
void ring_clear(Ring*r){if(r)r->size=r->head=0;}
size_t ring_snapshot(const Ring*r,int*out){if(!r||!out)return 0;for(size_t i=0;i<r->size;i++)out[i]=r->data[i];return r->size;}
