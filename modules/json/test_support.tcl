
catch {unset JSON}
catch {unset TCL}
catch {unset DICTSORT}

proc dictsort3 {spec data} {
    while [llength $spec] {
        set type [lindex $spec 0]
        set spec [lrange $spec 1 end]
        
        switch -- $type {
            dict {
                lappend spec * string
                
                set json {}
                foreach {key} [lsort [dict keys $data]] {
                    set val [dict get $data $key]
                    foreach {keymatch valtype} $spec {
                        if {[string match $keymatch $key]} {
                            lappend json $key [dictsort3 $valtype $val]
                            break
                        }
                    }
                }
                return $json
            }
            list {
                lappend spec * string
                set json {}
                set idx 0
                foreach {val} $data {
                    foreach {keymatch valtype} $spec {
                        if {$idx == $keymatch || $keymatch eq "*"} {
                            lappend json [dictsort3 $valtype $val]
                            break
                        }
                    }
                    incr idx
                }
                return $json
            }
            string {
                return $data
            }
            default {error "Invalid type"}
        }
    }
}


set JSON(array) {[
      {
         "precision": "zip",
         "Latitude":  37.7668,
         "Longitude": -122.3959,
         "Address":   "",
         "City":      "SAN FRANCISCO",
         "State":     "CA",
         "Zip":       "94107",
         "Country":   "US"
      },
      {
         "precision": "zip",
         "Latitude":  37.371991,
         "Longitude": -122.026020,
         "Address":   "",
         "City":      "SUNNYVALE",
         "State":     "CA",
         "Zip":       "94085",
         "Country":   "US"
      }
     ]}
set TCL(array) {{precision zip Latitude 37.7668 Longitude -122.3959 Address {} City {SAN FRANCISCO} State CA Zip 94107 Country US} {precision zip Latitude 37.371991 Longitude -122.026020 Address {} City SUNNYVALE State CA Zip 94085 Country US}}

set DICTSORT(array) {list dict}

set JSON(glossary) {{
    "glossary": {
        "title": "example glossary",
        "mixlist": ["a \"\" str", -0.09, null, "", {"member":true}],
        "GlossDiv": {
            "title": "S",
            "GlossList": [{
                "ID": "SGML",
                "GlossTerm": "Standard \\\" Language",
                "Acronym": "SGML\\",
                "Abbrev": "ISO 8879:1986",
                "GlossDef":
                "A meta-markup language, used ...",
                "GlossSeeAlso": ["GML", "XML", "markup"]}]}}
}}
set TCL(glossary) {glossary {title {example glossary} mixlist {{a "" str} -0.09 null {} {member 1}} GlossDiv {title S GlossList {{ID SGML GlossTerm {Standard \" Language} Acronym SGML\\ Abbrev {ISO 8879:1986} GlossDef {A meta-markup language, used ...} GlossSeeAlso {GML XML markup}}}}}}
set DICTSORT(glossary) {dict * {dict GlossDiv {dict GlossList {list dict}}}}

set JSON(menu) {{"menu": {
    "id": "file",
    "value": "File:",
    "unival": "\u6021:",
    "popup": {
        "menuitem": [
                     {"value": "Open", "onclick": "OpenDoc()"},
                     {"value": "Close", "onclick": "CloseDoc()"}
                    ]
    }
}
}}
set TCL(menu) [list menu [list id file value File: unival \u6021: popup {menuitem {{value Open onclick OpenDoc()} {value Close onclick CloseDoc()}}}]]
set DICTSORT(menu) {dict * {dict popup {dict * {list dict}}}}

set JSON(widget) {{"widget": {
    "debug": "on",
    "window": {
        "title":"Sample Widget",
        "name": "main_window",
        "width": 500,
        "height": 500},
    "text": {
        "data": "Click Here",
        "size": 36,
        "style": "bold",
        "name": null,
        "hOffset":250,
        "vOffset": 100,
        "alignment": "center",
        "onMouseUp": "sun1.opacity = (sun1.opacity / 100) * 90;"
    }
}
}}
set TCL(widget) {widget {debug on window {title {Sample Widget} name main_window width 500 height 500} text {data {Click Here} size 36 style bold name null hOffset 250 vOffset 100 alignment center onMouseUp {sun1.opacity = (sun1.opacity / 100) * 90;}}}}
set DICTSORT(widget) {dict * {dict text dict window dict}}

set JSON(menu2) {{"menu": {
    "header": "Viewer",
    "items": [
              {"id": "Open"},
              {"id": "OpenNew", "label": "Open New"},
              null,
              {"id": "ZoomIn", "label": "Zoom In"},
              {"id": "ZoomOut", "label": "Zoom Out"},
              null,
              {"id": "Help"},
              {"id": "About", "label": "About Viewer..."}
             ]
}
}}
set TCL(menu2) {menu {header Viewer items {{id Open} {id OpenNew label {Open New}} null {id ZoomIn label {Zoom In}} {id ZoomOut label {Zoom Out}} null {id Help} {id About label {About Viewer...}}}}}
set DICTSORT(menu2) {dict * {dict items {list 0 dict 1 dict 3 dict 4 dict 6 dict 7 dict}}}

set JSON(emptyList) {[]}
set TCL(emptyList) {}

set JSON(emptyList2) {{"menu": []}}
set TCL(emptyList2) {menu {}}

set JSON(emptyList3) {["menu", []]}
set TCL(emptyList3) {menu {}}

set JSON(emptyList4) {[[]]}
set TCL(emptyList4) {{}}

proc resultfor {name} {
    global TCL
    transform $TCL($name) $name
}

proc transform {res name} {
    global DICTSORT
    if {[info exists DICTSORT($name)]} {
        return [dictsort3 $DICTSORT($name) $res]
    } else {
        return $res
    }
}

proc transform* {res args} {
    set t {}
    foreach r $res n $args {
        lappend t [transform $r $n]
    }
    return $t
}
