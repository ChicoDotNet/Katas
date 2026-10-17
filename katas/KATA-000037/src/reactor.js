// SPDX-License-Identifier: MIT
'use strict';
export class Reactor {
  #cells = [];
  #notifying = false;
  input(initial) {
    if (!Number.isSafeInteger(initial)) throw new TypeError('integer required');
    const cell = {type:'input', value:initial, deps:[], fn:null, callbacks:new Map()};
    this.#cells.push(cell);
    return cell;
  }
  compute(dependencies, fn) {
    if (!Array.isArray(dependencies) || dependencies.length === 0 || typeof fn !== 'function') throw new TypeError('dependencies and function required');
    for (const dep of dependencies) if (!this.#cells.includes(dep)) throw new TypeError('foreign or future dependency');
    const value = fn(...dependencies.map(c=>c.value));
    if (!Number.isSafeInteger(value)) throw new TypeError('integer result required');
    const cell = {type:'compute', value, deps:[...dependencies], fn, callbacks:new Map()};
    this.#cells.push(cell);
    return cell;
  }
  observe(cell, callback) {
    if (!this.#cells.includes(cell) || typeof callback !== 'function') throw new TypeError('unknown cell/callback');
    if (cell.type !== 'compute') throw new TypeError('only computed cells support callbacks');
    const token = Symbol('subscription');
    cell.callbacks.set(token, callback);
    return () => cell.callbacks.delete(token);
  }
  set(cell, next) {
    if (!this.#cells.includes(cell) || cell.type !== 'input' || !Number.isSafeInteger(next)) throw new TypeError('expected input and safe integer');
    if (this.#notifying) throw new Error('reentrant updates forbidden');
    if (cell.value === next) return;
    const previous = new Map(this.#cells.map(c=>[c,c.value]));
    cell.value = next;
    if (process.env.KATA_RED === '1') return; // intentionally incorrect behavioral RED
    const changes = [];
    try {
      for (const computed of this.#cells) {
        if (computed.type === 'input') continue;
        const updated = computed.fn(...computed.deps.map(c=>c.value));
        if (!Number.isSafeInteger(updated)) throw new TypeError('integer result required');
        computed.value = updated;
      }
      for (const computed of this.#cells) {
        if (computed.type === 'compute' && previous.get(computed) !== computed.value) changes.push([computed, computed.value]);
      }
    } catch (err) {
      for (const [c,val] of previous) c.value = val;
      throw err;
    }
    this.#notifying = true;
    try {
      for (const [c,val] of changes) for (const fn of c.callbacks.values()) fn(val);
    } finally { this.#notifying = false; }
  }
  values() { return this.#cells.map(c=>c.value); }
}
