open Lwt.Infix
open Notty
module Term = Notty_lwt.Term

let counter = ref 0

let rec increase_counter () =
  Lwt_unix.sleep 0.1 >>= fun () ->
  if !counter < max_int then counter := !counter + 1 else counter := 0;
  Lwt.return () >>= fun () -> increase_counter ()

let render (_, _) = I.(strf ~attr:A.(fg lightblack) "[counter %d]" !counter)

let timer () = Lwt_unix.sleep 0.1 >|= fun () -> `Timer

let event term =
  Lwt_stream.get (Term.events term) >|= function
  | Some ((`Resize _ | #Unescape.event) as x) -> x
  | None -> `End

let rec loop term (e, t) dim =
  e <?> t >>= function
  | `End | `Key (`Escape, []) -> Lwt.return_unit
  | `Timer ->
      Term.image term (render dim) >>= fun () -> loop term (e, timer ()) dim
  | `Mouse ((`Press _ | `Drag), (_, _), _) -> loop term (event term, t) dim
  | `Resize dim ->
      Term.image term (render dim) >>= fun () -> loop term (event term, t) dim
  | _ -> loop term (event term, t) dim

let interface () =
  let tc = Unix.(tcgetattr stdin) in
  Unix.(tcsetattr stdin TCSANOW { tc with c_isig = false });
  let term = Term.create () in
  let size = Term.size term in
  loop term (event term, timer ()) size

let main () = Lwt.choose [ increase_counter (); interface () ]

let () = Lwt_main.run (main ())
