/*
 * Copyright (C) 2020-2021 Anil Madhavapeddy
 * Copyright (C) 2020-2021 Sadiq Jaffer
 * Copyright (C) 2022 Christiano Haesbaert
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include <unistd.h>
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h> 

#include <libzfs_core.h>
#include <libzfs.h>
#include <caml/alloc.h>
#include <caml/bigarray.h>
#include <caml/callback.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <caml/signals.h>
#include <caml/unixsupport.h>
#include <caml/socketaddr.h>

#undef ZFS_DEBUG
#ifdef ZFS_DEBUG
#define dprintf(fmt, ...) fprintf(stderr, fmt, ##__VA_ARGS__)
#else
#define dprintf(fmt, ...) ((void)0)
#endif

value ocaml_zfs_prop_is_string(value v_prop){
  int res;
  res = zfs_prop_is_string(Int_val(v_prop));
  if (res < 0) {
    caml_failwith("Error occurred!");
  }
  return Val_bool(res);
}

#define Zfs_list_val(v) (*((struct nv_list **) Data_custom_val(v)))
#define Zfs_handle_val(v) (*((libzfs_handle_t **) Data_custom_val(v)))
#define Zfs_pool_val(v) (*((zpool_handle_t **) Data_custom_val(v)))

static void finalize_zfs_list(value v) {
  caml_stat_free(Zfs_list_val(v));
  Zfs_list_val(v) = NULL;
}

static struct custom_operations zfs_list_ops = {
  "zfs.zfs_list_ops",
  finalize_zfs_list,
  custom_compare_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default,
  custom_compare_ext_default,
  custom_fixed_length_default
};

static void finalize_zfs_handle(value v) {
  caml_stat_free(Zfs_handle_val(v));
  Zfs_handle_val(v) = NULL;
}

static struct custom_operations zfs_handle_ops = {
  "zfs.zfs_handle",
  finalize_zfs_handle,
  custom_compare_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default,
  custom_compare_ext_default,
  custom_fixed_length_default
};

static void finalize_zfs_pool(value v) {
  caml_stat_free(Zfs_pool_val(v));
  Zfs_pool_val(v) = NULL;
}

static struct custom_operations zfs_pool_ops = {
  "zfs.zfs_pool",
  finalize_zfs_pool,
  custom_compare_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default,
  custom_compare_ext_default,
  custom_fixed_length_default
};

// ZFS Initialisation

value
ocaml_zfs_init(value v_unit) {
	CAMLparam0();
	libzfs_handle_t* res;
	CAMLlocal1(v_handle);

	v_handle = caml_alloc_custom_mem(&zfs_handle_ops, sizeof(libzfs_handle_t*), 64);
	res = libzfs_init();
	Zfs_handle_val(v_handle) = res; 

	CAMLreturn(v_handle);
}

// ZFS Pools 

value
ocaml_zfs_pool_open(value v_handle, value v_path) {
	CAMLparam2(v_handle, v_path);
	zpool_handle_t* res;
	CAMLlocal1(v_pool);

	if (!caml_string_is_c_safe(v_path))
      caml_invalid_argument("ocaml_zfs_pool_open: path is not C-safe");

	v_pool = caml_alloc_custom_mem(&zfs_pool_ops, sizeof(zpool_handle_t*), 64);
	res = zpool_open(Zfs_handle_val(v_handle), String_val(v_path));
	Zfs_pool_val(v_handle) = res;

	CAMLreturn(v_handle);
}

value
ocaml_zfs_pool_get_name(value v_pool) {
  CAMLparam1(v_pool);
  CAMLlocal1(v_path);
  const char* result;

  result = zpool_get_name(Zfs_pool_val(v_pool));
  v_path = caml_copy_string(result);

  CAMLreturn(v_path);
}


