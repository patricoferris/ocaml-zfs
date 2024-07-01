module C = Configurator.V1

let starts_with ~prefix s =
  try
  String.iteri (fun i c ->
    if Char.equal (String.get s i) c then ()
  else raise Not_found) prefix;
  let l = String.length s in
  let o = String.length prefix in
  Some (String.sub s o (l - o))
  with Not_found -> None

let () =
  C.main ~name:"discover" (fun c ->
      let errs, props =
        C.C_define.import c ~c_flags:["-D_GNU_SOURCE"; "-I"; Filename.concat (Sys.getcwd ()) "include"]
        ~includes:[ "unistd.h"; "stdio.h"; "stdint.h"; "stdbool.h"; "libzfs_core.h"; "libzfs.h" ]
          C.C_define.Type.[
            (* Errors *)
            "EZFS_SUCCESS", Int;

            (* Properties *)
            "ZFS_PROP_CREATION", Int;
            "ZFS_PROP_USED", Int;
            "ZFS_PROP_AVAILABLE", Int;
            "ZFS_PROP_REFERENCED", Int;
            "ZFS_PROP_COMPRESSRATIO", Int;
            "ZFS_PROP_COMPRESSION", Int;
            "ZFS_PROP_SNAPDIR", Int;
            "ZFS_PROP_ENCRYPTION", Int;
          ]
        |> List.fold_left (fun (errs, props) -> function
            | name, C.C_define.Value.Int v -> (
              let type_ name = Printf.sprintf "val %s : t" (String.lowercase_ascii name) in
              let definition name = Printf.sprintf "let %s : t = 0x%x" (String.lowercase_ascii name) v in
              match starts_with ~prefix:"EZFS_" name with
              | Some r -> ((type_ r, definition r) :: errs, props)
              | None -> (
                match starts_with ~prefix:"ZFS_PROP_" name with
                | Some r -> (errs, (type_ r, definition r) :: props)
                | None -> failwith "Unknown def"
              )
            )
            | _ -> assert false) ([], [])
      in
      let with_module ~name defs = [Printf.sprintf "module %s = struct\n type t =  int\n" name] @ defs @ [ "end" ] in
      let with_module_type ~name defs = [Printf.sprintf "module type %s = sig\n type t = private int\n" name] @ defs @ [ "end" ] in
      let defs = with_module ~name:"Error" (List.map snd errs) @ with_module ~name:"Props" (List.map snd props) in
      let types = with_module_type ~name:"ERROR" (List.map fst errs) @ with_module_type ~name:"PROPS" (List.map fst props) in 
      C.Flags.write_lines "config.ml" (defs @ types))
