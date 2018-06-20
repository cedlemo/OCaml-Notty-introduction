open Notty
open Notty_unix
(* ocamlbuild -pkg notty -pkg notty.unix basics_I_char.native *)
let () =
   I.char A.(fg lightred) 'o' 4 4
   |> Notty_unix.eol
   |> Notty_unix.output_image

