VERSION=$(shell tclsh mkdoc.tcl --version)

mkdoc:
	dtplite -o mkdoc.html html mkdoc.man
	tclsh mkdoc.tcl mkdoc.tcl mkdoc.md
	tclsh mkdoc.tcl mkdoc.tcl mkdoc-mkdoc.html
