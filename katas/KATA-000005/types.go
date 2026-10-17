// SPDX-License-Identifier: MIT
package rover

type Point struct{ X, Y int }
type Pose struct{ X, Y int; Facing string }
type World struct{ Width, Height int; Obstacles []Point }
type Result struct{ Pose Pose; Blocked bool; Obstacle *Point; Applied int }
