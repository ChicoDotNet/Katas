(* SPDX-License-Identifier: MIT *)
(* Generate an expected typed AST first, then serialize SGF independently. *)
type node = { a:string; b:string option; children:node list }
let alphabet = "abcXY 19]\\"
let value () =
  let len = Random.int 8 in
  String.init len (fun _ -> alphabet.[Random.int (String.length alphabet)])
let rec generate depth =
  let kids = if depth < 3 && Random.int 3 = 0 then
    [generate (depth+1);generate (depth+1)] else [] in
  {a=value();b=(if Random.bool() then Some(value()) else None);children=kids}
let sgf_escape s =
  let out = Buffer.create (String.length s) in
  String.iter (fun c -> if c = ']' || c = '\\' then Buffer.add_char out '\\';
                         Buffer.add_char out c) s;
  Buffer.contents out
let rec to_sgf n =
  "(;A[" ^ sgf_escape n.a ^ "]" ^
  (match n.b with Some v -> "B[" ^ sgf_escape v ^ "]" | None -> "") ^
  String.concat "" (List.map to_sgf n.children) ^ ")"
let json_escape s =
  let b=Buffer.create (String.length s + 8) in
  Buffer.add_char b '"';
  String.iter (function
    | '"' -> Buffer.add_string b "\\\""
    | '\\' -> Buffer.add_string b "\\\\"
    | '\n' -> Buffer.add_string b "\\n"
    | '\r' -> Buffer.add_string b "\\r"
    | '\t' -> Buffer.add_string b "\\t"
    | c -> Buffer.add_char b c) s;
  Buffer.add_char b '"';Buffer.contents b
let rec to_json n =
  "{\"properties\":{\"A\":[" ^ json_escape n.a ^ "]" ^
  (match n.b with Some v -> ",\"B\":[" ^ json_escape v ^ "]" | None -> "") ^
  "},\"children\":[" ^ String.concat "," (List.map to_json n.children) ^ "]}"
let () =
  Random.init 20261017;
  let cases=List.init 180 (fun _ -> generate 0) in
  print_string "{\"sgf\":[";
  print_string (String.concat "," (List.map (fun n -> json_escape (to_sgf n)) cases));
  print_string "],\"expected\":[";
  print_string (String.concat "," (List.map (fun n -> "{\"ok\":true,\"root\":" ^ to_json n ^ "}") cases));
  print_endline "]}"
