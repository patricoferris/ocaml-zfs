module Error = struct
  include Config.Error
end

module Flags = struct
  type t = int

  let empty = 0
  let of_int x = x
  let ( + ) = ( lor )
  let mem a b = a land b = a
end

module Types = struct
  include Flags

  let vdev = Config.Types.vdev
  let pool = Config.Types.pool
  let volume = Config.Types.volume
  let invalid = Config.Types.invalid
  let bookmark = Config.Types.bookmark
  let snapshot = Config.Types.snapshot
  let filesystem = Config.Types.filesystem
end

module Handle = struct
  type t = C.Types.libzfs_handle_t Ctypes_static.structure Ctypes_static.ptr
end

let init : unit -> Handle.t = C.Functions.init
let errno : Handle.t -> int = C.Functions.errno

module Zpool = struct
  type t = C.Types.zpool_handle_t Ctypes_static.structure Ctypes_static.ptr

  let open_ = C.Functions.Zpool.open_
  let get_name = C.Functions.Zpool.get_name
end

module Nvlist = struct
  type t = C.Types.nvlist_t Ctypes_static.structure Ctypes_static.ptr

  type nvlist =
    (string
    * [ `Bool of bool
      | `String of string
      | `Byte of Unsigned.uchar
      | `Int64 of int64 ])
    list

  let check_return i =
    if i = 22 then invalid_arg "Nvlist.v: add bool" else assert (i = 0)

  let v (schema : nvlist) : t =
    let open Ctypes in
    let finalise v = C.Functions.Nvlist.free !@v in
    let nv_pp =
      allocate ~finalise (ptr C.Types.nvlist_t)
        (from_voidp C.Types.nvlist_t null)
    in
    (* TODO: Unique names or not... *)
    C.Functions.Nvlist.alloc nv_pp 0x1 0 |> check_return;
    let rec aux = function
      | [] -> !@nv_pp
      | (k, `Bool b) :: rest ->
          C.Functions.Nvlist.add_bool !@nv_pp k b |> check_return;
          aux rest
      | (k, `String s) :: rest ->
          C.Functions.Nvlist.add_string !@nv_pp k s |> check_return;
          aux rest
      | (k, `Int64 i64) :: rest ->
          C.Functions.Nvlist.add_int64 !@nv_pp k i64 |> check_return;
          aux rest
      | (k, `Byte u) :: rest ->
          C.Functions.Nvlist.add_byte !@nv_pp k u |> check_return;
          aux rest
      | _ -> assert false
    in
    aux schema
end

type t = C.Types.zfs_handle_t Ctypes_static.structure Ctypes_static.ptr

let create ?(props = []) handle path (type_ : Types.t) =
  let i = C.Functions.create handle path type_ (Nvlist.v props) in
  if i != 0 then failwith "Failed to create" else ()

let open_ handle path (type_ : Types.t) = C.Functions.open_ handle path type_
let close : t -> unit = C.Functions.close
let get_type : t -> Types.t = C.Functions.get_type
