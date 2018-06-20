open Notty
open Notty_unix
(* ocamlbuild -pkg notty -pkg notty.unix basics_I_uchar.native *)
let () =
   I.uchar A.(fg lightred) (Uchar.of_int 0x2022) 4 4
   |> Notty_unix.eol
   |> Notty_unix.output_image

