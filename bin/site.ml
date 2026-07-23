open Yocaml

let cache_path = Path.rel [ ".cache" ]
let target_path = Path.rel [ ".target" ]
let templates_path = Path.rel [ "assets"; "templates" ]
let binary_path = Path.from_string Sys.executable_name

let copy_css =
  let source_path = Path.rel [ "assets"; "css"; "style.css" ] in
  Action.copy_file ~into:target_path source_path

let copy_images =
  let source_path = Path.rel [ "assets"; "img" ] in
  Action.copy_directory ~into:target_path source_path

let create_page source_path =
  let target_page_path =
    source_path |> Path.change_extension "html" |> Path.move ~into:target_path
  in
  let pipeline =
    let open Task in
    let+ metadata, content =
      Pipeline.read_file_with_metadata
        (module Yocaml_yaml)
        (module Archetype.Page)
        source_path
    and+ () = Pipeline.track_file binary_path
    and+ apply_templates =
      Pipeline.read_templates
        (module Yocaml_jingoo)
        Path.[ templates_path / "page.html"; templates_path / "layout.html" ]
    in
    content |> Yocaml_markdown.from_string_to_html
    |> apply_templates ~metadata (module Archetype.Page)
  in
  Action.Static.write_file target_page_path pipeline

let create_pages =
  Batch.iter_files (Path.rel [ "content"; "pages" ]) create_page

let create_404 =
  let source_path = Path.rel [ "content"; "404.md" ] in
  let target_page_path = Path.rel [ ".target"; "404.html" ] in
  let pipeline =
    let open Task in
    let+ metadata, content =
      Pipeline.read_file_with_metadata
        (module Yocaml_yaml)
        (module Archetype.Page)
        source_path
    and+ () = Pipeline.track_file binary_path
    and+ apply_templates =
      Pipeline.read_templates
        (module Yocaml_jingoo)
        Path.[ templates_path / "404tpl.html"; templates_path / "layout.html" ]
    in
    content |> Yocaml_markdown.from_string_to_html
    |> apply_templates ~metadata (module Archetype.Page)
  in
  Action.Static.write_file target_page_path pipeline

let create_index =
  let source_path = Path.rel [ "content"; "index.md" ] in
  let target_page_path = Path.rel [ ".target"; "index.html" ] in
  let pipeline =
    let open Task in
    let+ metadata, content =
      Pipeline.read_file_with_metadata
        (module Yocaml_yaml)
        (module Archetype.Page)
        source_path
    and+ () = Pipeline.track_file binary_path
    and+ apply_templates =
      Pipeline.read_templates
        (module Yocaml_jingoo)
        Path.[ templates_path / "index.html"; templates_path / "layout.html" ]
    in
    content |> Yocaml_markdown.from_string_to_html
    |> apply_templates ~metadata (module Archetype.Page)
  in
  Action.Static.write_file target_page_path pipeline

let program () =
  let open Eff in
  Action.restore_cache cache_path
  >>= copy_css >>= copy_images >>= create_404 >>= create_pages >>= create_index
  >>= Action.store_cache cache_path

let () =
  match
    Array.find_mapi
      (fun i element -> if i = 1 then Some element else None)
      Sys.argv
  with
  | Some "watch" ->
      Yocaml_unix.serve ~target:target_path ~port:8888 ~level:`Debug program
  | _ -> Yocaml_unix.run ~level:`Debug program
