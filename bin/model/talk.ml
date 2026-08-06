type t = {
  title : string;
  abstract : string;
  tags : string list;
  events : Event.t list;
}

let compare a b =
  let sortl = List.sort (fun a b -> Event.compare b a) in
  match (sortl a.events, sortl b.events) with
  | [], [] -> 0
  | [], _ -> 1
  | _, [] -> -1
  | x :: _, y :: _ -> Event.compare y x

let make ?(tags = []) ~title () = { title; tags; events = []; abstract = "" }

let to_data { title; abstract; tags; events } =
  let open Yocaml.Data in
  let events = List.sort (fun x y -> Event.compare y x) events in
  record
    [
      ("title", string title);
      ("abstract", string abstract);
      ("tags", list_of string tags);
      ("events", list_of Event.to_data events);
    ]

let from_data =
  let open Yocaml.Data.Validation in
  record (fun fields ->
      let+ title = req fields "title" (string $ String.trim & String.not_blank)
      and+ tags =
        opt fields "tags" (list_of (string $ String.trim & String.not_blank))
      in
      make ~title ?tags ())

module Def = struct
  type nonrec t = t

  let validate = from_data
  let entity_name = "talk definition"
  let neutral = Yocaml.Metadata.required entity_name
end

let fetch path =
  let open Yocaml.Eff in
  let on = `Source in
  let talk_path = Yocaml.Path.(path / "talk.md") in
  let* talk, abstract =
    Yocaml_yaml.Eff.read_file_with_metadata (module Def) ~on talk_path
  in
  let* events_path =
    read_directory ~on ~only:`Files
      ~where:(fun p -> not (Yocaml.Path.equal p talk_path))
      path
  in
  let* events =
    List.traverse
      (fun ep -> Yocaml_yaml.Eff.read_file_as_metadata ~on (module Event) ep)
      events_path
  in
  return
    {
      talk with
      abstract = Yocaml_markdown.from_string_to_html abstract;
      events;
    }

let fetch_all talks_dir () =
  let open Yocaml.Eff in
  let on = `Source in
  let* talk_path = read_directory ~on ~only:`Directories talks_dir in
  List.traverse fetch talk_path

let fetch_all talks_dir =
  let open Yocaml.Task in
  Yocaml.Pipeline.track_file talks_dir
  >>> from_effect ~has_dynamic_dependencies:false (fetch_all talks_dir)

module Listing = struct
  type nonrec t = { page : Yocaml.Archetype.Page.t; talks : t list }

  let normalize { page; talks } =
    let talks = List.sort compare talks in
    Yocaml.Data.("talks", list_of to_data talks)
    :: Yocaml.Archetype.Page.normalize page

  let make page talks = { page; talks }
end
