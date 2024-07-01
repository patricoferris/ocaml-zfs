let () =
  let creation = string_of_bool @@ Zfs.Prop.is_string Zfs.Prop.creation in
  let encryption = string_of_bool @@ Zfs.Prop.is_string Zfs.Prop.snapdir in
  Printf.printf "Creation is string %s, Encryption is string %s" creation encryption
