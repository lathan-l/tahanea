module Ingredients : sig
  type t

  include Yocaml.Required.DATA_READABLE with type t := t
end

type t

include Yocaml.Required.DATA_INJECTABLE with type t := t
