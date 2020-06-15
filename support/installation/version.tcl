package_version 1.20
package_name    tcllib

dist_exclude    config
dist_exclude    modules/ftp/example
dist_exclude    modules/ftpd/examples
dist_exclude    modules/stats
dist_exclude    modules/fileinput

critcl_main tcllibc       tcllibc.tcl
critcl      base32c       base32c/base32_c.tcl
critcl      base32hexc    base32c/base32hex_c.tcl
critcl      base64c      {base64c/base64c.tcl base64/uuencode.tcl base64/yencode.tcl}
critcl      crcc         {crcc/crcc.tcl crc/sum.tcl crc/crc32.tcl}
critcl      ipMorec       dns/ipMoreC.tcl
critcl      jsonc         jsonc/jsonc.tcl
critcl      md4c          md4c/md4c.tcl
critcl      md5c          md5c/md5c.tcl
critcl      md5cryptc     md5cryptc/md5cryptc.tcl
critcl      ptc           {pt/pt_rdengine_c.tcl pt/pt_parse_peg_c.tcl}
critcl      rc4c          rc4c/rc4c.tcl
critcl      sha1c         sha1c/sha1c.tcl
critcl      sha256c       sha256c/sha256c.tcl
critcl      struct_graphc struct/graph_c.tcl
critcl      struct_queuec struct/queue_c.tcl
critcl      struct_setc   struct/sets_c.tcl
critcl      struct_stackc struct/stack_c.tcl
critcl      struct_treec  struct/tree_c.tcl
critcl      uuid          uuid/uuid.tcl
critcl_notes {Note: you can ignore warnings for tcllibc.tcl, base64c.tcl and crcc.tcl.}
