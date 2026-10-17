<?php
declare(strict_types=1);
require __DIR__.'/../src/VLQ.php';
function same(mixed $want,mixed $actual,string $note):void{
 if($want!==$actual)throw new Exception("FAIL behavioral assertion: $note ".json_encode([$want,$actual]));
}
function reject(callable $work,string $note):void{
 try{$work();}catch(InvalidArgumentException){return;}
 throw new Exception("FAIL no exception: $note");
}
same([],\NinjaVLQ\encode([]),'empty encode');
same([0],\NinjaVLQ\encode([0]),'zero');
same([127],\NinjaVLQ\encode([127]),'seven bits');
same([129,0],\NinjaVLQ\encode([128]),'128 boundary');
same([255,127],\NinjaVLQ\encode([16383]),'two max');
same([129,128,0],\NinjaVLQ\encode([16384]),'three min');
same([143,255,255,255,127],\NinjaVLQ\encode([4294967295]),'uint32 max');
same([128,127,4294967295],\NinjaVLQ\decode([129,0,127,143,255,255,255,127]),'concatenated decode');
same([],\NinjaVLQ\decode([]),'empty decode');
reject(fn()=>\NinjaVLQ\decode([128]),'unterminated');
reject(fn()=>\NinjaVLQ\decode([128,0]),'overlong zero');
reject(fn()=>\NinjaVLQ\decode([144,128,128,128,0]),'uint32 overflow');
reject(fn()=>\NinjaVLQ\decode([129,128,128,128,128,0]),'six groups');
reject(fn()=>\NinjaVLQ\decode([256]),'invalid byte');
reject(fn()=>\NinjaVLQ\encode([-1]),'negative input');
reject(fn()=>\NinjaVLQ\encode([4294967296]),'over max');
echo "PASS: 16 PHP VLQ exact-boundary and error assertions\n";
