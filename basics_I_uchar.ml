open Notty

let () =
  I.uchar A.(fg lightred) (Uchar.of_int 0x2022) 4 4
  |> Notty_unix.eol |> Notty_unix.output_image
