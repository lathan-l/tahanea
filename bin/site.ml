open Yocaml

let cache_path = Path.rel [ ".cache" ]
let target_path = Path.rel [ ".target" ]
let articles = Path.rel [ "content"; "articles" ]
let templates_path = Path.rel [ "assets"; "templates" ]
let binary_path = Path.from_string Sys.executable_name

(* GitHub Pages serves a project site under /<repo>/, not /, so root-relative
   URLs such as "/style.css" 404 there. Every absolute URL is therefore built
   from [base_url], which the deploy workflow sets to "/tahanea/" and which
   stays "/" for the local dev server. *)
let base_url =
  match Sys.getenv_opt "SITE_BASE_URL" with
  | None | Some "" -> "/"
  | Some given ->
      let trimmed = String.trim given in
      let with_leading =
        if String.starts_with ~prefix:"/" trimmed then trimmed
        else "/" ^ trimmed
      in
      if String.ends_with ~suffix:"/" with_leading then with_leading
      else with_leading ^ "/"

let base_segments =
  base_url |> String.split_on_char '/' |> List.filter (fun s -> s <> "")

(* Adds [base_url] to the variables every template can see, on top of whatever
   the wrapped archetype already exposes. *)
module With_base (M : Required.DATA_INJECTABLE) :
  Required.DATA_INJECTABLE with type t = M.t = struct
  type t = M.t

  let normalize value = ("base_url", Data.string base_url) :: M.normalize value
end

module Page_with_base = With_base (Archetype.Page)
module Article_with_base = With_base (Archetype.Article)
module Articles_with_base = With_base (Archetype.Articles)

let copy_css =
  Batch.iter_files
    (Path.rel [ "assets"; "css" ])
    (fun source_path -> Action.copy_file ~into:target_path source_path)

let copy_images =
  let source_path = Path.rel [ "assets"; "img" ] in
  Action.copy_directory ~into:target_path source_path

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
    |> apply_templates ~metadata (module Page_with_base)
  in
  Action.Static.write_file target_page_path pipeline

let create_article source_path =
  let target_article_path =
    source_path
    |> Path.change_extension "html"
    |> Path.move ~into:Path.(target_path / "articles")
  in
  let pipeline =
    let open Task in
    let+ metadata, content =
      Pipeline.read_file_with_metadata
        (module Yocaml_yaml)
        (module Archetype.Article)
        source_path
    and+ () = Pipeline.track_file binary_path
    and+ apply_templates =
      Pipeline.read_templates
        (module Yocaml_jingoo)
        Path.[ templates_path / "page.html"; templates_path / "layout.html" ]
    in
    content |> Yocaml_markdown.from_string_to_html
    |> apply_templates ~metadata (module Article_with_base)
  in
  Action.Static.write_file target_article_path pipeline

let create_articles = Batch.iter_files articles create_article

let create_resume =
  let source_path = Path.rel [ "content"; "cv"; "resume.md" ] in
  let target_page_path = Path.rel [ ".target"; "resume.html" ] in
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
        Path.
          [
            templates_path / "resume.html";
            templates_path / "resume-layout.html";
          ]
    in
    content |> Yocaml_markdown.from_string_to_html
    |> apply_templates ~metadata (module Page_with_base)
  in
  Action.Static.write_file target_page_path pipeline

let compute_link source =
  let into = Path.abs (base_segments @ [ "articles" ]) in
  source |> Path.move ~into |> Path.change_extension "html"

let fetch_articles =
  Archetype.Articles.fetch
    ~where:(fun p -> Path.has_extension "md" p)
    ~compute_link
    (module Yocaml_yaml)
    (Path.rel [ "content"; "articles" ])

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
    and+ articles = fetch_articles in
    let metadata = Archetype.Articles.with_page ~page:metadata ~articles in
    content |> Yocaml_markdown.from_string_to_html
    |> apply_templates ~metadata (module Articles_with_base)
  in
  Action.Static.write_file target_page_path pipeline

let program () =
  let open Eff in
  Action.restore_cache cache_path
  >>= copy_css >>= copy_images >>= create_404 >>= create_articles
  >>= create_index >>= create_resume
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
