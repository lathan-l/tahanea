open Yocaml
(*module Talk = Model.Talk*)

let cache_path = Path.rel [ ".cache" ]
let target_path = Path.rel [ ".target" ]
let articles = Path.rel [ "content"; "articles" ]
let templates_path = Path.rel [ "assets"; "templates" ]
let binary_path = Path.from_string Sys.executable_name

(* The site is served at the root of its own domain (www.tahanea.net, see the
   CNAME file), so absolute URLs are plain root-relative paths: "/style.css",
   "/articles/…". The local dev server also serves the target at /, so nothing
   needs rewriting between the two. *)

(* GitHub Pages reads the custom domain from a CNAME file in the *published*
   tree, and the deploy replaces that tree wholesale, so CNAME has to be part
   of the build output or the domain gets dropped on the next push. *)
let copy_cname = Action.copy_file ~into:target_path (Path.rel [ "CNAME" ])

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
    |> apply_templates ~metadata (module Archetype.Page)
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
    |> apply_templates ~metadata (module Archetype.Article)
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
    |> apply_templates ~metadata (module Archetype.Page)
  in
  Action.Static.write_file target_page_path pipeline

let compute_link source =
  let into = Path.abs [ "articles" ] in
  source |> Path.move ~into |> Path.change_extension "html"

let fetch_articles =
  Archetype.Articles.fetch
    ~where:(fun p -> Path.has_extension "md" p)
    ~compute_link
    (module Yocaml_yaml)
    (Path.rel [ "content"; "articles" ])

let create_articles_index =
  let source_path = Path.rel [ "content"; "articles.md" ] in
  let target_page_path = Path.rel [ ".target"; "articles.html" ] in
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
            templates_path / "articles_index.html";
            templates_path / "layout.html";
          ]
    and+ articles = fetch_articles in
    let metadata = Archetype.Articles.with_page ~page:metadata ~articles in
    content |> Yocaml_markdown.from_string_to_html
    |> apply_templates ~metadata (module Archetype.Articles)
  in
  Action.Static.write_file target_page_path pipeline

let create_talks_index =
  let source_path = Path.rel [ "content"; "talks.md" ] in
  let target_page_path = Path.rel [ ".target"; "talks.html" ] in
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
            templates_path / "talks_index.html"; templates_path / "layout.html";
          ]
    and+ articles = fetch_articles in
    let metadata = Archetype.Articles.with_page ~page:metadata ~articles in
    content |> Yocaml_markdown.from_string_to_html
    |> apply_templates ~metadata (module Archetype.Articles)
  in
  Action.Static.write_file target_page_path pipeline

let create_mysterious_links =
  let source_path = Path.rel [ "content"; "mysterious_links.md" ] in
  let target_page_path = Path.rel [ ".target"; "mysterious_links.html" ] in
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
            templates_path / "mysterious_links.html";
            templates_path / "layout.html";
          ]
    and+ articles = fetch_articles in
    let metadata = Archetype.Articles.with_page ~page:metadata ~articles in
    content |> Yocaml_markdown.from_string_to_html
    |> apply_templates ~metadata (module Archetype.Articles)
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
    and+ articles = fetch_articles in
    let metadata = Archetype.Articles.with_page ~page:metadata ~articles in
    content |> Yocaml_markdown.from_string_to_html
    |> apply_templates ~metadata (module Archetype.Articles)
  in
  Action.Static.write_file target_page_path pipeline

let program () =
  let open Eff in
  Action.restore_cache cache_path
  >>= copy_cname >>= copy_css >>= copy_images >>= create_404 >>= create_articles
  >>= create_articles_index >>= create_talks_index >>= create_mysterious_links
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
