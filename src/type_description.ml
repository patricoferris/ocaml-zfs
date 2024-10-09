module Types (F : Ctypes.TYPE) = struct
  open F

  type libzfs_handle_t

  let libzfs_handle_t :
      libzfs_handle_t Ctypes_static.structure Ctypes_static.ptr typ =
    ptr @@ structure "libzfs_handle"

  type zpool_handle_t

  let zpool_handle_t :
      zpool_handle_t Ctypes_static.structure Ctypes_static.ptr typ =
    ptr @@ structure "zpool_handle"

  type zfs_handle_t

  let zfs_handle_t : zfs_handle_t Ctypes_static.structure Ctypes_static.ptr typ
      =
    ptr @@ structure "zfs_handle"

  type nvlist_t

  let nvlist_t : nvlist_t Ctypes_static.structure typ = structure "nvlist"
  let nvl_version = field nvlist_t "nvl_version" int32_t
  let nvl_nvflag = field nvlist_t "nvl_nvflag" uint32_t
  let nvl_priv = field nvlist_t "nvl_priv" uint64_t
  let nvl_flag = field nvlist_t "nvl_flag" uint32_t
  let nvl_pad = field nvlist_t "nvl_pad" int32_t
  let () = seal nvlist_t
end
