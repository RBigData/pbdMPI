#include "comm_api.h"


/* Modify from "R-2.15.1/src/main/sort.c". */
int api_rcmp_increasing(double x, double y, Rboolean nalast){
    int nax = ISNAN(x), nay = ISNAN(y);
    if (nax && nay)	return 0;
    if (nax)		return nalast?1:-1;
    if (nay)		return nalast?-1:1;
    if (x < y)		return -1;
    if (x > y)		return 1;
    return 0;
} /* End of api_rcmp_increasing(). */

int api_rcmp_decreasing(double x, double y, Rboolean nalast){
    int nax = ISNAN(x), nay = ISNAN(y);
    if (nax && nay)	return 0;
    if (nax)		return nalast?-1:1;
    if (nay)		return nalast?1:-1;
    if (x < y)		return 1;
    if (x > y)		return -1;
    return 0;
} /* End of api_rcmp_decreasing(). */


/* ----- Swap ----- */
void api_rswap(double *array, int x_index, int x_rank, int y_index, int y_rank,
		int comm_index, int status_index){
	int COMM_RANK;
	double tmp_value;

	MPI_Comm_rank(comm[comm_index], &COMM_RANK);
	if(x_rank != y_rank){
		if(COMM_RANK == x_rank){
			MPI_Send(&array[x_index], 1, MPI_DOUBLE, y_rank, y_rank,
				comm[comm_index]);
			MPI_Recv(&array[x_index], 1, MPI_DOUBLE, y_rank, x_rank,
				comm[comm_index], &status[status_index]);
		} else if(COMM_RANK == y_rank){
			MPI_Recv(&tmp_value, 1, MPI_DOUBLE, x_rank, y_rank,
				comm[comm_index], &status[status_index]);
			MPI_Send(&array[y_index], 1, MPI_DOUBLE, x_rank, x_rank,
				comm[comm_index]);
			array[y_index] = tmp_value;
		}
	} else{
		if(COMM_RANK == x_rank){
			tmp_value = array[x_index];
			array[x_index] = array[y_index];
			array[y_index] = tmp_value;
		}
	}
} /* End of api_rswap(). */


/* ----- Partition ----- */
void api_rpartition(double *array, int *n_all, int left_index,
		int left_rank, int right_index, int right_rank, int pivot_index,
		int pivot_rank, int comm_index, int status_index,
		int (*fp_cmp)(double, double, Rboolean),
		Rboolean nalast, int *ret_index, int *ret_rank){
	int COMM_RANK, i_index, i_rank, j_rank, from_index, to_index, check;
	double pivot_value;

	MPI_Comm_rank(comm[comm_index], &COMM_RANK);

	if(COMM_RANK == pivot_rank){
		pivot_value = array[pivot_index];
	}
	MPI_Bcast(&pivot_value, 1, MPI_DOUBLE, pivot_rank, comm[comm_index]);

	api_rswap(array, pivot_index, pivot_rank, right_index, right_rank,
		comm_index, status_index);
	*ret_index = left_index;
	*ret_rank = left_rank;

	for(i_rank = left_rank; i_rank <= right_rank; i_rank++){
		/* Check 0 vector. */
		if(n_all[i_rank] == 0){
			continue;
		}

		if(i_rank == left_rank){
			from_index = left_index;
		} else{
			from_index = 0;
		}

		if(i_rank == right_rank){
			to_index = right_index;
		} else{
			to_index = n_all[i_rank];
		}

		for(i_index = from_index; i_index < to_index; i_index++){
			if(COMM_RANK == i_rank){
				check = fp_cmp(array[i_index],
						pivot_value, nalast);
				MPI_Bcast(&check, 1, MPI_INT, i_rank,
					comm[comm_index]);
			} else{
				MPI_Bcast(&check, 1, MPI_INT, i_rank,
					comm[comm_index]);
			}

			if(check == -1){
				api_rswap(array, i_index, i_rank,
					*ret_index, *ret_rank,
					comm_index, status_index);
				*ret_index = *ret_index + 1;
				if(*ret_index > n_all[*ret_rank] - 1){
					*ret_index = 0;
					// *ret_rank = *ret_rank + 1;
					/* Check 0 vector. */
					for(j_rank = *ret_rank + 1;
							j_rank <= right_rank;
							j_rank++){
						if(n_all[j_rank] != 0){
							*ret_rank = j_rank;
							break;
						}
					}
				}
			}
		}
	}

	api_rswap(array, *ret_index, *ret_rank, right_index, right_rank,
		comm_index, status_index);
} /* End of api_rpartition(). */


