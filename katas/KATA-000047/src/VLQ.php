<?php
// SPDX-License-Identifier: MIT
declare(strict_types=1);
namespace NinjaVLQ;
use InvalidArgumentException;
const U32_MAX=4294967295;
function encode(array $values):array{
 $out=[];
 foreach($values as $value){
  if(!is_int($value)||$value<0||$value>U32_MAX)throw new InvalidArgumentException('unsigned 32-bit value required');
  $bytes=[];
  do{array_unshift($bytes,$value&0x7f);$value>>=7;}while($value>0);
  for($i=0;$i<count($bytes)-1;$i++)$bytes[$i]|=0x80;
  foreach($bytes as $b)$out[]=$b;
 }
 return $out;
}
function decode(array $bytes):array{
 if(getenv('KATA_RED')==='1')return []; // deliberately incorrect behavioral RED
 $out=[];$value=0;$groups=0;
 foreach($bytes as $b){
  if(!is_int($b)||$b<0||$b>255)throw new InvalidArgumentException('byte required');
  $groups++;
  if($groups>5)throw new InvalidArgumentException('VLQ too long');
  if($groups===1&&($b&0x7f)===0&&($b&0x80)!==0)throw new InvalidArgumentException('noncanonical leading zero');
  $value=($value<<7)|($b&0x7f);
  if($value>U32_MAX)throw new InvalidArgumentException('32-bit overflow');
  if(($b&0x80)===0){$out[]=$value;$value=0;$groups=0;}
 }
 if($groups!==0)throw new InvalidArgumentException('unterminated VLQ');
 return $out;
}
