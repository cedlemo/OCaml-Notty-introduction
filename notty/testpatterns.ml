(**
 * A few images that exercise image composition, cropping, and padding. This
 * test is a good canary.
 *)
open Common

let () =
  Images.[i3; i5; checker1]
  |> List.iter Notty_unix.output_image_endline
