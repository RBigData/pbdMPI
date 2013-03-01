/* Modified from "R-devel/main/src/error.c" and
 *               "R-devel/main/include/Rinternals.h".
 *
 * WCC: .Internal(...) is not allowed for user to modified and may change.
 *      However, some function is exported in "Rinternals.h" which can be
 *      reused at somewhere. .External(...) can do the similar works,
 *      but the caller should be passed from R, since findCall() is not
 *      available in "Rinternals.h" and requires more R negative structures.
 *      Replace errorcall() by Rf_errorcall(), and warningcall() by
 *      Rf_warningcall().
 */

#include <R.h>
#include <Rdefines.h>
#include <Rinternals.h>

static int immediateWarning = 0;

/* Origin: SEXP attribute_hidden do_stop(). */
SEXP api_R_stop(SEXP args){
	SEXP call, c_call;

	args = CDR(args);		/* get caller name */
	call = CAR(args);

	args = CDR(args);
	if(asLogical(CAR(args))){	/* find context -> "... in: ..:" */
		c_call = call;
	} else{
		c_call = R_NilValue;
	}

	args = CDR(args);
	if(CAR(args) != R_NilValue){	/* message */
		SETCAR(args, coerceVector(CAR(args), STRSXP));
		if(!isValidString(CAR(args))){
			Rf_errorcall(c_call,
				" [invalid string in comm.stop(.)]\n");
		}
		Rf_errorcall(c_call, "%s",
			translateChar(STRING_ELT(CAR(args), 0)));
	} else{
		Rf_errorcall(c_call, "\n");
	}

	return c_call;
} /* End of api_R_stop(). */


/* Origin: SEXP attribute_hidden do_warning(). */
SEXP api_R_warning(SEXP args){
	SEXP call, c_call;

	args = CDR(args);		/* get caller name */
	call = CAR(args);

	args = CDR(args);
	if(asLogical(CAR(args))){	/* find context -> "... in: ..:" */
		c_call = call;
	} else{
		c_call = R_NilValue;
	}

	args = CDR(args);

	if(asLogical(CAR(args))){	/* immediate = TRUE */
		immediateWarning = 1;
	} else{
		immediateWarning = 0;
	}

	args = CDR(args);
	if(CAR(args) != R_NilValue){
		SETCAR(args, coerceVector(CAR(args), STRSXP));
		if(!isValidString(CAR(args))){
			Rf_warningcall(c_call,
				" [invalid string in comm.warning(.)]\n");
		} else{
			Rf_warningcall(c_call, "%s",
				translateChar(STRING_ELT(CAR(args), 0)));
		}
	} else{
		Rf_warningcall(c_call, "");
	}
	immediateWarning = 0;	/* reset to internal calls */

	return CAR(args);
} /* End of api_R_warning(). */

