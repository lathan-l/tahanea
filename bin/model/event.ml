type t = {
  organization : string;
  organization_website : string option;
  name : string;
  date : Yocaml.Datetime.t;
  slides : string option;
  video : string option;
  image : string option;
  feedbacks : string option;
  tags : string list;
}

let to_data
    {
      organization;
      organization_website;
      name;
      date;
      slides;
      video;
      image;
      feedbacks;
      tags;
    } =
  let open Yocaml.Data in
  record
    [
      ("organization", string organization);
      ("organization_website", option string organization_website);
      ("has_organization_website", bool (Option.is_some organization_website));
      ("name", string name);
      ("date", Yocaml.Datetime.to_data date);
      ("slides", option string slides);
      ("has_slides", bool (Option.is_some slides));
      ("video", option string video);
      ("has_video", bool (Option.is_some video));
      ("image", option string image);
      ("has_image", bool (Option.is_some image));
      ("feedbacks", option string feedbacks);
      ("has_feedbacks", bool (Option.is_some feedbacks));
      ("tags", list_of string tags);
      ("has_tags", bool (List.length tags > 0));
    ]

let make ?(tags = []) ?organization_website ~organization ~name ~date ?slides
    ?video ?image ?feedbacks () =
  {
    organization;
    organization_website;
    name;
    date;
    slides;
    video;
    image;
    feedbacks;
    tags;
  }

let from_data =
  let open Yocaml.Data.Validation in
  record (fun fields ->
      let+ organization =
        req fields "organization" (string $ String.trim & String.not_blank)
      and+ name = req fields "name" (string $ String.trim & String.not_blank)
      and+ date = req fields "date" Yocaml.Datetime.from_data
      and+ slides = opt fields "slides" (string $ String.trim & String.not_blank)
      and+ organization_website =
        opt fields "organization_website"
          (string $ String.trim & String.not_blank)
      and+ video = opt fields "video" (string $ String.trim & String.not_blank)
      and+ image = opt fields "image" (string $ String.trim & String.not_blank)
      and+ tags =
        opt fields "tags" (list_of (string $ String.trim & String.not_blank))
      and+ feedbacks =
        opt fields "feedbacks" (string $ String.trim & String.not_blank)
      in
      make ~organization ?organization_website ~name ~date ?slides ?video ?image
        ?feedbacks ?tags ())

let validate = from_data
let entity_name = "event"
let neutral = Yocaml.Metadata.required entity_name
let compare a b = Yocaml.Datetime.compare a.date b.date
