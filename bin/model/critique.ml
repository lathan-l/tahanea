type t = {
  title : string;
  content : string;
  tags : string list;
  date : Yocaml.Datetime.t;
}

let compare a b = Yocaml.Datetime.compare a.date b.date
let make ?(tags = []) ~title ~date () = { title; tags; date; content = "" }

let normalize { title; content; tags; date } =
  let open Yocaml.Data in
  [
    ("title", string title);
    ("content", string content);
    ("tags", list_of string tags);
    ("date", Yocaml.Datetime.to_data date);
  ]

let to_data critique = Yocaml.Data.record (normalize critique)

let from_data =
  let open Yocaml.Data.Validation in
  record (fun fields ->
      let+ title = req fields "title" (string $ String.trim & String.not_blank)
      and+ tags =
        opt fields "tags" (list_of (string $ String.trim & String.not_blank))
      and+ date = req fields "date" Yocaml.Datetime.from_data in
      make ~title ?tags ~date ())

let validate = from_data
let entity_name = "critique"
let neutral = Yocaml.Metadata.required entity_name
