// SPDX-License-Identifier: MIT
// Compilable behavioral mutant: posts before awaiting required GPS.
export async function redClockIn({now,send}){return await send({at:now()});}
