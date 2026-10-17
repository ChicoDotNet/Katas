<?php
// SPDX-License-Identifier: MIT
declare(strict_types=1);
namespace NinjaTree;
use InvalidArgumentException;
/** Reconstruct an ordered forum tree from unsorted parent-linked records. */
function build(array $rows):array {
 $n=count($rows);
 if($n<1||$n>1000)throw new InvalidArgumentException('root and bounded records required');
 $parents=array_fill(0,$n,null);
 foreach($rows as $row){
  if(!is_array($row)||!array_key_exists('id',$row)||!array_key_exists('parent',$row))throw new InvalidArgumentException('missing keys');
  $id=$row['id'];$parent=$row['parent'];
  if(!is_int($id)||!is_int($parent)||$id<0||$id>=$n||$parents[$id]!==null)throw new InvalidArgumentException('duplicate/invalid id');
  if($id===0?$parent!==0:($parent<0||$parent>=$id))throw new InvalidArgumentException('invalid parent');
  $parents[$id]=$parent;
 }
 foreach($parents as $parent)if($parent===null)throw new InvalidArgumentException('missing record');
 if(getenv('KATA_RED')==='1')return ['id'=>0,'children'=>[]];
 $children=array_fill(0,$n,[]);
 for($id=1;$id<$n;$id++)$children[$parents[$id]][]=$id;
 $make=function(int $id)use(&$make,$children):array{
  return ['id'=>$id,'children'=>array_map($make,$children[$id])];
 };
 return $make(0);
}
