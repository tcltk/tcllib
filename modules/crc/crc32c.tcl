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
         * The CRC is kept in an unsigned 64-bit value and exchanged with
         * Tcl as a wide integer, on every platform. This is what the code
         * always did where a C long is 64 bits (Linux, macOS), so the
         * results there are unchanged. A C long is only 32 bits on
         * Windows, which made Tcl_NewLongObj return negative values and
         * Tcl_GetLongFromObj reject the sums Crc32Update passed back in.
         *
         * Seeds are accepted in the same 64-bit range as before, and their
         * upper bits take part in the computation, as before. Crc32Final
         * reduces the result to 32 bits.
         */
        int r = TCL_OK;
        Tcl_WideUInt t = 0xFFFFFFFF;
        Tcl_WideInt w;

        if (objc < 2 || objc > 3) {
            Tcl_WrongNumArgs(interp, 1, objv, "data ?seed?"); /* OK tcl9 */
            return TCL_ERROR;
        }
        if (objc == 3) {
#if TCL_MAJOR_VERSION >= 9
            /*
             * Tcl 9's Tcl_GetWideIntFromObj stops at 2^63-1, while its
             * Tcl_GetLongFromObj accepted unsigned values up to 2^64-1
             * for a 64-bit long. Try the unsigned conversion first to
             * keep that range; negative values and errors fall through.
             */
            Tcl_WideUInt u;
            if (Tcl_GetWideUIntFromObj(NULL, objv[2], &u) == TCL_OK) {
                t = u;
            } else
#endif
            {
                r = Tcl_GetWideIntFromObj(interp, objv[2], &w);
                if (r == TCL_OK) {
                    t = (Tcl_WideUInt) w;
                }
            }
        }
        if (r == TCL_OK) {
            Tcl_Size cn, size, ndx;
            unsigned char *data;
            Tcl_WideUInt lkp;
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
                    lkp = (Tcl_WideUInt) (w & 0xFFFFFFFF);
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
