# interpolate.tcl --
#
#    Package for interpolation methods (one- and two-dimensional)
#
# Remarks:
#    None of the methods deal gracefully with missing values
#
# To do:
#    Add cubic splines and B-splines as methods
#    For spatial interpolation in two dimensions also quadrant method?
#    Method for destroying a table
#    Proper documentation
#    Proper test cases
#
# version 0.1: initial implementation, january 2003
# version 0.2: added linear and Lagrange interpolation, straightforward
#              spatial interpolation, april 2004

package provide math::interpolate 0.2
package require struct

# ::math::interpolate --
#   Namespace holding the procedures and variables
#

namespace eval ::math::interpolate {
   variable search_radius {}
   variable inv_dist_pow  2

   namespace export interp-1d-table interp-table interp-linear \
                    interp-lagrange
}

# defineTable --
#    Define a two-dimensional table of data
#
# Arguments:
#    name     Name of the table to be created
#    cols     Names of the columns (for convenience and for counting)
#    values   List of values to fill the table with (must be sorted
#             w.r.t. first column or first column and first row)
#
# Results:
#    Name of the new command
#
# Side effects:
#    Creates a new command, which is used in subsequent calls
#
proc ::math::interpolate::defineTable { name cols values } {

   set table ::math::interpolate::__$name
   ::struct::matrix $table

   $table add columns [llength $cols]
   $table add row
   $table set row 0 $cols

   set row    1
   set first  0
   set nocols [llength $cols]
   set novals [llength $values]
   while { $first < $novals } {
      set last [expr {$first+$nocols-1}]
      $table add row
      $table set row $row [lrange $values $first $last]

      incr first $nocols
      incr row
   }

   return $table
}

# inter-1d-table --
#    Interpolate in a one-dimensional table
#    (first column is independent variable, all others dependent)
#
# Arguments:
#    table    Name of the table
#    xval     Value of the independent variable
#
# Results:
#    List of interpolated values, including the x-variable
#
proc ::math::interpolate::interp-1d-table { table xval } {

   #
   # Search for the records that enclose the x-value
   #
   set xvalues [lrange [$table get column 0] 1 end]

   foreach {row row2} [FindEnclosingEntries $xval $xvalues] break

   set prev_values [$table get row $row]
   set next_values [$table get row $row2]

   set xprev       [lindex $prev_values 0]
   set xnext       [lindex $next_values 0]

   if { $row == $row2 } {
      return [concat $xval [lrange $prev_values 1 end]]
   } else {
      set wprev [expr {($xnext-$xval)/($xnext-$xprev)}]
      set wnext [expr {1.0-$wprev}]
      set results {}
      foreach vprev $prev_values vnext $next_values {
         set vint  [expr {$vprev*$wprev+$vnext*$wnext}]
         lappend results $vint
      }
      return $results
   }
}

# interp-table --
#    Interpolate in a two-dimensional table
#    (first column and first row are independent variables)
#
# Arguments:
#    table    Name of the table
#    xval     Value of the independent row-variable
#    yval     Value of the independent column-variable
#
# Results:
#    Interpolated value
#
# Note:
#    Use bilinear interpolation
#
proc ::math::interpolate::interp-table { table xval yval } {

   #
   # Search for the records that enclose the x-value
   #
   set xvalues [lrange [$table get column 0] 2 end]

   foreach {row row2} [FindEnclosingEntries $xval $xvalues] break
   incr row
   incr row2

   #
   # Search for the columns that enclose the y-value
   #
   set yvalues [lrange [$table get row 1] 1 end]

   foreach {col col2} [FindEnclosingEntries $yval $yvalues] break

   set yvalues [concat "." $yvalues] ;# Prepend a dummy column!

   set prev_values [$table get row $row]
   set next_values [$table get row $row2]

   set x1          [lindex $prev_values 0]
   set x2          [lindex $next_values 0]
   set y1          [lindex $yvalues     $col]
   set y2          [lindex $yvalues     $col2]

   set v11         [lindex $prev_values $col]
   set v12         [lindex $prev_values $col2]
   set v21         [lindex $next_values $col]
   set v22         [lindex $next_values $col2]

   #
   # value = v0 + a*(x-x1) + b*(y-y1) + c*(x-x1)*(y-y1)
   # if x == x1 and y == y1: value = v11
   # if x == x1 and y == y2: value = v12
   # if x == x2 and y == y1: value = v21
   # if x == x2 and y == y2: value = v22
   #
   set a 0.0
   if { $x1 != $x2 } {
      set a [expr {($v21-$v11)/($x2-$x1)}]
   }
   set b 0.0
   if { $y1 != $y2 } {
      set b [expr {($v12-$v11)/($y2-$y1)}]
   }
   set c 0.0
   if { $x1 != $x2 && $y1 != $y2 } {
      set c [expr {($v11+$v22-$v12-$v21)/($x2-$x1)/($y2-$y1)}]
   }

   set result \
   [expr {$v11+$a*($xval-$x1)+$b*($yval-$y1)+$c*($xval-$x1)*($yval-$y1)}]

   return $result
}

