# -*- tcl -*-
package require    msgcat
namespace import ::msgcat::*

mcset en end/open/list    "Dokument zu Ende, nicht alle Listen wurden geschlossen"
mcset en end/open/example "Dokument zu Ende, das letzte Beispiel wurde nicht abgeschlossen"
mcset en end/open/mp	  "Dokument zu Ende, es fehlt der Abschlussbefehl \[manpage_end\]"
mcset en mpbegin          "Erwartete diesen Befehl als ersten in der Manpage"
mcset en hdrcmd           "Dieser Befehl ist ausserhalb des Headers nicht erlaubt"
mcset en bodycmd          "Dieser Befehl darf nicht ausserhalb des Hauptteils der Manpage auftreten"
mcset en reqcmd           "Dieser Befehl ist ausserhalb von Header/Requirements nicht erlaubt"
mcset en nolistcmd        "Dieser Befehl ist innerhalb einer Liste nicht erlaubt"
mcset en nolisthdr        "Dieser Befehl darf nicht zwischen dem Beginn einer Liste und ihrem ersten Unterpunkt benutzt werden"
mcset en listcmd          "Dieser Befehl ist ausserhalb einer Liste nicht erlaubt"
mcset en deflist          "Dieser Befehl darf nur in Definitions-Listen benutzt werden"
mcset en bulletlist       "Dieser Befehl darf nur in ungeordneten Listen benutzt werden"
mcset en enumlist         "Dieser Befehl darf nur in Aufzaehlungs-Listen benutzt werden"
mcset en examplecmd       "Dieser Befehl kann nur zum Schliessen eines Beispieles benutzt werden"
mcset en listcmd          "Dieser Befehl ist ausserhalb einer Liste nicht erlaubt"
mcset en nodonecmd        "Dieser Befehl ist nach Ausfuehrung von \[manpage_end\] nicht mehr erlaubt"
