module Error = struct
  include Config.Error 
end


external prop_is_string : int -> bool = "ocaml_zfs_prop_is_string"


module Prop = struct
  include Config.Props

  let is_string prop = prop_is_string prop
end

module Core = struct
  external init : unit -> bool = "ocaml_zfs_lzc_init"

  let () = 
    if init () then () else failwith "Failed initialise ZFS"

  external exists : string -> bool = "ocaml_zfs_lzc_exists" 
end

