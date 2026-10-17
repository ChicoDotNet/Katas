//go:build kata_red
// SPDX-License-Identifier: MIT
package lift
func(e *Engine)Tick()Event{return Event{e.floor,"idle"}}
