// SPDX-License-Identifier: MIT
// Compilable, intentionally incorrect implementation for RED-only isolated build.
export class ForthError extends Error {}
export class Forth { evaluate(_source: string): number[] { return []; } }
export function evaluateProgram(_source: string): number[] { return []; }
