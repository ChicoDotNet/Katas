-- SPDX-License-Identifier: MIT
-- Pure full-snapshot model, not JavaScript callback scheduling.
import Data.List (foldl', intercalate)
data Cell = Input Int | Derived String [Int]
array :: [String] -> String
array values = "[" ++ intercalate "," values ++ "]"
pair :: Int -> Int -> String
pair a b = array [show a,show b]
cellJson :: Cell -> String
cellJson (Input x) = "{\"kind\":\"input\",\"value\":"++show x++"}"
cellJson (Derived op deps) =
  "{\"kind\":\"compute\",\"op\":\""++op++"\",\"deps\":"++array (map show deps)++"}"
applyOp :: String -> [Int] -> Int
applyOp "sum" xs = sum xs
applyOp "max" xs = maximum xs
applyOp "product" xs = mod (product xs) 997
applyOp x _ = error ("unknown operator: "++x)
calculate :: [Cell] -> (Int,Int) -> [Int]
calculate nodes (a,b) = foldl' step [] (zip [0..] nodes)
 where
  step accum (0,Input _) = accum ++ [a]
  step accum (1,Input _) = accum ++ [b]
  step accum (_,Derived op deps) = accum ++ [applyOp op (map (accum !!) deps)]
  step _ _ = error "unexpected graph order"
snapshotJson :: [Int] -> [(Int,Int)] -> String
snapshotJson values events =
 "{\"values\":"++array (map show values)++",\"events\":"++
 array (map (uncurry pair) events)++"}"
calculateSnapshots :: [Cell] -> [(Int,Int)] -> [String]
calculateSnapshots nodes updates = reverse out
 where
  start = (inputValue (head nodes),inputValue (nodes !! 1))
  (_,_,out) = foldl' step (start,calculate nodes start,[]) updates
  inputValue (Input x) = x
  inputValue _ = error "not an input"
  step (current,previous,acc) (inputIx,value) =
   let state = if inputIx==0 then (value,snd current) else (fst current,value)
       next = calculate nodes state
       events = [(i,next !! i) | i <- [2..length nodes-1],previous !! i /= next !! i]
   in (state,next,snapshotJson next events:acc)
scenario :: Int -> (String,String)
scenario i = (caseJson,expectedJson)
 where
  a=mod (i*17) 73-36
  b=mod (i*23) 79-39
  ops=["sum","max","product"]
  op1=ops !! mod i 3
  op2=ops !! mod (i+1) 3
  op3=ops !! mod (i+2) 3
  nodes=[Input a,Input b,Derived op1 [0,1],Derived op2 [0,2],Derived op3 [2,3]]
  updates=[(mod j 2,mod (i*11+j*7) 71-35) | j<-[1..9]]
  caseJson="{\"cells\":"++array (map cellJson nodes)++",\"updates\":"++array (map (uncurry pair) updates)++"}"
  expectedJson=array (calculateSnapshots nodes updates)
main :: IO ()
main = do
 let scenarios=map scenario [1..180]
 putStrLn ("{\"cases\":"++array (map fst scenarios)++",\"expected\":"++array (map snd scenarios)++"}")
