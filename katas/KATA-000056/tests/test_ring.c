/* SPDX-License-Identifier: MIT */
#include "../src/ring.h"
#include <assert.h>
#include <stdio.h>
static void same(const Ring*r,const int*expected,size_t n){
 int values[128];assert(ring_snapshot(r,values)==n);
 for(size_t i=0;i<n;i++)assert(values[i]==expected[i]);
}
int main(void){
 Ring r;assert(!ring_init(&r,0));assert(!ring_init(&r,129));assert(ring_init(&r,3));
 int v=0;assert(!ring_read(&r,&v));
 assert(ring_write(&r,4,0)&&ring_write(&r,5,0)&&ring_write(&r,6,0));
 {const int a[]={4,5,6};same(&r,a,3);}
 assert(!ring_write(&r,7,0));
 assert(ring_write(&r,7,1));{const int a[]={5,6,7};same(&r,a,3);}
 assert(ring_read(&r,&v)&&v==5);
 assert(ring_write(&r,8,0));{const int a[]={6,7,8};same(&r,a,3);}
 assert(ring_read(&r,&v)&&v==6);assert(ring_read(&r,&v)&&v==7);
 assert(ring_read(&r,&v)&&v==8);assert(!ring_read(&r,&v));
 assert(ring_write(&r,9,0));ring_clear(&r);same(&r,NULL,0);
 assert(ring_write(&r,10,0));{const int a[]={10};same(&r,a,1);}
 puts("PASS: 12 C ring buffer contract/boundary assertions");
}
