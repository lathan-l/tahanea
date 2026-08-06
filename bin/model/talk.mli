type t

val fetch : Yocaml.Path.t -> t Yocaml.Eff.t
val fetch_all : Yocaml.Path.t -> (unit, t list) Yocaml.Task.t

module Listing : sig
  type talk := t
  type t

  include Yocaml.Required.DATA_INJECTABLE with type t := t

  val make : Yocaml.Archetype.Page.t -> talk list -> t
end

val compare : t -> t -> int
