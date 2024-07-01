let () =
  let creation = string_of_bool @@ Zfs.Prop.is_string Zfs.Prop.creation in
  let encryption = string_of_bool @@ Zfs.Prop.is_string Zfs.Prop.snapdir in
  Printf.printf "Creation is string %s, Encryption is string %s\n" creation encryption;
  try
    let ds = Sys.argv.(1) in
    Printf.printf "Checking if %s exists: " ds;
    let b = Zfs.Core.exists ds in 
    Printf.printf "%b" b
  with
   Invalid_argument _ -> print_endline "You can also check for datasets" 
