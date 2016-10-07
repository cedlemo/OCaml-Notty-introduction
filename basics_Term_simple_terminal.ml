open Notty
open Notty_unix

(* ocamlbuild -pkg notty -pkg notty.unix basics_Term_simple_terminal.native
 * or
 * ocamlfind ocamlc -o basics_simple_terminal -package notty,notty.unix -linkpkg -g basics_Term_simple_terminal.ml*)
let rec main_loop t =
  let img = I.(string A.(bg lightred ++ fg black) "This is a simple example") in
    Term.image t img;
    match Term.event t with
    | `End | `Key (`Escape, []) | `Key (`Uchar 67, [`Ctrl]) -> ()
    | _ -> main_loop t

let () =
  let t = Term.create () in main_loop t
