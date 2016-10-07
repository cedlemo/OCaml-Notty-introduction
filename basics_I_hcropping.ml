open Notty
open Notty_unix

(* ocamlfind ocamlc -o basics_cropping -package notty,notty.unix  -linkpkg -g basics_I_cropping.ml *)
let long_line_str = "This is a line that will be cropped 2 unit left and 5 unit right"

let () =
  let long_line = I.string A.(fg lightgreen ++ bg black) long_line_str in
  let long_line_cropped = I.hcrop 2 5 long_line in
  I.(long_line <-> long_line_cropped) |> Notty_unix.output_image_endline
