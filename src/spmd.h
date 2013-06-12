/* WCC: Define spmd stuff. */

#ifndef __SPMD_
#define __SPMD_

/* pkg stuff. */
#include "pkg_global.h"
#include "spmd_constant.h"

/* R SEXP stuff. */
#include <R.h>
#include <Rdefines.h>
#include <Rinternals.h>


/* In file "spmd.c". */
SEXP spmd_initialize();
SEXP spmd_finalize();
SEXP spmd_get_processor_name();

/* In file "spmd_communicator.c". */
SEXP spmd_barrier(SEXP R_comm);
SEXP spmd_comm_is_null(SEXP R_comm);
SEXP spmd_comm_size(SEXP R_comm);
SEXP spmd_comm_rank(SEXP R_comm);
SEXP spmd_comm_dup(SEXP R_comm, SEXP R_newcomm);
SEXP spmd_comm_set_errhandler(SEXP R_comm);
SEXP spmd_comm_spawn(SEXP R_worker, SEXP R_workerargv, SEXP R_nworker,
		SEXP R_info, SEXP R_rank_source, SEXP R_intercomm);
SEXP spmd_comm_get_parent(SEXP R_comm);
SEXP spmd_is_master();
SEXP spmd_comm_disconnect(SEXP R_comm);
SEXP spmd_intercomm_merge(SEXP R_intercomm, SEXP R_high, SEXP R_comm);
SEXP spmd_comm_c2f(SEXP R_comm);

/* In file "spmd_allgather.c". */
SEXP spmd_allgather_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_comm);
SEXP spmd_allgather_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_comm);
SEXP spmd_allgather_raw(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_comm);

/* In file "spmd_gather.c". */
SEXP spmd_gather_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_source, SEXP R_comm);
SEXP spmd_gather_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_source, SEXP R_comm);
SEXP spmd_gather_raw(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_source, SEXP R_comm);

/* In file "spmd_allgatherv.c". */
SEXP spmd_allgatherv_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_recv_counts, SEXP R_displs, SEXP R_comm);
SEXP spmd_allgatherv_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_recv_counts, SEXP R_displs, SEXP R_comm);
SEXP spmd_allgatherv_raw(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_recv_counts, SEXP R_displs, SEXP R_comm);

/* In file "spmd_gatherv.c". */
SEXP spmd_gatherv_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_recv_counts, SEXP R_displs, SEXP R_rank_source,
		SEXP R_comm);
SEXP spmd_gatherv_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_recv_counts, SEXP R_displs, SEXP R_rank_source,
		SEXP R_comm);
SEXP spmd_gatherv_raw(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_recv_counts, SEXP R_displs, SEXP R_rank_source,
		SEXP R_comm);

/* In file "spmd_send.c". */
SEXP spmd_send_integer(SEXP R_send_data, SEXP R_rank_dest, SEXP R_tag,
		SEXP R_comm);
SEXP spmd_send_double(SEXP R_send_data, SEXP R_rank_dest, SEXP R_tag,
		SEXP R_comm);
SEXP spmd_send_raw(SEXP R_send_data, SEXP R_rank_dest, SEXP R_tag,
		SEXP R_comm);

/* In file "spmd_recv.c". */
SEXP spmd_recv_integer(SEXP R_recv_data, SEXP R_rank_source, SEXP R_tag,
		SEXP R_comm, SEXP R_status);
SEXP spmd_recv_double(SEXP R_recv_data, SEXP R_rank_source, SEXP R_tag,
		SEXP R_comm, SEXP R_status);
SEXP spmd_recv_raw(SEXP R_recv_data, SEXP R_rank_source, SEXP R_tag,
		SEXP R_comm, SEXP R_status);

/* In file "spmd_isend.c". */
SEXP spmd_isend_integer(SEXP R_send_data, SEXP R_rank_dest, SEXP R_tag,
		SEXP R_comm, SEXP R_request);
