<?php
// SPDX-License-Identifier: MIT
declare(strict_types=1);
require __DIR__.'/VLQ.php';
$cases=json_decode(stream_get_contents(STDIN),true,512,JSON_THROW_ON_ERROR);
if(!is_array($cases)||!array_is_list($cases))throw new InvalidArgumentException('cases array expected');
$out=[];
foreach($cases as $case){
 try{
  $input=$case['values']??null;
  if(!is_array($input)||!array_is_list($input))throw new InvalidArgumentException('values array expected');
  $result=match($case['action']??null){
   'encode'=>\NinjaVLQ\encode($input),
   'decode'=>\NinjaVLQ\decode($input),
   default=>throw new InvalidArgumentException('unknown action')
  };
  $out[]=['ok'=>true,'result'=>$result];
 }catch(InvalidArgumentException $e){$out[]=['ok'=>false];}
}
echo json_encode($out,JSON_THROW_ON_ERROR),"\n";
