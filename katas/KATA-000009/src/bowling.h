/* SPDX-License-Identifier: MIT */
#ifndef NINJA_BOWLING_H
#define NINJA_BOWLING_H
typedef struct { int rolls[21]; int count; } Game;
void game_init(Game *g);
int game_roll(Game *g,int pins);
int game_score(const Game *g); /* -1 invalid/incomplete */
#endif
