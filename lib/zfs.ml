module Error = struct
  include Config.Error 
end


external prop_is_string : int -> bool = "ocaml_zfs_prop_is_string"

module Handle = struct
  type t

  external open_ : string -> int = "ocaml_zfs_open"

  let open_ path =

end

module Prop = struct
  include Config.Props

  let is_string prop = prop_is_string prop
end