# FindEnclosingEntries --
#    Search within a sorted list
#
# Arguments:
#    val      Value to be searched
#    values   List of values to be examined
#
# Results:
#    Returns a list of the previous and next indices
#
proc FindEnclosingEntries { val values } {
   set found 0
   set row2  1
   foreach v $values {
      if { $val <= $v } {
         set row   [expr {$row2-1}]
         set found 1
         break
      }
      incr row2
   }

   #
   # Border cases: extrapolation needed
   #
   if { ! $found } {
      incr row2 -1
      set  row $row2
   }
   if { $row == 0 } {
      set row $row2
   }

   return [list $row $row2]
}

# interp-linear --
#    Use linear interpolation
#
# Arguments:
#    xyvalues   List of x/y values to be interpolated
#    xval       x-value for which a value is sought
#
# Results:
#    Estimated value at $xval
#
# Note:
#    The list xyvalues must be sorted w.r.t. the x-value
#
proc ::math::interpolate::interp-linear { xyvalues xval } {
   #
   # Border cases first
   #
   if { [lindex $xyvalues 0] > $xval } {
      return [lindex $xyvalues 1]
   }
   if { [lindex $xyvalues end-1] < $xval } {
      return [lindex $xyvalues end]
   }

   #
   # The ordinary case
   #
   set idxx -2
   set idxy -1
   foreach { x y } $xyvalues {
      if { $xval < $x } {
         break
      }
      incr idxx 2
      incr idxy 2
   }

   set x2 [lindex $xyvalues $idxx]
   set y2 [lindex $xyvalues $idxy]

   if { $x2 != $x } {
      set yval [expr {$y+($y2-$y)*($xval-$x)/($x2-$x)}]
   } else {
      set yval $y
   }
   return $yval
}

# interp-lagrange --
#    Use the Lagrange interpolation method
#
# Arguments:
#    xyvalues   List of x/y values to be interpolated
#    xval       x-value for which a value is sought
#
# Results:
#    Estimated value at $xval
#
# Note:
#    The list xyvalues must be sorted w.r.t. the x-value
#    Furthermore the Lagrange method is not a very practical
#    method, as potentially the errors are unbounded
#
proc ::math::interpolate::interp-lagrange { xyvalues xval } {
   #
   # Border case: xval equals one of the "nodes"
   #
   foreach { x y } $xyvalues {
      if { $x == $xval } {
         return $y
      }
   }

   #
   # Ordinary case
   #
   set nonodes2 [llength $xyvalues]

   set yval 0.0

   for { set i 0 } { $i < $nonodes2 } { incr i 2 } {
      set idxn 0
      set xn   [lindex $xyvalues $i]
      set yn   [lindex $xyvalues [expr {$i+1}]]

      foreach { x y } $xyvalues {
         if { $idxn != $i } {
            set yn [expr {$yn*($x-$xval)/($x-$xn)}]
         }
         incr idxn 2
      }

      set yval [expr {$yval+$yn}]
   }

   return $yval
}

# interp-spatial --
#    Use a straightforward interpolation method with weights as
#    function of the inverse distance to interpolate in 2D and N-D
#    space
#
# Arguments:
#    xyvalues   List of coordinates and values at these coordinates
#    coord      List of coordinates for which a value is sought
#
# Results:
#    Estimated value(s) at $coord
#
# Note:
#    The list xyvalues is a list of lists:
#    { {x1 y1 z1 {v11 v12 v13 v14}
#      {x2 y2 z2 {v21 v22 v23 v24}
#      ...
#    }
#    The last element of each inner list is either a single number
#    or a list in itself. In the latter case the return value is
#    a list with the same number of elements.
#
#    The method is influenced by the search radius and the
#    power of the inverse distance
#
proc ::math::interpolate::interp-spatial { xyvalues coord } {
   variable search_radius
   variable inv_dist_pow

   set result {}
   foreach v [lindex [lindex $xyvalues 0] end] {
      lappend result 0.0
   }

   set total_weight 0.0

   if { $search_radius != {} } {
      set max_radius2  [expr {$search_radius*$search_radius}]
   } else {
      set max_radius2  {}
   }

   foreach point $xyvalues {
      set dist 0.0
      foreach c [lrange $point 0 end-1] cc $coord {
         set dist [expr {$dist+($c-$cc)*($c-$cc)}]
      }
      if { $max_radius2 == {} || $dist <= $max_radius2 } {
         if { $inv_dist_pow == 1 } {
            set dist [expr {sqrt($dist)}]
         }
         set total_weight [expr {$total_weight+1.0/$dist}]

         set idx 0
         foreach v [lindex $point end] r $result {
            lset result $idx [expr {$r+$v/$dist}]
            incr idx
         }
      }
   }

   if { $total_weight == 0.0 } {
      set idx 0
      foreach r $result {
         lset result $idx {}
         incr idx
      }
   } else {
      set idx 0
      foreach r $result {
         lset result $idx [expr {$r/$total_weight}]
         incr idx
      }
   }

   return $result
}

# interp-spatial-params --
#    Set the parameters for spatial interpolation
#
# Arguments:
#    max_search   Search radius (if none: use {} or "")
#    power        Power for the inverse distance (1 or 2, defaults to 2)
#
# Results:
#    None
#
proc ::math::interpolate::interp-spatial-params { max_search {power 2} } {
   variable search_radius
   variable inv_dist_pow

   set search_radius $max_search
   if { $power == 1 } {
      set inv_dist_pow 1
   } else {
      set inv_dist_pow 2
   }
}

#
# Announce our presence
#
package provide math::interpolate 1.0
