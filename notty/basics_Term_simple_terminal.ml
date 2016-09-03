open Notty
open Notty_unix
open Common
(* ocamlbuild -pkg notty -pkg notty.unix basics_Term_simple_terminal_size.native *)
let rec main_loop t =
  let img = I.(string A.(bg lightred ++ fg black) "This is a simple example") in
    Term.image t img;
    match Term.event t with
    | `End | `Key (`Escape, []) | `Key (`Uchar 67, [`Ctrl]) -> ()
    | `Resize _ -> main_loop t
    | _ -> main_loop t

let () =
  let t = Term.create () in main_loop t
