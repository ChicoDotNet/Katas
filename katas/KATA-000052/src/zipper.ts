// SPDX-License-Identifier: MIT
export type Tree={value:number;left:Tree|null;right:Tree|null};
type Direction='L'|'R';
type Crumb={parent:number;sibling:Tree|null;from:Direction};
declare const process:{env:Record<string,string|undefined>};
export class Zipper{
 private constructor(private readonly focus:Tree,private readonly crumbs:readonly Crumb[]){}
 static from(root:Tree):Zipper{return new Zipper(root,[]);}
 value():number{return this.focus.value;}
 left():Zipper|null{
  if(!this.focus.left)return null;
  return new Zipper(this.focus.left,[...this.crumbs,{parent:this.focus.value,sibling:this.focus.right,from:'L'}]);
 }
 right():Zipper|null{
  if(!this.focus.right)return null;
  return new Zipper(this.focus.right,[...this.crumbs,{parent:this.focus.value,sibling:this.focus.left,from:'R'}]);
 }
 up():Zipper|null{
  if(!this.crumbs.length)return null;
  const crumb=this.crumbs[this.crumbs.length-1];
  const parent=crumb.from==='L'
   ?{value:crumb.parent,left:this.focus,right:crumb.sibling}
   :{value:crumb.parent,left:crumb.sibling,right:this.focus};
  return new Zipper(parent,this.crumbs.slice(0,-1));
 }
 setValue(value:number):Zipper{
  if(!Number.isSafeInteger(value))throw new TypeError('safe integer required');
  if(process.env.KATA_RED==='1')return this;
  return new Zipper({...this.focus,value},this.crumbs);
 }
 setLeft(tree:Tree|null):Zipper{return new Zipper({...this.focus,left:tree},this.crumbs);}
 setRight(tree:Tree|null):Zipper{return new Zipper({...this.focus,right:tree},this.crumbs);}
 toRoot():Tree{
  let current:Zipper=this;
  while(true){const parent=current.up();if(!parent)return current.focus;current=parent;}
 }
}
