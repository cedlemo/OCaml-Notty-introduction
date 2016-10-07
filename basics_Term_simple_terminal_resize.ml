open Notty
open Notty_unix

(* ocamlbuild -pkg notty -pkg notty.unix basics_Term_simple_terminal_resize.native
 * or
 * ocamlfind ocamlc -o simple_terminal_resize -package notty.unix  -linkpkg -g common.ml basics_Term_simple_terminal_resize.ml*)

let grid xxs = xxs |> List.map I.hcat |> I.vcat

let outline attr t =
  let (w, h) = Term.size t in
  let chr x = I.uchar attr x 1 1
  and hbar  = I.uchar attr 0x2500 (w - 2) 1
  and vbar  = I.uchar attr 0x2502 1 (h - 2) in
  let (a, b, c, d) = (chr 0x256d, chr 0x256e, chr 0x256f, chr 0x2570) in
  grid [ [a; hbar; b]; [vbar; I.void (w - 2) 1; vbar]; [d; hbar; c] ]

let size_box cols rows =
  let cols_str = string_of_int cols in let rows_str = string_of_int rows in
  let label = (cols_str ^ "x" ^ rows_str) in
  let box = I.string A.(fg lightgreen ++ bg lightblack) label in
  let top_margin = (rows - I.height box) / 2 in
  let left_margin = (cols - I.width box) / 2 in
  I.pad ~t:top_margin ~l:left_margin box

let rec main t (x, y as pos) =
  let img = I.((outline A.(fg lightred ) t) </> (size_box x y)) in
  Term.image t img;
  Term.cursor t (Some pos);
  match Term.event t with
  | `End | `Key (`Escape, []) | `Key (`Uchar 67, [`Ctrl]) -> ()
  | `Resize (cols, rows) -> main t (cols, rows)
  | _ -> main t pos

let () =
  let t = Term.create () in
  main t (Term.size t)
