//go:build !kata_red

// SPDX-License-Identifier: MIT
package rover

import "fmt"

// Navigate validates commands before executing a finite, toroidal world.
// Obstacles stop execution before entering their square; previous moves remain.
func Navigate(world World, origin Pose, commands string) (Result, error) {
 if world.Width<1 || world.Height<1 || origin.X<0 || origin.Y<0 || origin.X>=world.Width || origin.Y>=world.Height {
  return Result{},fmt.Errorf("invalid world or starting coordinates")
 }
 headings:=[]string{"N","E","S","W"}
 direction:=-1
 for i,heading:=range headings {if origin.Facing==heading{direction=i}}
 if direction<0{return Result{},fmt.Errorf("invalid heading")}
 for _,action:=range commands {if action!='f' && action!='b' && action!='l' && action!='r'{return Result{},fmt.Errorf("invalid command: %q",action)}}
 blocked:=make(map[Point]bool,len(world.Obstacles))
 for _,obstacle:=range world.Obstacles {
  if obstacle.X<0 || obstacle.Y<0 || obstacle.X>=world.Width || obstacle.Y>=world.Height {return Result{},fmt.Errorf("obstacle outside world")}
  blocked[obstacle]=true
 }
 pose:=origin
 for index,action:=range commands {
  switch action {
  case 'l':direction=(direction+3)%4
  case 'r':direction=(direction+1)%4
  case 'f','b':
   step:=1
   if action=='b'{step=-1}
   dx,dy:=0,0
   switch direction {
   case 0:dy=step
   case 1:dx=step
   case 2:dy=-step
   case 3:dx=-step
   }
   target:=Point{X:(pose.X+dx+world.Width)%world.Width,Y:(pose.Y+dy+world.Height)%world.Height}
   if blocked[target]{return Result{Pose:pose,Blocked:true,Obstacle:&target,Applied:index},nil}
   pose.X,pose.Y=target.X,target.Y
  }
  pose.Facing=headings[direction]
 }
 return Result{Pose:pose,Applied:len(commands)},nil
}
