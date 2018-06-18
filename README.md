# Ocaml Notty library

* [Introduction](#introduction)
* [Basics](#basics)
  * [Image](#image)
  * [The Image module](#the-image-module)
    * [Image Creation](#image-creation)
    * [Image Composition](#image-composition)
    * [Image Modification](#image-modification)
      * [Cropping Image](#cropping-image)
        * [Horizontal cropping](#horizontal-cropping)
	* [Vertical cropping](#vertical-cropping)
      * [Padding](#padding)
        * [Negative cropping](#negative-cropping)
	* [Padding functions](#padding-functions)
  * [The Notty_unix.Term module](#the-unix-term-module)
  * [The Notty_lwt.Term module](#the-lwt-term-module)

## Introduction

Better than curses/ncurses, here is Notty. Written in OCaml, this library
is based on the notion of composable images.

  * [Notty on Github](https://github.com/pqwy/notty)
  * [documentation](https://pqwy.github.io/notty/Notty.html)

## Basics

### Image

An image is a rectangle displayed in the terminal that contains styled characters.
An image can be:
  * a single character with display attributes,
  * or some text with display attributes,
  * or a combinaison of both beside, above or over each other.

After its construction, the image can be rendered. Basically, it is tranformed
to a string we can display.

Print a red "Wow!" above its right-shifted copy:

```ocaml
open Notty
open Notty_unix

(* build with
 * ocamlbuild -pkg notty -pkg notty.unix basics_wow.native
 *)
let () =
	let wow = I.string A.(fg lightred) "Wow!" in
	I.(wow <-> (void 2 0 <|> wow)) |> Notty_unix.output_image_endline
```

In this program we create an image that is based on a string "Wow!" with some
attributes `A.(fg lightred)`. Then we compose a bigger image and display twice
the `wow` image at different position. The function `Notty_unix.output_image_endline`
allow us to display the generated image.

### The Image module

https://pqwy.github.io/notty/Notty.I.html

#### Image Creation

Basics images can be created with :

*  `I.string` : require an attribute (style) and a string
*  `I.uchars` : require an attribute and an array of unicode value
*  `I.char`   : require an attribute, a char and 2 int for the width and the height of the grid.
*  `I.uchar`  : same as `I.char` but for unicode value.

or 2 specials primitives:

*  `I.empty`  : which is a zero sized image.
*  `I.void`   : require a width and an height, it is a transparent image.

##### I.string basic example

```ocaml
open Notty
open Notty_unix
(* ocamlbuild -pkg notty -pkg notty.unix basics_I_string.native *)
let () =
 I.string A.(fg lightred) "Wow!" |> Notty_unix.output_image_endline
```

##### I.uchars basic example

```ocaml
open Notty
open Notty_unix
(* ocamlbuild -pkg notty -pkg notty.unix basics_I_uchars.native *)
let () =
  let my_unicode_chars = [|0x2500; 0x2502; 0x2022; 0x2713; 0x25cf; 0x256d;
                          0x256e; 0x256f; 0x2570; 0x253c|] in
   I.uchars A.(fg lightred) my_unicode_chars |> Notty_unix.output_image_endline
```

##### I.char basic example

```ocaml
open Notty
open Notty_unix
(* ocamlbuild -pkg notty -pkg notty.unix basics_I_char.native *)
let () =
   I.char A.(fg lightred) 'o' 4 4 |> Notty_unix.output_image_endline

```

##### I.uchar basic example

```ocaml
open Notty
open Notty_unix
(* ocamlbuild -pkg notty -pkg notty.unix basics_I_uchar.native *)
let () =
   I.uchar A.(fg lightred) 0x2022 4 4 |> Notty_unix.output_image_endline
```

#### Image composition

There are 3 composition modes which allow you to blend simple images into
complexe ones.

*  `I.(<|>)` : puts one image after another
*  `I.(<->)` : puts one image below another
*  `I.(</>)` : puts one image on another.

##### Side by side images

```ocaml
open Notty
open Notty_unix

(* ocamlbuild -pkg notty -pkg notty.unix basic_I_side_by_side *)
let () =
  let bar = I.uchar A.(fg lightred) 0x2502 3 1 in
  let img1 = I.string A.(fg lightgreen) "image1" in
  I.(img1 <|> bar) |> Notty_unix.output_image_endline
```

##### Image above another

```ocaml
open Notty
open Notty_unix

(* ocamlbuild -pkg notty -pkg notty.unix basics_I_above_another.native *)
let () =
  let bar = I.uchar A.(fg lightred) (Uchar.of_int 0x2502) 3 1 in
  let img1 = I.string A.(fg lightgreen) "image1" in
  I.(img1 <-> bar) |> Notty_unix.eol |> Notty_unix.output_image
```

##### Image overlay

```ocaml
open Notty
open Notty_unix

(* ocamlbuild -pkg notty -pkg notty.unix basic_I_overlay.native *)
let () =
  let bar = I.uchar A.(fg lightred) 0x2502 3 1 in
  let img1 = I.string A.(fg lightgreen) "image1" in
  I.(img1 </> bar) |> Notty_unix.output_image_endline
```

#### Image modifications

Basic notty images can be modified by cropping them or by adding them padding.

#### Cropping image

*  `I.hcrop`
*  `I.vcrop`
*  `I.crop`


##### Horizontal cropping:

```ocaml
open Notty
open Notty_unix

(* ocamlfind ocamlc -o basics_hcropping -package notty,notty.unix  -linkpkg -g basics_I_hcropping.ml *)
let long_line_str = "This is a line that will be cropped 2 unit left and 5 unit right"

let () =
  let long_line = I.string A.(fg lightgreen ++ bg black) long_line_str in
  let long_line_cropped = I.hcrop 2 5 long_line in
  I.(long_line <-> long_line_cropped) |> Notty_unix.output_image_endline
```

##### Vertical cropping:

```ocaml
open Notty
open Notty_unix

(* ocamlfind ocamlc -o basics_vcropping -package notty,notty.unix  -linkpkg -g basics_I_vcropping.ml *)
let line_str num =
  "line number " ^ (string_of_int num)

let build_5_lines () =
  let rec _build img remain =
    if remain = 0 then img
    else let str = line_str (6 - remain) in
    _build I.(img <-> string A.(fg lightgreen ++ bg black) str) (remain - 1)
  in _build (I.string A.(fg lightgreen ++ bg black) (line_str 1)) 4

let description =
  I.string A.(fg lightyellow ++ bg lightblack) "crop 2 at top and 1 at bottom"

let () =
   I.(build_5_lines () <->
   description <->
   vcrop 2 1 (build_5_lines ())) |> Notty_unix.output_image_endline
```
#### Padding

##### Negative cropping

```ocaml
open Notty
open Notty_unix

(* ocamlfind ocamlc -o basics_negative_vcropping -package notty,notty.unix  -linkpkg -g basics_I_negative_vcropping.ml *)
let line_str num =
  "line number " ^ (string_of_int num)

let build_5_lines () =
  let rec _build img remain =
    if remain = 0 then img
    else let str = line_str (6 - remain) in
    _build I.(img <-> string A.(fg lightgreen ++ bg black) str) (remain - 1)
  in _build (I.string A.(fg lightgreen ++ bg black) (line_str 1)) 4

let description =
  I.string A.(fg lightyellow ++ bg lightblack) "Negative crop -2 at top and -1 at bottom"

let () =
   I.(build_5_lines () <->
   description <->
   vcrop (-2) (-1) (build_5_lines ())) |> Notty_unix.output_image_endline
```
The same applies to `I.hcrop`.

##### Padding functions

*  `I.hpad`
*  `I.vpad`
*  `I.pad`

```ocaml
open Notty
open Notty_unix

(* ocamlfind ocamlc -o basics_padding -package notty,notty.unix  -linkpkg -g basics_I_padding.ml *)
let line_str num =
  "line number " ^ (string_of_int num)

let build_5_lines () =
  let rec _build img remain =
    if remain = 0 then img
    else let str = line_str (6 - remain) in
    _build I.(img <-> string A.(fg lightgreen ++ bg black) str) (remain - 1)
  in _build (I.string A.(fg lightgreen ++ bg black) (line_str 1)) 4

let description =
  I.string A.(fg lightyellow ++ bg lightblack) "Padding left = 2, right = 3, top = 4 and 1 at bottom"

let () =
   I.(build_5_lines () <->
   description <->
   pad ~l:2 ~r:3 ~t:4 ~b:1 (build_5_lines ())) |> Notty_unix.output_image_endline
```

### The Unix Term module

*  http://pqwy.github.io/notty/Notty_unix.Term.html

It is an helper for fullscreen, interactive applications.

#### Simple interactive fullscreen

```ocaml
open Notty
open Notty_unix

(* ocamlbuild -pkg notty -pkg notty.unix basics_Term_simple_terminal.native
 * or
 * ocamlfind ocamlc -o basics_simple_terminal -package notty,notty.unix -linkpkg -g basics_Term_simple_terminal.ml*)

let rec main_loop t =
  let img = I.(string A.(bg lightred ++ fg black) "This is a simple example") in
    Term.image t img;
    match Term.event t with
    | `End | `Key (`Escape, []) | `Key (`Uchar 67, [`Ctrl]) -> ()
    | _ -> main_loop t

let () =
  let t = Term.create () in main_loop t
```

This little programm just draw in all the terminal, add a string and wait for
key events. Press "Esc" and the program exits.

#### Handling the terminal size and the resize events.

```ocaml
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
```

*  The grid function takes a list of list of images and compose a bigger image.
*  The outline function draws a line at the border of the screen.
*  The attr argument allows to configure the style of the line.

### The Lwt Term module

*  https://pqwy.github.io/notty/Notty_lwt.html
*  https://ocsigen.org/lwt/3.0.0/manual/

#### Handling the terminal size and the resize events.

The same example but inside a light-weight cooperative thread.

```ocaml
open Notty
open Notty_lwt
open Lwt

(* ocamlfind ocamlc -o simple_lwt_terminal_resize -package notty.lwt -linkpkg -g common.ml basics_Lwt_Term_simple_terminal_resize.ml*)


module LwtTerm = Notty_lwt.Term

let grid xxs = xxs |> List.map I.hcat |> I.vcat

let outline attr t =
  let (w, h) = LwtTerm.size t in
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
  LwtTerm.image t img
  >>= fun () ->
    LwtTerm.cursor t (Some pos)
    >>= fun () ->
      Lwt_stream.get ( LwtTerm.events t)
      >>= fun event ->
      match event with
      | None -> LwtTerm.release t >>= fun () -> Lwt.return_unit
      | Some (`Resize _ | #Unescape.event as x) -> match x with
        | `Key (`Escape, []) | `Key (`Uchar 67, [`Ctrl]) -> LwtTerm.release t >>= fun () -> Lwt.return_unit
        | `Resize (cols, rows) -> main t (cols, rows)
        | _ ->Lwt.return () >>= fun () -> main t pos

let () =
  let t = LwtTerm.create () in
  let size = LwtTerm.size t in
  Lwt_main.run @@ main t size
```

#### Update a terminal interface with a timeout.

The following example illustrate how to :
* create of a Notty.term that is updated with a timeout
* use an Notty.term with another thread, one for the interface and one for
another loop.

It is a very simple terminal application that displays a counter. The user can
leave it with `Esc`.

```ocaml
(* ocamlfind ocamlc -o basics_Lwt_Term_simple_terminal_timeout -package lwt,notty.lwt -linkpkg -g basics_Lwt_Term_simple_terminal_timeout.ml *)
open Lwt
open Lwt.Infix
open Notty
open Notty_lwt
open Notty.Infix

module Term = Notty_lwt.Term

let counter = ref 0

let rec increase_counter () =
  Lwt_unix.sleep 0.1
  >>= fun () ->
    (
    if !counter < max_int then counter := (!counter + 1)
    else counter := 0
  );
  Lwt.return ()
  >>= fun () ->
    increase_counter ()

let render (w, h) =
  I.(strf ~attr:A.(fg lightblack) "[counter %d]" !counter)

let timer () = Lwt_unix.sleep 0.1 >|= fun () -> `Timer

let event term = Lwt_stream.get (Term.events term) >|= function
  | Some (`Resize _ | #Unescape.event as x) -> x
  | None -> `End

let rec loop term (e, t) dim =
  (e <?> t) >>= function
  | `End | `Key (`Escape, []) ->
      Lwt.return_unit
  | `Timer ->
      Term.image term (render dim)
      >>= fun () ->
        loop term (e, timer ()) dim
  | `Mouse ((`Press _|`Drag), (x, y), _) ->
      loop term (event term, t) dim
  | `Resize dim ->
      Term.image term (render dim)
      >>= fun () ->
        loop term (event term, t) dim
  | _ -> loop term (event term, t) dim

let interface () =
  let tc = Unix.(tcgetattr stdin) in
  Unix.(tcsetattr stdin TCSANOW { tc with c_isig = false });
  let term    = Term.create () in
  let size = Term.size term in
  loop term (event term, timer ()) size

let main () =
  Lwt.choose [
    increase_counter ();
    interface ();
  ]

let () = Lwt_main.run (main ())
```
