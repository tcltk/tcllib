## -*- tcl -*-
# ### ### ### ######### ######### #########
## Support declarations

# ### ### ### ######### ######### #########
## Type definitions

critcl::resulttype wxh {
    Tcl_SetObjResult(interp, wxh_box (interp, &rv));
    return TCL_OK;
} wxh

critcl::argtype wxh {
    if (!wxh_unbox (interp, @@, &@A) != TCL_OK) return TCL_ERROR;
} wxh wxh

# ### ### ### ######### ######### #########
## Support implementation

critcl::ccode {
    typedef struct wxh {
	int h;
	int w;
    } wxh;

    static int wxh_unbox (Tcl_Interp* interp, Tcl_Obj* obj, wxh* p) {
	int       lc;
	Tcl_Obj** lv;

	if (Tcl_ListObjGetElements (interp, obj, &lc, &lv) != TCL_OK) return TCL_ERROR;
	if (lc != 2) {
	    Tcl_SetErrorCode (interp, "MAP", "SLIPPY", "INVALID", "WXH", NULL);
	    Tcl_AppendResult (interp, "Bad WxH, expected list of 2", NULL);
	    return TCL_ERROR;
	}

	int h;
	int w;

	if (Tcl_GetIntFromObj (interp, lv[0], &h) != TCL_OK) return TCL_ERROR;
	if (Tcl_GetIntFromObj (interp, lv[1], &w) != TCL_OK) return TCL_ERROR;

	p->h = h;
	p->w = w;

	return TCL_OK;
    }

    static Tcl_Obj* wxh_box (Tcl_Interp* interp, wxh* p) {
	Tcl_Obj* cl[2];
	cl [0] = Tcl_NewIntObj (p->h);
	cl [1] = Tcl_NewIntObj (p->w);
	return Tcl_NewListObj(2, cl);
    }
}

# ### ### ### ######### ######### #########
return
