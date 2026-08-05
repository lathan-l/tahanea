type 'a raw = {
  title : string;
  abstract : string;
  tags : string list;
  events : 'a list;
}

let make ?(events = []) ?(tags = []) ~title ~abstract () =
  { title; abstract; tags; events }

let to_data on_event { title; abstract; tags; events } =
  let open Yocaml.Data in
  [
    ("title", string title);
    ("abstract", string abstract);
    ("tags", list_of string tags);
    ("events", list_of on_event events);
  ]

let from_data on_event =
  let open Yocaml.Data.Validation in
  record (fun fields ->
      let+ title = req fields "title" (string $ String.trim & String.not_blank)
      and+ abstract =
        req fields "abstract" (string $ String.trim & String.not_blank)
      and+ tags =
        opt fields "tags" (list_of (string $ String.trim & String.not_blank))
      and+ events = opt fields "events" (list_of on_event) in
      make ~title ~abstract ?tags ?events ())

module Ingredients = struct
  type t = Yocaml.Path.t raw

  let entity_name = "talk"
  let neutral = Yocaml.Metadata.required entity_name
  let validate = from_data Yocaml.Data.Validation.path
end

type t = Event.t raw

let normalize = to_data Event.to_data
