/* WCC: Define stuff for global api. */

#ifndef __G_API_
#define __G_API_

/* pkg stuff. */
#include "pkg_global.h"
#include "spmd_constant.h"

/* R utility stuff. */
#include <R_ext/Boolean.h>


/* In file "api_sort_integer.c". */
int api_icmp_increasing(int x, int y, Rboolean nalast);
int api_icmp_decreasing(int x, int y, Rboolean nalast);
void api_iswap(int *array, int x_index, int x_rank, int y_index, int y_rank,
		int comm_index, int status_index);
void api_ipartition(int *array, int *n_all, int left_index,
		int left_rank, int right_index, int right_rank, int pivot_index,
		int pivot_rank, int comm_index, int status_index,
		int (*fp_cmp)(int, int, Rboolean),
		Rboolean nalast, int *ret_index, int *ret_rank);
void api_isort(int *array, int *n_all, int left_index, int left_rank,
		int right_index, int right_rank, int comm_index,
		int status_index, int (*fp_cmp)(int, int, Rboolean),
		Rboolean nalast);
SEXP api_R_isort(SEXP R_x, SEXP R_comm, SEXP R_status,
		SEXP R_decreasing, SEXP R_nalast);

/* In file "api_sort_double.c". */
int api_rcmp_increasing(double x, double y, Rboolean nalast);
int api_rcmp_decreasing(double x, double y, Rboolean nalast);
void api_rswap(double *array, int x_index, int x_rank, int y_index, int y_rank,
		int comm_index, int status_index);
void api_rpartition(double *array, int *n_all, int left_index,
		int left_rank, int right_index, int right_rank, int pivot_index,
		int pivot_rank, int comm_index, int status_index,
		int (*fp_cmp)(double, double, Rboolean),
		Rboolean nalast, int *ret_index, int *ret_rank);
void api_rsort(double *array, int *n_all, int left_index, int left_rank,
		int right_index, int right_rank, int comm_index,
		int status_index, int (*fp_cmp)(double, double, Rboolean),
		Rboolean nalast);
SEXP api_R_rsort(SEXP R_x, SEXP R_comm, SEXP R_status,
		SEXP R_decreasing, SEXP R_nalast);

#endif

