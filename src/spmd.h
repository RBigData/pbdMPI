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

/* 64-bit and long vector support. */
#define SPMD_INT8_LEN_MAX 127				// 2^7 - 1
#define SPMD_INT16_LEN_MAX 32767			// 2^15 - 1
#define SPMD_INT32_LEN_MAX 2147483647			// 2^31 - 1
#define SPMD_INT64_LEN_MAX 4503599627370496		// 2^52 - 1
#if (MPI_LONG_DEBUG & 1) == 0
	/* 1.
	   gcc -m64 gives 4 byes to an integer (int), and
	   gcc -m32 gives 4 byes to an integer (int), too.
	   2.
	   gcc -m64 gives 8 byes to an integer pointer (int*), but
	   gcc -m32 gives 4 byes to an integer pointer (int*).
	 */
	#define SPMD_SHORT_LEN_MAX R_SHORT_LEN_MAX	// SPMD_INT32_LEN_MAX
#else
	#define SPMD_SHORT_LEN_MAX SPMD_INT8_LEN_MAX
#endif

/* In file "spmd.c". */
SEXP spmd_initialize();
SEXP spmd_finalize(SEXP R_mpi_finalize);
SEXP spmd_is_finalized();
SEXP spmd_get_processor_name();

/* In file "spmd_communicator.c". */
SEXP spmd_barrier(SEXP R_comm);
SEXP spmd_comm_is_null(SEXP R_comm);
SEXP spmd_comm_size(SEXP R_comm);
SEXP spmd_comm_rank(SEXP R_comm);
SEXP spmd_comm_dup(SEXP R_comm, SEXP R_newcomm);
SEXP spmd_comm_free(SEXP R_comm);
SEXP spmd_comm_set_errhandler(SEXP R_comm);
SEXP spmd_comm_get_parent(SEXP R_comm);
SEXP spmd_is_master();
SEXP spmd_comm_abort(SEXP R_comm, SEXP R_errorcode);
SEXP spmd_comm_split(SEXP R_comm, SEXP R_color, SEXP R_key, SEXP R_newcomm);
SEXP spmd_comm_disconnect(SEXP R_comm);
SEXP spmd_comm_connect(SEXP R_port_name, SEXP R_info, SEXP R_root, SEXP R_comm,
                SEXP R_newcomm);
SEXP spmd_comm_accept(SEXP R_port_name, SEXP R_info, SEXP R_root, SEXP R_comm,
                SEXP R_newcomm);
SEXP spmd_port_open(SEXP R_info);
SEXP spmd_port_close(SEXP R_port_name);
SEXP spmd_serv_publish(SEXP R_serv_name, SEXP R_info, SEXP R_port_name);
SEXP spmd_serv_unpublish(SEXP R_serv_name, SEXP R_info, SEXP R_port_name);
SEXP spmd_serv_lookup(SEXP R_serv_name, SEXP R_info);
SEXP spmd_intercomm_merge(SEXP R_intercomm, SEXP R_high, SEXP R_comm);
SEXP spmd_intercomm_create(SEXP R_local_comm, SEXP R_local_leader,
		SEXP R_peer_comm, SEXP R_remote_leader, SEXP R_tag,
		SEXP R_newintercomm);
SEXP spmd_comm_c2f(SEXP R_comm);

/* In file "spmd_communicator_spawn.c". */
SEXP spmd_comm_spawn(SEXP R_worker, SEXP R_workerargv, SEXP R_nworker,
		SEXP R_info, SEXP R_rank_source, SEXP R_intercomm);

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
SEXP spmd_bcast_string(SEXP R_send_data, SEXP R_rank_source, SEXP R_comm);

/* In file "spmd_scatter.c". */
SEXP spmd_scatter_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_source, SEXP R_comm);
SEXP spmd_scatter_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_source, SEXP R_comm);
SEXP spmd_scatter_raw(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_rank_source, SEXP R_comm);

/* In file "spmd_scatterv.c". */
SEXP spmd_scatterv_integer(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_send_counts, SEXP R_displs, SEXP R_rank_source,
		SEXP R_comm);
SEXP spmd_scatterv_double(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_send_counts, SEXP R_displs, SEXP R_rank_source,
		SEXP R_comm);
SEXP spmd_scatterv_raw(SEXP R_send_data, SEXP R_recv_data,
		SEXP R_send_counts, SEXP R_displs, SEXP R_rank_source,
		SEXP R_comm);

/* In file "spmd_utility.c". */
SEXP spmd_probe(SEXP R_source, SEXP R_tag, SEXP R_comm, SEXP R_status);
SEXP spmd_iprobe(SEXP R_source, SEXP R_tag, SEXP R_comm, SEXP R_status);
SEXP spmd_anysource();
SEXP spmd_anytag();
SEXP spmd_get_sourcetag(SEXP R_status);
SEXP spmd_get_count(SEXP R_data_type, SEXP R_status);

/* In file "spmd_info.c". */
SEXP spmd_info_create(SEXP R_info);
SEXP spmd_info_set(SEXP R_info, SEXP R_key, SEXP R_value);
SEXP spmd_info_free(SEXP R_info);

/* In file "spmd_wait.c". */
SEXP spmd_wait(SEXP R_request, SEXP R_status);
SEXP spmd_waitany(SEXP R_count, SEXP R_status);
SEXP spmd_waitsome(SEXP R_count);
SEXP spmd_waitall(SEXP R_count);

/* In file "spmd_tool.c". */
SEXP AsInt(int x);
int spmd_errhandler(int error_code);

#endif

