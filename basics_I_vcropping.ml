open Notty
open Notty_unix

(* ocamlfind ocamlc -o basics_vcropping -package notty,notty.unix  -linkpkg -g basics_I_vcropping.ml *)
let line_str num =
  "line number " ^ (string_of_int num)

let build_5_lines () =
  let rec _build img remain =
    if remain = 0 then img
    else let str = line_str (6 - remain) in
    _build I.(img <-> string A.(fg lightgreen ++ bg black) str) (remain - 1)
  in _build (I.string A.(fg lightgreen ++ bg black) (line_str 1)) 4

let description =
  I.string A.(fg lightyellow ++ bg lightblack) "crop 2 at top and 1 at bottom"

let () =
   I.(build_5_lines () <->
   description <->
   vcrop 2 1 (build_5_lines ())) |> Notty_unix.output_image_endline
