// SPDX-License-Identifier: MIT
package rover

import (
	"math/rand"
	"strings"
	"testing"
)

// checkRoverResult compares both the stop witness and the progress counter.
// We deliberately avoid an independent step-by-step coordinate simulator here:
// the existing Python differential oracle provides that second algorithm.
func checkRoverResult(t *testing.T, want, got Result) {
	t.Helper()
	if got.Pose != want.Pose || got.Blocked != want.Blocked || got.Applied != want.Applied {
		t.Fatalf("metamorphic result mismatch: got=%+v want=%+v", got, want)
	}
	if (got.Obstacle == nil) != (want.Obstacle == nil) {
		t.Fatalf("metamorphic obstacle presence mismatch: got=%+v want=%+v", got, want)
	}
	if got.Obstacle != nil && *got.Obstacle != *want.Obstacle {
		t.Fatalf("metamorphic obstacle mismatch: got=%+v want=%+v", got, want)
	}
}

func navigateOK(t *testing.T, w World, p Pose, commands string) Result {
	t.Helper()
	result, err := Navigate(w, p, commands)
	if err != nil {
		t.Fatalf("unexpected error for %q in %+v: %v", commands, w, err)
	}
	return result
}

// An explicit cardinal anchor prevents an internally consistent but reversed
// Go/Python coordinate convention from making every relational property pass.
func TestCardinalAndToroidalAnchors(t *testing.T) {
	cases := []struct {
		start  Pose
		action string
		want   Pose
	}{
		{Pose{2, 2, "N"}, "f", Pose{2, 3, "N"}},
		{Pose{2, 2, "E"}, "f", Pose{3, 2, "E"}},
		{Pose{2, 2, "S"}, "f", Pose{2, 1, "S"}},
		{Pose{2, 2, "W"}, "f", Pose{1, 2, "W"}},
		{Pose{0, 0, "S"}, "f", Pose{0, 4, "S"}},
		{Pose{0, 0, "W"}, "f", Pose{4, 0, "W"}},
		{Pose{4, 4, "N"}, "f", Pose{4, 0, "N"}},
		{Pose{4, 4, "E"}, "f", Pose{0, 4, "E"}},
	}
	for _, c := range cases {
		got := navigateOK(t, World{Width: 5, Height: 5}, c.start, c.action)
		checkRoverResult(t, Result{Pose: c.want, Applied: 1}, got)
	}
}

func TestMetamorphicTurnsAndInverses(t *testing.T) {
	rng := rand.New(rand.NewSource(20261019))
	headings := []string{"N", "E", "S", "W"}
	for i := 0; i < 320; i++ {
		w := World{Width: 2 + rng.Intn(19), Height: 2 + rng.Intn(17)}
		start := Pose{X: rng.Intn(w.Width), Y: rng.Intn(w.Height), Facing: headings[rng.Intn(len(headings))]}
		for _, commands := range []string{"llll", "rrrr", "lr", "rl", "fb", "bf"} {
			got := navigateOK(t, w, start, commands)
			checkRoverResult(t, Result{Pose: start, Applied: len(commands)}, got)
		}
		// Wrapping through exactly one whole dimension is a geometric identity.
		dimension := w.Height
		if start.Facing == "E" || start.Facing == "W" {
			dimension = w.Width
		}
		got := navigateOK(t, w, start, strings.Repeat("f", dimension))
		checkRoverResult(t, Result{Pose: start, Applied: dimension}, got)
	}
}

func translated(p Point, dx, dy int, w World) Point {
	return Point{X: (p.X + dx) % w.Width, Y: (p.Y + dy) % w.Height}
}

func TestMetamorphicToroidalTranslationWithObstacles(t *testing.T) {
	rng := rand.New(rand.NewSource(20261019 + 1))
	headings := []string{"N", "E", "S", "W"}
	actions := []byte("fblr")
	for i := 0; i < 300; i++ {
		w := World{Width: 2 + rng.Intn(11), Height: 2 + rng.Intn(11)}
		for x := 0; x < w.Width; x++ {
			for y := 0; y < w.Height; y++ {
				if rng.Intn(8) == 0 {
					w.Obstacles = append(w.Obstacles, Point{X: x, Y: y})
				}
			}
		}
		start := Pose{X: rng.Intn(w.Width), Y: rng.Intn(w.Height), Facing: headings[rng.Intn(4)]}
		commands := make([]byte, rng.Intn(85))
		for j := range commands {
			commands[j] = actions[rng.Intn(len(actions))]
		}
		original := navigateOK(t, w, start, string(commands))
		dx, dy := rng.Intn(w.Width), rng.Intn(w.Height)
		moved := World{Width: w.Width, Height: w.Height, Obstacles: make([]Point, 0, len(w.Obstacles))}
		for _, obs := range w.Obstacles {
			moved.Obstacles = append(moved.Obstacles, translated(obs, dx, dy, w))
		}
		movedStart := translated(Point{X: start.X, Y: start.Y}, dx, dy, w)
		shifted := navigateOK(t, moved, Pose{X: movedStart.X, Y: movedStart.Y, Facing: start.Facing}, string(commands))
		expected := original
		position := translated(Point{X: original.Pose.X, Y: original.Pose.Y}, dx, dy, w)
		expected.Pose.X, expected.Pose.Y = position.X, position.Y
		if original.Obstacle != nil {
			ob := translated(*original.Obstacle, dx, dy, w)
			expected.Obstacle = &ob
		}
		checkRoverResult(t, expected, shifted)
	}
}

func TestMetamorphicCommandCompositionAndPartialObstacleStop(t *testing.T) {
	rng := rand.New(rand.NewSource(20261019 + 2))
	headings := []string{"N", "E", "S", "W"}
	actions := []byte("fblr")
	for i := 0; i < 300; i++ {
		world := World{Width: 2 + rng.Intn(11), Height: 2 + rng.Intn(11)}
		for x := 0; x < world.Width; x++ {
			for y := 0; y < world.Height; y++ {
				if rng.Intn(7) == 0 {
					world.Obstacles = append(world.Obstacles, Point{X: x, Y: y})
				}
			}
		}
		start := Pose{X: rng.Intn(world.Width), Y: rng.Intn(world.Height), Facing: headings[rng.Intn(4)]}
		commands := make([]byte, rng.Intn(80))
		for j := range commands {
			commands[j] = actions[rng.Intn(len(actions))]
		}
		split := rng.Intn(len(commands) + 1)
		all := navigateOK(t, world, start, string(commands))
		prefix := navigateOK(t, world, start, string(commands[:split]))
		if prefix.Blocked {
			// The complete run must stop at the same earliest obstacle.
			checkRoverResult(t, prefix, all)
			continue
		}
		suffix := navigateOK(t, world, prefix.Pose, string(commands[split:]))
		composed := suffix
		composed.Applied += split
		checkRoverResult(t, composed, all)
	}
}
