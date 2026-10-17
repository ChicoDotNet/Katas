//go:build kata_red

// SPDX-License-Identifier: MIT
package rover

// Deliberately wrong, compilable behavioral RED, using shared domain types.
func Navigate(_ World, pose Pose, commands string)(Result,error){
 return Result{Pose:pose,Applied:len(commands)},nil
}
