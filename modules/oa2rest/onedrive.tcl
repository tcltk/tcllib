
package require Tcl 8.6

package require oa2rest

namespace eval onedrive::bvfs {
    namespace ensemble create -parameters service
}

proc onedrive::bvfs::createdirectory {service root relative actual} {
    set token [$service send PUT "/Files/getByPath('[Quotepath $relative]')"]
    