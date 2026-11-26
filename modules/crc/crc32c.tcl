# crc32c.tcl -- Copyright (C) 2002 Pat Thoyts <patthoyts@users.sourceforge.net>
#
# CRC32 Cyclic Redundancy Check. 
# (for algorithm see http://www.rad.com/networks/1994/err_con/crc.htm)
#
# From http://mini.net/tcl/2259.tcl
# Written by Wayland Augur and Pat Thoyts.
#
# -------------------------------------------------------------------------
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# -------------------------------------------------------------------------
# This provides a critcl C implementation of CRC
#
# INSTALLATION
# ------------
# This package uses critcl (https://wiki.tcl-lang.org/critcl). To build do:
#  critcl -libdir <your-tcl-lib-dir> -pkg crcc crc32c.tcl sumc.tcl
#
# To build this for tcllib use sak.tcl:
#  tclsh sak.tcl critcl
# generates a tcllibc module.

package require critcl
# @sak notprovided crcc
package provide crcc 1.3.4

# -------------------------------------------------------------------------

# crc::Crc32_c --
#
#	A C version of the CRC-32 code using the same table. This is
#	designed to be compiled using critcl.
#

namespace eval ::crc {
    critcl::ccommand Crc32_c {dummy interp objc objv} {
        /*
         * The CRC is kept in an unsigned 32-bit value and exchanged with
         * Tcl as a wide integer. A C long is only 32 bits on Windows, so
         * Tcl_NewLongObj would return a negative value whenever bit 31 is
         * set, and Tcl_GetLongFromObj rejects such values once they have
         * been through Tcl arithmetic (Tcl 9).
         *
         * The seed must fit into 32 bits, as either a signed or an
         * unsigned value (-2147483648 .. 4294967295), which is the range
         * Tcl_GetLongFromObj accepted for a 32-bit long. Anything else is
         * rejected with the same error Tcl reports.
         *
         * Define CRC32_NO_SEED_RANGE_CHECK to disable this check. The
         * seed is then truncated to its low 32 bits instead, on every
         * platform.
         */
        int r = TCL_OK;
        unsigned int t = 0xFFFFFFFFU;
        Tcl_WideInt w;

        if (objc < 2 || objc > 3) {
            Tcl_WrongNumArgs(interp, 1, objv, "data ?seed?"); /* OK tcl9 */
            return TCL_ERROR;
        }
        if (objc == 3) {
            r = Tcl_GetWideIntFromObj(interp, objv[2], &w);
            if (r == TCL_OK) {
#ifndef CRC32_NO_SEED_RANGE_CHECK
                if (w < -(Tcl_WideInt) 0x80000000 || w > (Tcl_WideInt) 0xFFFFFFFF) {
                    const char *msg = "integer value too large to represent";
                    Tcl_SetObjResult(interp, Tcl_NewStringObj(msg, -1));
                    Tcl_SetErrorCode(interp, "ARITH", "IOVERFLOW", msg, (char *) NULL);
                    return TCL_ERROR;
                }
#endif
                t = (unsigned int) (w & 0xFFFFFFFF);
            }
        }
        if (r == TCL_OK) {
            Tcl_Size cn, size, ndx;
            unsigned char *data;
            unsigned int lkp;
            Tcl_Obj *tblPtr, *lkpPtr;

            tblPtr = Tcl_GetVar2Ex(interp, "::crc::crc32_tbl", NULL,
                                   TCL_LEAVE_ERR_MSG );
            if (tblPtr == NULL) {
                r = TCL_ERROR;
            }
            if (r == TCL_OK) {
                data = Tcl_GetBytesFromObj(interp, objv[1], &size); /* OK tcl9 */
                if (data == NULL) return TCL_ERROR;
            }
            for (cn = 0; r == TCL_OK && cn < size; cn++) {
                ndx = (t ^ data[cn]) & 0xFF;
                r = Tcl_ListObjIndex(interp, tblPtr, ndx, &lkpPtr); /* OK tcl9 */
                if (r == TCL_OK) {
                    r = Tcl_GetWideIntFromObj(interp, lkpPtr, &w);
                }
                if (r == TCL_OK) {
                    lkp = (unsigned int) (w & 0xFFFFFFFF);
                    t = lkp ^ (t >> 8);
                }
            }
        }

        if (r == TCL_OK) {
            Tcl_SetObjResult(interp,
                             Tcl_NewWideIntObj((Tcl_WideInt) (t ^ 0xFFFFFFFFU)));
        }
        return r;
    }
}

# -------------------------------------------------------------------------
#
# Local variables:
#   mode: tcl
#   indent-tabs-mode: nil
# End:
