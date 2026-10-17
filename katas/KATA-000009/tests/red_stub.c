/* SPDX-License-Identifier: MIT */
#include "../src/bowling.h"
void game_init(Game *g){g->count=0;}
int game_roll(Game *g,int p){if(p<0||p>10||g->count>=21)return 0;g->rolls[g->count++]=p;return 1;}
int game_score(const Game *g){(void)g;return 0;}
