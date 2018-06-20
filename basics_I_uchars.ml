open Notty
open Notty_unix
(* ocamlbuild -pkg notty -pkg notty.unix basics_I_uchars.native *)
let () =
  let my_unicode_chars =
    [|0x2500; 0x2502; 0x2022; 0x2713; 0x25cf;
      0x256d; 0x256e; 0x256f; 0x2570; 0x253c|] in
   I.uchars A.(fg lightred) (Array.map Uchar.of_int my_unicode_chars)
   |> Notty_unix.eol
   |> Notty_unix.output_image

