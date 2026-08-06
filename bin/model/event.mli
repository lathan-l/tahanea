type t

include Yocaml.Data.S with type t := t
include Yocaml.Data.Validation.S with type t := t
include Yocaml.Required.DATA_READABLE with type t := t

val compare : t -> t -> int
