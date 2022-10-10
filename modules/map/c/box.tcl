## -*- tcl -*-
# ### ### ### ######### ######### #########
## Support declarations

# ### ### ### ######### ######### #########
## Type definitions

critcl::resulttype box {
    Tcl_SetObjResult(interp, box_box (interp, &rv));
    return TCL_OK;
} box

critcl::argtype box {
    if (box_unbox (interp, @@, &@A) != TCL_OK) return TCL_ERROR;
} box box

# ### ### ### ######### ######### #########
## Support implementation

critcl::ccode {
    typedef struct box {
	double lat0;
	double lon0;
	double lat1;
	double lon1;
    } box;

    static int box_unbox (Tcl_Interp* interp, Tcl_Obj* obj, box* p) {
	int       lc;
	Tcl_Obj** lv;

	if (Tcl_ListObjGetElements (interp, obj, &lc, &lv) != TCL_OK) return TCL_ERROR;
	if (lc != 4) {
	    Tcl_SetErrorCode (interp, "MAP", "SLIPPY", "INVALID", "BOX");
	    Tcl_AppendResult (interp, "Bad box, expected list of 4");
	    return TCL_ERROR;
	}

	double lat0;
	double lon0;
	double lat1;
	double lon1;

	if (Tcl_GetDoubleFromObj (interp, lv[0], &lat0) != TCL_OK) return TCL_ERROR;
	if (Tcl_GetDoubleFromObj (interp, lv[1], &lon0) != TCL_OK) return TCL_ERROR;
	if (Tcl_GetDoubleFromObj (interp, lv[2], &lat1) != TCL_OK) return TCL_ERROR;
	if (Tcl_GetDoubleFromObj (interp, lv[3], &lon1) != TCL_OK) return TCL_ERROR;

	p->lat0 = lat0;
	p->lon0 = lon0;
	p->lat1 = lat1;
	p->lon1 = lon1;

	return TCL_OK;
    }

    static Tcl_Obj* box_box (Tcl_Interp* interp, box* p) {
	Tcl_Obj* cl[4];
	cl [0] = Tcl_NewDoubleObj (p->lat0);
	cl [1] = Tcl_NewDoubleObj (p->lon0);
	cl [2] = Tcl_NewDoubleObj (p->lat1);
	cl [3] = Tcl_NewDoubleObj (p->lon1);
	return Tcl_NewListObj(4, cl);
    }
}

# ### ### ### ######### ######### #########
return
