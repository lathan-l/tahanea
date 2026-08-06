type t = {
  organization : string;
  name : string;
  date : Yocaml.Datetime.t;
  slides : string option;
}

let to_data { organization; name; date; slides } =
  let open Yocaml.Data in
  record
    [
      ("organization", string organization);
      ("name", string name);
      ("date", Yocaml.Datetime.to_data date);
      ("slides", option string slides);
      ("has_slides", bool (Option.is_some slides));
    ]

let from_data =
  let open Yocaml.Data.Validation in
  record (fun fields ->
      let+ organization =
        req fields "organization" (string $ String.trim & String.not_blank)
      and+ name = req fields "name" (string $ String.trim & String.not_blank)
      and+ date = req fields "date" Yocaml.Datetime.from_data
      and+ slides =
        opt fields "slides" (string $ String.trim & String.not_blank)
      in
      { organization; name; date; slides })

let validate = from_data
let entity_name = "event"
let neutral = Yocaml.Metadata.required entity_name
let compare a b = Yocaml.Datetime.compare a.date b.date
