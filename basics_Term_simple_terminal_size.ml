open Notty
open Notty_unix
open Common

(* ocamlbuild -pkg notty -pkg notty.unix basics_Term_simple_terminal_size.native
 * or
 * ocamlfind ocamlc -o simple_terminal -package notty.unix  -linkpkg -g common.ml basics_Term_simple_terminal_size.ml*)

let grid xxs = xxs |> List.map I.hcat |> I.vcat

let outline attr t =
  let (w, h) = Term.size t in
  let chr x = I.uchar attr x 1 1
  and hbar  = I.uchar attr 0x2500 (w - 2) 1
  and vbar  = I.uchar attr 0x2502 1 (h - 2) in
  let (a, b, c, d) = (chr 0x256d, chr 0x256e, chr 0x256f, chr 0x2570) in
  grid [ [a; hbar; b]; [vbar; I.void (w - 2) 1; vbar]; [d; hbar; c] ]

let rec main t (x, y as pos) =
  let img = outline A.(fg lightred ) t in
  Term.image t img;
  Term.cursor t (Some pos);
  match Term.event t with
  | `End | `Key (`Escape, []) | `Key (`Uchar 67, [`Ctrl]) -> ()
  | `Resize _ -> main t pos
  | _ -> main t pos

let () =
  let t = Term.create () in
  main t (0, 1)
