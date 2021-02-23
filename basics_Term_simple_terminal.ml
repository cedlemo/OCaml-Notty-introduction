open Notty
open Notty_unix

let rec main_loop t =
  let img = I.(string A.(bg lightred ++ fg black) "This is a simple example") in
  Term.image t img;
  match Term.event t with
  | `End | `Key (`Escape, []) -> ()
  | `Key (`Uchar u, [ `Ctrl ]) when Uchar.to_int u = 67 -> ()
  | _ -> main_loop t

let () =
  let t = Term.create () in
  main_loop t