/* ----- Quick sort ----- */
void api_rsort(double *array, int *n_all, int left_index, int left_rank,
		int right_index, int right_rank, int comm_index,
		int status_index, int (*fp_cmp)(double, double, Rboolean),
		Rboolean nalast){
	int COMM_RANK;
	int pivot_index, pivot_rank, ret_index, ret_rank;
	int new_pivot_index, new_pivot_rank;
	int i_rank;

	MPI_Comm_rank(comm[comm_index], &COMM_RANK);

	if((left_rank == right_rank && left_index < right_index) ||
			(left_rank < right_rank)){
		pivot_rank = (int) left_rank + (right_rank - left_rank) / 2;
		/* Check 0 vector. */
		if(n_all[pivot_rank] == 0){
			for(i_rank = left_rank; i_rank <= right_rank; i_rank++){
				if(n_all[i_rank] != 0){
					pivot_rank = i_rank;
					break;
				}
			}
		}

		if(left_rank != right_rank){
			if(pivot_rank == left_rank){
				pivot_index = (int) left_index +
					(n_all[left_rank] - 1 - left_index) / 2;
			} else if(pivot_rank == right_rank){
				pivot_index = (int) right_index / 2;
			} else{
				pivot_index = (int) (n_all[pivot_rank] - 1) / 2;
			}
		} else{
			pivot_index = (int) left_index +
					(right_index - left_index) / 2;
		}

		api_rpartition(array, n_all, left_index,
			left_rank, right_index, right_rank, pivot_index,
			pivot_rank, comm_index, status_index,
			fp_cmp, nalast, &ret_index, &ret_rank);

		/* Check 0 vector. */
		new_pivot_rank = -1;
		if(ret_index == 0){
			// new_pivot_rank = ret_rank - 1;
			/* Check 0 vector. */
			for(i_rank = ret_rank - 1; i_rank >= left_rank;
					i_rank--){
				if(n_all[i_rank] != 0){
					new_pivot_rank = i_rank;
					new_pivot_index = n_all[i_rank] - 1;
					break;
				}
			}
		} else{
			new_pivot_rank = ret_rank;
			new_pivot_index = ret_index - 1;
		}
		/* Check 0 vector. */
		if(new_pivot_rank != -1){
			api_rsort(array, n_all, left_index, left_rank,
				new_pivot_index, new_pivot_rank, comm_index,
				status_index, fp_cmp, nalast);
		}

		/* Check 0 vector. */
		new_pivot_rank = -1;
		if(ret_index == n_all[ret_rank] - 1){
			// new_pivot_rank = ret_rank + 1;
			/* Check 0 vector. */
			for(i_rank = ret_rank + 1; i_rank <= right_rank;
					i_rank++){
				if(n_all[i_rank] != 0){
					new_pivot_rank = i_rank;
					new_pivot_index = 0;
					break;
				}
			}
		} else{
			new_pivot_rank = ret_rank;
			new_pivot_index = ret_index + 1;
		}
		/* Check 0 vector. */
		if(new_pivot_rank != -1){
			api_rsort(array, n_all, new_pivot_index,
				new_pivot_rank, right_index, right_rank,
				comm_index, status_index, fp_cmp, nalast);
		}
	}
} /* End api_rsort(). */


/* ----- R wraper ----- */
SEXP api_R_rsort(SEXP R_x, SEXP R_comm, SEXP R_status, SEXP R_decreasing,
		SEXP R_nalast){
	SEXP R_ret;
	int n_x;
	double *x, *array;
	int COMM_SIZE, comm_index, status_index, *n_all;
	int decreasing;
	Rboolean nalast;
	int (*fp_cmp)(double, double, Rboolean);
	int i_rank, left_rank, right_rank;

	n_x = length(R_x);
	x = REAL(R_x);
	comm_index = INTEGER(R_comm)[0];
	status_index = INTEGER(R_status)[0];
	decreasing = asLogical(R_decreasing);
	nalast = asLogical(R_nalast);

	/* R objects. */
	PROTECT(R_ret = allocVector(REALSXP, n_x));
	array = REAL(R_ret);
	memcpy(array, x, n_x * sizeof(double));

	MPI_Comm_size(comm[comm_index], &COMM_SIZE);
	n_all = (int*) malloc(COMM_SIZE * sizeof(int));
	MPI_Allgather(&n_x, 1, MPI_INT, n_all, 1, MPI_INT, comm[comm_index]);

	if(decreasing == TRUE){
		fp_cmp = &api_rcmp_decreasing;
	} else{
		fp_cmp = &api_rcmp_increasing;
	}

	left_rank = 0;
	right_rank = COMM_SIZE - 1;
	/* Check if 0 vector. */
	for(i_rank = 0; i_rank < COMM_SIZE; i_rank++){
		if(n_all[i_rank] != 0){
			left_rank = i_rank;	
			break;
		}
	}
	for(i_rank = COMM_SIZE - 1; i_rank >= 0; i_rank--){
		if(n_all[i_rank] != 0){
			right_rank = i_rank;
			break;
		}
	}

	api_rsort(array, n_all, 0, left_rank, n_all[right_rank] - 1,
		right_rank, comm_index, status_index, fp_cmp, nalast);

	free(n_all);
	UNPROTECT(1);
	return(R_ret);
} /* End api_R_rsort(). */
