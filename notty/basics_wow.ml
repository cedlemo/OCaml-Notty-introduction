open Notty
open Notty_unix

let () =
let wow = I.string A.(fg lightred) "Wow!" in
I.(wow <-> (void 2 0 <|> wow)) |> Notty_unix.output_image_endline

