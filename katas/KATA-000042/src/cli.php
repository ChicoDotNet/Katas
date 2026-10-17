<?php
// SPDX-License-Identifier: MIT
declare(strict_types=1);
require __DIR__.'/TreeBuilding.php';
$cases=json_decode(stream_get_contents(STDIN),true,512,JSON_THROW_ON_ERROR);
$out=[];
foreach($cases as $records){
 try{$out[]=['ok'=>true,'tree'=>\NinjaTree\build($records)];}
 catch(InvalidArgumentException $e){$out[]=['ok'=>false];}
}
echo json_encode($out,JSON_THROW_ON_ERROR),"\n";
