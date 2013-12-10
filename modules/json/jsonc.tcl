# jsonc.tcl --
#
#       Implementation of a JSON parser in C, binding to the json-c library.
#       See c/README-tcllib for notes on origin.
#
# Copyright (c) 2013 - critcl wrapper - Andreas Kupries <andreas_kupries@users.sourceforge.net>
# Copyright (c) 2013 - C binding      - mi+tcl.tk-2013@aldan.algebra.com

package require critcl
# @sak notprovided jsonc
package provide jsonc 1
package require Tcl 8.4

## Parts still written in Tcl.
critcl::tsources jsonc_tcl.tcl

critcl::cheaders -Ic c/*.h
critcl::csources c/*.c

critcl::ccode {
    #include <json.h>

    static Tcl_Obj *
    value2obj(Tcl_Interp *I, struct json_object *jso)
    {
	Tcl_Obj *result, *key, *value;
	int	 len;
	struct array_list *ar;

	switch (json_object_get_type(jso)) {
	    case json_type_object: {
		result = Tcl_NewDictObj();
		json_object_object_foreach(jso, k, v) {
		    key   = Tcl_NewStringObj(k, -1);
		    value = value2obj(I, v);

		    Tcl_DictObjPut(I, result, key, value);
		    json_object_object_del(jso, k);
		}
		return result;
	    }

	    case json_type_null: {
		return Tcl_NewStringObj("null",-1);
	    }

	    case json_type_boolean: {
		return Tcl_NewBooleanObj(json_object_get_boolean(jso));
	    }

	    case json_type_double: {
		return Tcl_NewDoubleObj(json_object_get_double(jso));
	    }

	    case json_type_int: {
		return Tcl_NewLongObj(json_object_get_int64(jso));
	    }

	    case json_type_array: {
		ar = json_object_get_array(jso);
		result = Tcl_NewListObj(0, NULL);
		for (len = 0; len < ar->length; len++) {
		    Tcl_ListObjAppendElement(I, result,
					     value2obj(I, ar->array[len]));
		}
		return result;
	    }

	    case json_type_string: {
		len = json_object_get_string_len(jso);
		return Tcl_NewStringObj(json_object_get_string(jso), len);
	    }
	}
	return NULL; /* unreachable */
    }
}

namespace eval ::json {
    critcl::ccommand json2dict_critcl {dummy I objc objv} {

	struct json_tokener	*tok;
	enum json_tokener_error	 jerr;
	struct json_object	*parsed;
	const char		*text;
	int       		 len;

	if (objc != 2) {
	    Tcl_WrongNumArgs(I, 1, objv, "json");
	    return TCL_ERROR;
	}

	text   = Tcl_GetStringFromObj(objv[1], &len);
	tok    = json_tokener_new();
	parsed = json_tokener_parse_ex(tok, text, len);

	if (parsed == NULL) {
	    jerr = json_tokener_get_error(tok);
	    Tcl_SetResult(I,
			  (void *)json_tokener_error_desc(jerr),
			  TCL_STATIC);
	    json_tokener_free(tok);
	    return TCL_ERROR;
	}
	json_tokener_free(tok);

	Tcl_SetObjResult(I, value2obj(I, parsed));

	json_object_put(parsed);
	return TCL_OK;
    }
}
