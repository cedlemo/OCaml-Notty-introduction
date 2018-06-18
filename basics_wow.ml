open Notty
open Notty_unix

(*
 * ocamlbuild -pkg notty -pkg notty.unix basics_wow.native
 *)
let () =
let wow = I.string A.(fg lightred) "Wow!" in
I.(wow <-> (void 2 0 <|> wow))
|> Notty_unix.eol
|> Notty_unix.output_image
