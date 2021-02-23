open Notty
open Lwt

(* ocamlfind ocamlc -o simple_lwt_terminal_resize -package notty.lwt -linkpkg -g common.ml basics_Lwt_Term_simple_terminal_resize.ml*)

module LwtTerm = Notty_lwt.Term

let grid xxs = xxs |> List.map I.hcat |> I.vcat

let outline attr t =
  let w, h = LwtTerm.size t in
  let chr x = I.uchar attr x 1 1
  and hbar = I.uchar attr (Uchar.of_int 0x2500) (w - 2) 1
  and vbar = I.uchar attr (Uchar.of_int 0x2502) 1 (h - 2) in
  let a, b, c, d =
    ( chr (Uchar.of_int 0x256d),
      chr (Uchar.of_int 0x256e),
      chr (Uchar.of_int 0x256f),
      chr (Uchar.of_int 0x2570) )
  in
  grid [ [ a; hbar; b ]; [ vbar; I.void (w - 2) 1; vbar ]; [ d; hbar; c ] ]

let size_box cols rows =
  let cols_str = string_of_int cols in
  let rows_str = string_of_int rows in
  let label = cols_str ^ "x" ^ rows_str in
  let box = I.string A.(fg lightgreen ++ bg lightblack) label in
  let top_margin = (rows - I.height box) / 2 in
  let left_margin = (cols - I.width box) / 2 in
  I.pad ~t:top_margin ~l:left_margin box

let rec main t ((x, y) as pos) =
  let img = I.(outline A.(fg lightred) t </> size_box x y) in
  LwtTerm.image t img >>= fun () ->
  LwtTerm.cursor t (Some pos) >>= fun () ->
  Lwt_stream.get (LwtTerm.events t) >>= fun event ->
  match event with
  | None -> LwtTerm.release t >>= fun () -> Lwt.return_unit
  | Some ((`Resize _ | #Unescape.event) as x) -> (
      match x with
      | `Key (`Escape, []) -> LwtTerm.release t
      | `Key (`Uchar u, [ `Ctrl ]) when Uchar.to_int u = 67 -> LwtTerm.release t
      | `Resize (cols, rows) -> main t (cols, rows)
      | _ -> Lwt.return () >>= fun () -> main t pos )

let () =
  let t = LwtTerm.create () in
  let size = LwtTerm.size t in
  Lwt_main.run @@ main t size
