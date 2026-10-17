/* SPDX-License-Identifier: MIT */
#ifndef NINJA_RING_H
#define NINJA_RING_H
#include <stddef.h>
typedef struct{int data[128];size_t capacity,head,size;}Ring;
int ring_init(Ring*,size_t);
int ring_write(Ring*,int,int);
int ring_read(Ring*,int*);
void ring_clear(Ring*);
size_t ring_snapshot(const Ring*,int*);
#endif
