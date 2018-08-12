#include <R.h>
#include <R_ext/Rdynload.h>

#include "spmd.h"
#include "comm_api.h"

static const R_CallMethodDef callMethods[] = {
	/* In file "pkg_tools.c". */
	{"arrange_MPI_APTS", (DL_FUNC) &arrange_MPI_APTS, 0},

	/* In file "pkg_dl.c". */
	{"pkg_initialize", (DL_FUNC) &pkg_initialize, 1},

	/* In file "spmd.c". */
	{"spmd_initialize", (DL_FUNC) &spmd_initialize, 0},
	{"spmd_finalize", (DL_FUNC) &spmd_finalize, 1},
	{"spmd_is_finalized", (DL_FUNC) &spmd_is_finalized, 0},
	{"spmd_get_processor_name", (DL_FUNC) &spmd_get_processor_name, 0},

	/* In file "spmd_communicator.c". */
	{"spmd_barrier", (DL_FUNC) &spmd_barrier, 1},
	{"spmd_comm_is_null", (DL_FUNC) &spmd_comm_is_null, 1},
	{"spmd_comm_size", (DL_FUNC) &spmd_comm_size, 1},
	{"spmd_comm_rank", (DL_FUNC) &spmd_comm_rank, 1},
	{"spmd_comm_localrank", (DL_FUNC) &spmd_comm_localrank, 1},
	{"spmd_comm_dup", (DL_FUNC) &spmd_comm_dup, 2},
	{"spmd_comm_free", (DL_FUNC) &spmd_comm_free, 1},
	{"spmd_comm_set_errhandler", (DL_FUNC) &spmd_comm_set_errhandler, 1},
	{"spmd_comm_get_parent", (DL_FUNC) &spmd_comm_get_parent, 1},
	{"spmd_is_master", (DL_FUNC) &spmd_is_master, 0},
	{"spmd_comm_abort", (DL_FUNC) &spmd_comm_abort, 2},
	{"spmd_comm_split", (DL_FUNC) &spmd_comm_split, 4},
	{"spmd_comm_disconnect", (DL_FUNC) &spmd_comm_disconnect, 1},
	{"spmd_comm_connect", (DL_FUNC) &spmd_comm_connect, 5},
	{"spmd_comm_accept", (DL_FUNC) &spmd_comm_accept, 5},
	{"spmd_port_open", (DL_FUNC) &spmd_port_open, 1},
	{"spmd_port_close", (DL_FUNC) &spmd_port_close, 1},
	{"spmd_serv_publish", (DL_FUNC) &spmd_serv_publish, 3},
	{"spmd_serv_unpublish", (DL_FUNC) &spmd_serv_unpublish, 3},
	{"spmd_serv_lookup", (DL_FUNC) &spmd_serv_lookup, 2},
	{"spmd_intercomm_merge", (DL_FUNC) &spmd_intercomm_merge, 3},
	{"spmd_intercomm_create", (DL_FUNC) &spmd_intercomm_create, 6},
	{"spmd_comm_c2f", (DL_FUNC) &spmd_comm_c2f, 1},

	/* In file "spmd_communicator_spawn.c". */
	{"spmd_comm_spawn", (DL_FUNC) &spmd_comm_spawn, 6},

	/* In file "spmd_allgather.c". */
	{"spmd_allgather_integer", (DL_FUNC) &spmd_allgather_integer, 3},
	{"spmd_allgather_double", (DL_FUNC) &spmd_allgather_double, 3},
	{"spmd_allgather_raw", (DL_FUNC) &spmd_allgather_raw, 3},

	/* In file "spmd_gather.c". */
	{"spmd_gather_integer", (DL_FUNC) &spmd_gather_integer, 4},
	{"spmd_gather_double", (DL_FUNC) &spmd_gather_double, 4},
	{"spmd_gather_raw", (DL_FUNC) &spmd_gather_raw, 4},

	/* In file "spmd_allgatherv.c". */
	{"spmd_allgatherv_integer", (DL_FUNC) &spmd_allgatherv_integer, 5},
	{"spmd_allgatherv_double", (DL_FUNC) &spmd_allgatherv_double, 5},
	{"spmd_allgatherv_raw", (DL_FUNC) &spmd_allgatherv_raw, 5},

	/* In file "spmd_gatherv.c". */
	{"spmd_gatherv_integer", (DL_FUNC) &spmd_gatherv_integer, 6},
	{"spmd_gatherv_double", (DL_FUNC) &spmd_gatherv_double, 6},
	{"spmd_gatherv_raw", (DL_FUNC) &spmd_gatherv_raw, 6},

	/* In file "spmd_send.c". */
	{"spmd_send_integer", (DL_FUNC) &spmd_send_integer, 4},
	{"spmd_send_double", (DL_FUNC) &spmd_send_double, 4},
	{"spmd_send_raw", (DL_FUNC) &spmd_send_raw, 4},

	/* In file "spmd_recv.c". */
	{"spmd_recv_integer", (DL_FUNC) &spmd_recv_integer, 5},
	{"spmd_recv_double", (DL_FUNC) &spmd_recv_double, 5},
	{"spmd_recv_raw", (DL_FUNC) &spmd_recv_raw, 5},

	/* In file "spmd_isend.c". */
	{"spmd_isend_integer", (DL_FUNC) &spmd_isend_integer, 5},
	{"spmd_isend_double", (DL_FUNC) &spmd_isend_double, 5},
	{"spmd_isend_raw", (DL_FUNC) &spmd_isend_raw, 5},

	/* In file "spmd_irecv.c". */
	{"spmd_irecv_integer", (DL_FUNC) &spmd_irecv_integer, 5},
	{"spmd_irecv_double", (DL_FUNC) &spmd_irecv_double, 5},
	{"spmd_irecv_raw", (DL_FUNC) &spmd_irecv_raw, 5},

	/* In file "spmd_sendrecv_replace.c". */
	{"spmd_sendrecv_replace_integer",
		(DL_FUNC) &spmd_sendrecv_replace_integer, 7},
	{"spmd_sendrecv_replace_double",
		(DL_FUNC) &spmd_sendrecv_replace_double, 7},
	{"spmd_sendrecv_replace_raw",
		(DL_FUNC) &spmd_sendrecv_replace_raw, 7},

	/* In file "spmd_sendrecv.c". */
	{"spmd_sendrecv_integer", (DL_FUNC) &spmd_sendrecv_integer, 8},
	{"spmd_sendrecv_double", (DL_FUNC) &spmd_sendrecv_double, 8},
	{"spmd_sendrecv_raw", (DL_FUNC) &spmd_sendrecv_raw, 8},

	/* In file "spmd_allreduce.c". */
	{"spmd_allreduce_integer", (DL_FUNC) &spmd_allreduce_integer, 4},
	{"spmd_allreduce_double", (DL_FUNC) &spmd_allreduce_double, 4},
	{"spmd_allreduce_float", (DL_FUNC) &spmd_allreduce_float, 4},

	/* In file "spmd_reduce.c". */
	{"spmd_reduce_integer", (DL_FUNC) &spmd_reduce_integer, 5},
	{"spmd_reduce_double", (DL_FUNC) &spmd_reduce_double, 5},
	{"spmd_reduce_float", (DL_FUNC) &spmd_reduce_float, 5},

	/* In file "spmd_bcast.c". */
	{"spmd_bcast_integer", (DL_FUNC) &spmd_bcast_integer, 3},
	{"spmd_bcast_double", (DL_FUNC) &spmd_bcast_double, 3},
	{"spmd_bcast_raw", (DL_FUNC) &spmd_bcast_raw, 3},
	{"spmd_bcast_string", (DL_FUNC) &spmd_bcast_string, 3},

	/* In file "spmd_scatter.c". */
	{"spmd_scatter_integer", (DL_FUNC) &spmd_scatter_integer, 4},
	{"spmd_scatter_double", (DL_FUNC) &spmd_scatter_double, 4},
	{"spmd_scatter_raw", (DL_FUNC) &spmd_scatter_raw, 4},

	/* In file "spmd_scatterv.c". */
	{"spmd_scatterv_integer", (DL_FUNC) &spmd_scatterv_integer, 6},
	{"spmd_scatterv_double", (DL_FUNC) &spmd_scatterv_double, 6},
	{"spmd_scatterv_raw", (DL_FUNC) &spmd_scatterv_raw, 6},

	/* In file "spmd_alltoall.c". */
	{"spmd_alltoall_integer", (DL_FUNC) &spmd_alltoall_integer, 5},
	{"spmd_alltoall_double", (DL_FUNC) &spmd_alltoall_double, 5},
	{"spmd_alltoall_raw", (DL_FUNC) &spmd_alltoall_raw, 5},

	/* In file "spmd_alltoallv.c". */
	{"spmd_alltoallv_integer", (DL_FUNC) &spmd_alltoallv_integer, 7},
	{"spmd_alltoallv_double", (DL_FUNC) &spmd_alltoallv_double, 7},
	{"spmd_alltoallv_raw", (DL_FUNC) &spmd_alltoallv_raw, 7},

	/* In file "spmd_utility.c". */
	{"spmd_probe", (DL_FUNC) &spmd_probe, 4},
	{"spmd_iprobe", (DL_FUNC) &spmd_iprobe, 4},
	{"spmd_anysource", (DL_FUNC) &spmd_anysource, 0},
	{"spmd_anytag", (DL_FUNC) &spmd_anytag, 0},
	{"spmd_get_sourcetag", (DL_FUNC) &spmd_get_sourcetag, 1},
	{"spmd_get_count", (DL_FUNC) &spmd_get_count, 2},

	/* In file "spmd_info.c". */
	{"spmd_info_create", (DL_FUNC) &spmd_info_create, 1},
	{"spmd_info_set", (DL_FUNC) &spmd_info_set, 3},
	{"spmd_info_free", (DL_FUNC) &spmd_info_free, 1},

	/* In file "spmd_wait.c". */
	{"spmd_wait", (DL_FUNC) &spmd_wait, 2},
	{"spmd_waitany", (DL_FUNC) &spmd_waitany, 2},
	{"spmd_waitsome", (DL_FUNC) &spmd_waitsome, 1},
	{"spmd_waitall", (DL_FUNC) &spmd_waitall, 1},

	/* In files "comm_sort_integer.c" and "comm_sort_double.c". */
	{"api_R_isort", (DL_FUNC) &api_R_isort, 5},
	{"api_R_rsort", (DL_FUNC) &api_R_rsort, 5},

	/* Finish R_CallMethodDef. */
	{NULL, NULL, 0}
};
/* End of the callMethods[]. */


void R_init_pbdMPI(DllInfo *info){
	R_registerRoutines(info, NULL, callMethods, NULL, NULL);
	R_useDynamicSymbols(info, TRUE);
} /* End of R_init_pbdMPI(). */
