open Notty
open Notty_unix

let square = "\xe2\x97\xbe"

let rec sierp n =
  if n > 1 then
    let ss = sierp (pred n) in I.(ss <-> (ss <|> ss))
  else I.(string A.(fg magenta) square |> hpad 1 0)

let img(double, n) =
  let s = sierp n in
  if double then
    I.(s </> (hpad 1 0 s))
  else
    s
  in
let rec update t state =
  Term.image t (img state); loop t state
and loop t (double, n as state) =
  match Term.event t with
  | `Key (`Enter,_)         -> ()
  | `Key (`Arrow `Left, _)  -> update t (double, max 1 (n - 1))
  | `Key (`Arrow `Right, _) -> update t (double, min 8 (n + 1))
  | `Key (`Uchar 0x20, _)   -> update t (not double, n)
  | `Resize _               -> update t state
  | _                       -> loop t state
in
let t = Term.create () in
update t (false, 1);
Term.release t
