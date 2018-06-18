open Notty
open Notty_unix
(* ocamlbuild -pkg notty -pkg notty.unix basics_I_string.native *)
let () =
I.string A.(fg lightred) "Wow!"
|> eol
|> Notty_unix.output_image