SEXP spmd_isend_double(SEXP R_send_data, SEXP R_rank_dest, SEXP R_tag,
		SEXP R_comm, SEXP R_request);
SEXP spmd_isend_raw(SEXP R_send_data, SEXP R_rank_dest, SEXP R_tag,
		SEXP R_comm, SEXP R_request);

/* In file "spmd_irecv.c". */
SEXP spmd_irecv_integer(SEXP R_recv_data, SEXP R_rank_source, SEXP R_tag,
		SEXP R_comm, SEXP R_request);
SEXP spmd_irecv_double(SEXP R_recv_data, SEXP R_rank_source, SEXP R_tag,
		SEXP R_comm, SEXP R_request);
SEXP spmd_irecv_raw(SEXP R_recv_data, SEXP R_rank_source, SEXP R_tag,
		SEXP R_comm, SEXP R_request);

/* In file "spmd_sendrecv_replace.c". */
SEXP spmd_sendrecv_replace_integer(SEXP R_data, SEXP R_rank_dest,
		SEXP R_send_tag, SEXP R_rank_source, SEXP R_recv_tag,
		SEXP R_comm, SEXP R_status);
SEXP spmd_sendrecv_replace_double(SEXP R_data, SEXP R_rank_dest,
		SEXP R_send_tag, SEXP R_rank_source, SEXP R_recv_tag,
		SEXP R_comm, SEXP R_status);
SEXP spmd_sendrecv_replace_raw(SEXP R_data, SEXP R_rank_dest,
		SEXP R_send_tag, SEXP R_rank_source, SEXP R_recv_tag,
		SEXP R_comm, SEXP R_status);

/* In file "spmd_sendrecv.c". */
SEXP spmd_sendrecv_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_dest, SEXP R_send_tag,
		SEXP R_rank_source, SEXP R_recv_tag,
		SEXP R_comm, SEXP R_status);
SEXP spmd_sendrecv_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_dest, SEXP R_send_tag,
		SEXP R_rank_source, SEXP R_recv_tag,
		SEXP R_comm, SEXP R_status);
SEXP spmd_sendrecv_raw(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_dest, SEXP R_send_tag,
		SEXP R_rank_source, SEXP R_recv_tag,
		SEXP R_comm, SEXP R_status);

/* In file "spmd_allreduce.c". */
SEXP spmd_allreduce_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_op, SEXP R_comm);
SEXP spmd_allreduce_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_op, SEXP R_comm);

/* In file "spmd_reduce.c". */
SEXP spmd_reduce_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_op, SEXP R_rank_dest, SEXP R_comm);
SEXP spmd_reduce_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_op, SEXP R_rank_dest, SEXP R_comm);

/* In file "spmd_bcast.c". */
SEXP spmd_bcast_integer(SEXP R_send_data, SEXP R_rank_source, SEXP R_comm);
SEXP spmd_bcast_double(SEXP R_send_data, SEXP R_rank_source, SEXP R_comm);
SEXP spmd_bcast_raw(SEXP R_send_data, SEXP R_rank_source, SEXP R_comm);

/* In file "spmd_utility.c". */
SEXP spmd_probe(SEXP R_source, SEXP R_tag, SEXP R_comm, SEXP R_status);
SEXP spmd_iprobe(SEXP R_source, SEXP R_tag, SEXP R_comm, SEXP R_status);
SEXP spmd_any_source();
SEXP spmd_any_tag();
SEXP spmd_get_sourcetag(SEXP R_status);
SEXP spmd_get_count(SEXP R_data_type, SEXP R_status);

/* In file "spmd_info.c". */
SEXP spmd_info_create(SEXP R_info);
SEXP spmd_info_set(SEXP R_info, SEXP R_key, SEXP R_value);
SEXP spmd_info_free(SEXP R_info);

/* In file "spmd_tool.c". */
SEXP AsInt(int x);
int spmd_errhandler(int error_code);

#endif

