# geometry.tcl --
#
#	Collection of geometry functions.
#
# Copyright (c) 2001 by Ideogramic ApS and other parties.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
# 
# RCS: @(#) $Id: geometry.tcl,v 1.1 2001/12/12 16:51:53 chdamm Exp $

namespace eval ::math::geometry {
}


###
#
# POINTS
#
#    A point P consists of an x-coordinate, Px, and a y-coordinate, Py,
#    and both coordinates are floating point values.
#
#    Points are usually denoted by A, B, C, P, or Q.
#
###
#
# LINES
#
#    There are basically three types of lines:
#         line           A line is defined by two points A and B as the
#                        _infinite_ line going through these two points.
#                        Often a line is given as a list of 4 coordinates
#                        instead of 2 points.
#         line segment   A line segment is defined by two points A and B
#                        as the _finite_ that starts in A and ends in B.
#                        Often a line segment is given as a list of 4
#                        coordinates instead of 2 points.
#         polyline       A polyline is a sequence of connected line segments.
#
#    Please note that given a point P, the closest point on a line is given
#    by the projection of P onto the line. The closest point on a line segment
#    may be the projection, but it may also be one of the end points of the
#    line segment.
#
###
#
# DISTANCES
#
#    The distances in this package are all floating point values.
#
###



# ::math::geometry::calculateDistanceToLine
#
#       Calculate the distance between a point and a line.
#
# Arguments:
#       P             a point
#       line          a line
#
# Results:
#       dist          the smallest distance between P and the line
#
# Examples:
#     - calculateDistanceToLine {5 10} {0 0 10 10}
#       Result: 3.53553390593
#     - calculateDistanceToLine {-10 0} {0 0 10 10}
#       Result: 7.07106781187
#
proc ::math::geometry::calculateDistanceToLine {P line} {
    # solution based on FAQ 1.02 on comp.graphics.algorithms
    # L = sqrt( (Bx-Ax)^2 + (By-Ay)^2 )
    #     (Ay-Cy)(Bx-Ax)-(Ax-Cx)(By-Ay)
    # s = -----------------------------
    #                 L^2
    # dist = |s|*L
    #
    # =>
    # 
    #        | (Ay-Cy)(Bx-Ax)-(Ax-Cx)(By-Ay) |
    # dist = ---------------------------------
    #                       L
    set Ax [lindex $line 0]
    set Ay [lindex $line 1]
    set Bx [lindex $line 2]
    set By [lindex $line 3]
    set Cx [lindex $P 0]
    set Cy [lindex $P 1]
    if {$Ax==$Bx && $Ay==$By} {
	return [dist $Cx $Cy $Ax $Ay]
    } else {
	set L [expr {sqrt(pow($Bx-$Ax,2) + pow($By-$Ay,2))}]
	return [expr {abs(($Ay-$Cy)*($Bx-$Ax)-($Ax-$Cx)*($By-$Ay)) / $L}]
    }
}

# ::math::geometry::findClosestPointOnLine
#
#       Return the point on a line which is closest to a given point.
#
# Arguments:
#       P             a point
#       line          a line
#
# Results:
#       Q             the point on the line that has the smallest
#                     distance to P
#
# Examples:
#     - findClosestPointOnLine {5 10} {0 0 10 10}
#       Result: 7.5 7.5
#     - findClosestPointOnLine {-10 0} {0 0 10 10}
#       Result: -5.0 -5.0
#
proc ::math::geometry::findClosestPointOnLine {P line} {
    ...
}

# ::math::geometry::findClosestPointOnLineImpl
#
#       PRIVATE FUNCTION USED BY OTHER FUNCTIONS.
#       Find the point on a line that is closest to a given point.
#
# Arguments:
#       P             a point
#       line          a line defined by points A and B
#
# Results:
#       Q             the point on the line that has the smallest
#                     distance to P
#       r             r has the following meaning:
#                        r=0      P = A
#                        r=1      P = B
#                        r<0      P is on the backward extension of AB
#                        r>1      P is on the forward extension of AB
#                        0<r<1    P is interior to AB
#
proc ::math::geometry::findClosestPointOnLineImpl {P line} {
    # solution based on FAQ 1.02 on comp.graphics.algorithms
    #   L = sqrt( (Bx-Ax)^2 + (By-Ay)^2 )
    #        (Cx-Ax)(Bx-Ax) + (Cy-Ay)(By-Ay)
    #   r = -------------------------------
    #                     L^2
    #   Px = Ax + r(Bx-Ax)
    #   Py = Ay + r(By-Ay)
    set Ax [lindex $line 0]
    set Ay [lindex $line 1]
    set Bx [lindex $line 2]
    set By [lindex $line 3]
    set Cx [lindex $P 0]
    set Cy [lindex $P 1]
    if {$Ax==$Bx && $Ay==$By} {
	return [list [list $Ax $Ay] 0]
    } else {
	set L [expr {sqrt(pow($Bx-$Ax,2) + pow($By-$Ay,2))}]
	set r [expr {(($Cx-$Ax)*($Bx-$Ax) + ($Cy-$Ay)*($By-$Ay))/pow($L,2)}]
	set Px [expr {$Ax + $r*($Bx-$Ax)}]
	set Py [expr {$Ay + $r*($By-$Ay)}]
	return [list [list $Px $Py] $r]
    }
}

# ::math::geometry::calculateDistanceToLineSegment
#
#       Calculate the distance between a point and a line segment.
#
# Arguments:
#       P             a point
#       linesegment   a line segment
#
# Results:
#       dist          the smallest distance between P and any point
#                     on the line segment
#
# Examples:
#     - calculateDistanceToLineSegment {5 10} {0 0 10 10}
#       Result: 3.53553390593
#     - calculateDistanceToLineSegment {-10 0} {0 0 10 10}
#       Result: 10.0
#
proc ::math::geometry::calculateDistanceToLineSegment {P linesegment} {
    set result [calculateDistanceToLineSegmentImpl $P $linesegment]
    set distToLine [lindex $result 0]
    set r [lindex $result 1]
    if {$r<0} {
	return [lengthOfPolyline [concat $P [lrange $linesegment 0 1]]]
    } elseif {$r>1} {
	return [lengthOfPolyline [concat $P [lrange $linesegment 2 3]]]
    } else {
	return $distToLine
    }
}

# ::math::geometry::calculateDistanceToLineSegmentImpl
#
#       PRIVATE FUNCTION USED BY OTHER FUNCTIONS.
#       Find the distance between a point and a line.
#
# Arguments:
#       P             a point
#       linesegment   a line segment A->B
#
# Results:
#       dist          the smallest distance between P and the line
#       r             r has the following meaning:
#                        r=0      P = A
#                        r=1      P = B
#                        r<0      P is on the backward extension of AB
#                        r>1      P is on the forward extension of AB
#                        0<r<1    P is interior to AB
#
proc ::math::geometry::calculateDistanceToLineSegmentImpl {P linesegment} {
    # solution based on FAQ 1.02 on comp.graphics.algorithms
    # L = sqrt( (Bx-Ax)^2 + (By-Ay)^2 )
    #     (Ay-Cy)(Bx-Ax)-(Ax-Cx)(By-Ay)
    # s = -----------------------------
    #                 L^2
    #      (Cx-Ax)(Bx-Ax) + (Cy-Ay)(By-Ay)
    # r = -------------------------------
    #                   L^2
    # dist = |s|*L
    #
    # =>
    # 
    #        | (Ay-Cy)(Bx-Ax)-(Ax-Cx)(By-Ay) |
    # dist = ---------------------------------
    #                       L
    set Ax [lindex $linesegment 0]
    set Ay [lindex $linesegment 1]
    set Bx [lindex $linesegment 2]
    set By [lindex $linesegment 3]
    set Cx [lindex $P 0]
    set Cy [lindex $P 1]
    if {$Ax==$Bx && $Ay==$By} {
	return [list [dist $Cx $Cy $Ax $Ay] 0]
    } else {
	set L [expr {sqrt(pow($Bx-$Ax,2) + pow($By-$Ay,2))}]
	set r [expr {(($Cx-$Ax)*($Bx-$Ax) + ($Cy-$Ay)*($By-$Ay))/pow($L,2)}]
	return [list [expr {abs(($Ay-$Cy)*($Bx-$Ax)-($Ax-$Cx)*($By-$Ay)) / $L}] $r]
    }
}

# ::math::geometry::findClosestPointOnLineSegment
#
#       Return the point on a line segment which is closest to a given point.
#
# Arguments:
#       P             a point
#       linesegment   a line segment
#
# Results:
#       Q             the point on the line segment that has the
#                     smallest distance to P
#
# Examples:
#     - findClosestPointOnLineSegment {5 10} {0 0 10 10}
#       Result: 7.5 7.5
#     - findClosestPointOnLineSegment {-10 0} {0 0 10 10}
#       Result: 0 0
#
proc ::math::geometry::findClosestPointOnLineSegment {P linesegment} {
    set result [findClosestPointOnLineImpl $P $linesegment]
    set Q [lindex $result 0]
    set r [lindex $result 1]
    if {$r<0} {
	return [lrange $linesegment 0 1]
    } elseif {$r>1} {
	return [lrange $linesegment 2 3]
    } else {
	return $Q
    }

}

# ::math::geometry::calculateDistanceToPolyline
#
#       Calculate the distance between a point and a polyline.
#
# Arguments:
#       P           a point
#       polyline    a polyline
#
# Results:
#       dist        the smallest distance between P and any point
#                   on the polyline
#
# Examples:
#     - calculateDistanceToPolyline {10 10} {0 0 10 5 20 0}
#       Result: 5.0
#     - calculateDistanceToPolyline {5 10} {0 0 10 5 20 0}
#       Result: 6.7082039325
#
proc ::math::geometry::calculateDistanceToPolyline {P polyline} {
    set minDist "none"
    foreach {Ax Ay} [lrange $polyline 0 end-2] {Bx By} [lrange $polyline 2 end] {
	set dist [calculateDistanceToLineSegment $P [list $Ax $Ay $Bx $By]]
	if {$minDist=="none" || $dist < $minDist} {
	    set minDist $dist
	}
    }
    return $minDist
}

# ::math::geometry::findClosestPointOnPolyline
#
#       Return the point on a polyline which is closest to a given point.
#
# Arguments:
#       P           a point
#       polyline    a polyline
#
# Results:
#       Q           the point on the polyline that has the smallest
#                   distance to P
#
# Examples:
#     - findClosestPointOnPolyline {10 10} {0 0 10 5 20 0}
#       Result: 10 5
#     - findClosestPointOnPolyline {5 10} {0 0 10 5 20 0}
#       Result: 8.0 4.0
#
proc ::math::geometry::findClosestPointOnPolyline {P polyline} {
    set closestPoint "none"
    foreach {Ax Ay} [lrange $polyline 0 end-2] {Bx By} [lrange $polyline 2 end] {
	set Q [findClosestPointOnLineSegment $P [list $Ax $Ay $Bx $By]]
	set dist [lengthOfPolyline [concat $P $Q]]
	if {$closestPoint=="none" || $dist<$closestDistance} {
	    set closestPoint $Q
	    set closestDistance $dist
	}
    }
    return $closestPoint
}






# ::math::geometry::lengthOfPolyline
#
#       Find the length of a polyline, i.e., the sum of the
#       lengths of the individual line segments.
#
# Arguments:
#       polyline      a polyline
#
# Results:
#       length        the length of the polyline
#
# Examples:
#     - lengthOfPolyline {0 0 5 0 5 10}
#       Result: 15.0
#
proc ::math::geometry::lengthOfPolyline {polyline} {
    set length 0
    foreach {x1 y1} [lrange $polyline 0 end-2] {x2 y2} [lrange $polyline 2 end] {
	set length [expr {$length + sqrt(($x1-$x2)*($x1-$x2) + ($y1-$y2)*($y1-$y2))}]
    }
    return $length
}




# ::math::geometry::movePointInDirection
#
#       Return the point which is w units away from (x,y) in direction alpha.
#
# Arguments:
#       P             the starting point
#       direction     the direction from P
#                     The direction is in 360-degrees going counter-clockwise,
#                     with "straight right" being 0 degrees
#       dist          the distance from P
#
# Results:
#       Q             the point which is found by starting in P and going
#                     in the given direction, until the distance between
#                     P and Q is dist
#
# Examples:
#     - movePointInDirection {0 0} 45.0 10
#       Result: 7.07106781187 7.07106781187
#
proc ::math::geometry::movePointInDirection {P direction dist} {
    set x [lindex $P 0]
    set y [lindex $P 1]
    set pi [expr {4*atan(1)}]
    set xt [expr {$x + $dist*cos(($direction*$pi)/180)}]
    set yt [expr {$y + $dist*sin(($direction*$pi)/180)}]
    return [list $xt $yt]
}


# ::math::geometry::angle
#
#       Calculates angle from the horizon (0,0)->(1,0) to a line.
#
# Arguments:
#       line          a line defined by two points A and B
#
# Results:
#       angle         the angle between the line (0,0)->(1,0) and (Ax,Ay)->(Bx,By).
#                     Angle is in 360-degrees going counter-clockwise
#
# Examples:
#     - angle {10 10 15 13}
#       Result: 30.9637565321
#
proc ::math::geometry::angle {line} {
    set x1 [lindex $line 0]
    set y1 [lindex $line 1]
    set x2 [lindex $line 2]
    set y2 [lindex $line 3]
    # - handle vertical lines
    if {$x1==$x2} {if {$y1<$y2} {return 90} else {return 270}}
    # - handle other lines
    set a [expr {atan(abs((1.0*$y1-$y2)/(1.0*$x1-$x2)))}] ; # a is between 0 and pi/2
    set pi [expr {4*atan(1)}]
    if {$y1<=$y2} {
	# line is going upwards
	if {$x1<$x2} {set b $a} else {set b [expr {$pi-$a}]}
    } else {
	# line is going downwards
	if {$x1<$x2} {set b [expr {2*$pi-$a}]} else {set b [expr {$pi+$a}]}
    }
    return [expr {$b/$pi*180}] ; # convert b to degrees
}




###
#
# Intersection procedures
#
###

# ::math::geometry::lineSegmentsIntersect
#
#       Checks whether two line segments intersect.
#
# Arguments:
#       linesegment1  the first line segment
#       linesegment2  the second line segment
#
# Results:
#       dointersect   a boolean saying whether the line segments intersect
#                     (i.e., have any points in common)
#
# Examples:
#     - lineSegmentsIntersect {0 0 10 10} {0 10 10 0}
#       Result: 1
#     - lineSegmentsIntersect {0 0 10 10} {20 20 20 30}
#       Result: 0
#     - lineSegmentsIntersect {0 0 10 10} {10 10 15 15}
#       Result: 1
#
proc ::math::geometry::lineSegmentsIntersect {linesegment1 linesegment2} {
    ...
}

# ::math::geometry::findLineSegmentIntersection
#
#       Returns the intersection point of two line segments.
#       Note: may also return "coincident" and "none".
#
# Arguments:
#       linesegment1  the first line segment
#       linesegment2  the second line segment
#
# Results:
#       P             the intersection point of linesegment1 and linesegment2.
#                     If linesegment1 and linesegment2 have an infinite number
#                     of points in common, the procedure returns "coincident".
#                     If there are no intersection points, the procedure
#                     returns "none".
#
# Examples:
#     - findLineSegmentIntersection {0 0 10 10} {0 10 10 0}
#       Result: 5.0 5.0
#     - findLineSegmentIntersection {0 0 10 10} {20 20 20 30}
#       Result: none
#     - findLineSegmentIntersection {0 0 10 10} {10 10 15 15}
#       Result: 10.0 10.0
#     - findLineSegmentIntersection {0 0 10 10} {5 5 15 15}
#       Result: coincident
#
proc ::math::geometry::findLineSegmentIntersection {linesegment1 linesegment2} {
    ...
}

# ::math::geometry::findLineIntersection {line1 line2}
#
#       Returns the intersection point of two lines.
#       Note: may also return "coincident" and "none".
#
# Arguments:
#       line1         the first line
#       line2         the second line
#
# Results:
#       P             the intersection point of line1 and line2.
#                     If line1 and line2 have an infinite number of points
#                     in common, the procedure returns "coincident".
#                     If there are no intersection points, the procedure
#                     returns "none".
#
# Examples:
#     - findLineIntersection {0 0 10 10} {0 10 10 0}
#       Result: 5.0 5.0
#     - findLineIntersection {0 0 10 10} {20 20 20 30}
#       Result: 20.0 20.0
#     - findLineIntersection {0 0 10 10} {10 10 15 15}
#       Result: coincident
#     - findLineIntersection {0 0 10 10} {5 5 15 15}
#       Result: coincident
#     - findLineIntersection {0 0 10 10} {1 1 11 11}
#       Result: none
#
proc ::math::geometry::findLineIntersection {line1 line2} {
    ...
}


# ::math::geometry::polylinesIntersect
#
#       Checks whether two polylines intersect.
#
# Arguments;
#       polyline1     the first polyline
#       polyline2     the second polyline
#
# Results:
#       dointersect   a boolean saying whether the polylines intersect
#
# Examples:
#     - polylinesIntersect {0 0 10 10 10 20} {0 10 10 0}
#       Result: 1
#     - polylinesIntersect {0 0 10 10 10 20} {5 4 10 4}
#       Result: 0
#
proc ::math::geometry::polylinesIntersect {polyline1 polyline2} {
    ...
}

# ::math::geometry::polylinesBoundingIntersect
#
#       Check whether two polylines intersect, but reduce
#       the correctness of the result to the given granularity.
#       Use this for faster, but weaker, intersection checking.
#
#       How it works:
#          Each polyline is split into a number of smaller polylines,
#          consisting of granularity points each. If a pair of those smaller
#          lines' bounding boxes intersect, then this procedure returns 1,
#          otherwise it returns 0.
#
# Arguments:
#       polyline1     the first polyline
#       polyline2     the second polyline
#       granularity   the number of points in each part-polyline
#                     granularity<=1 means full correctness
#
# Results:
#       dointersect   a boolean saying whether the polylines intersect
#
# Examples:
#     - polylinesBoundingIntersect {0 0 10 10 10 20} {0 10 10 0} 2
#       Result: 1
#     - polylinesBoundingIntersect {0 0 10 10 10 20} {5 4 10 4} 2
#       Result: 1
#
proc ::math::geometry::polylinesBoundingIntersect {polyline1 polyline2 granularity} {
    ...
}

# ::math::geometry::ccw
#
#       PRIVATE FUNCTION USED BY OTHER FUNCTIONS.
#       Returns whether traversing from A to B to C is CounterClockWise
#       Algorithm by Sedgewick.
#
# Arguments:
#       A             first point
#       B             second point
#       C             third point
#
# Reeults:
#       ccw           a boolean saying whether traversing from A to B to C
#                     is CounterClockWise
#
proc ::math::geometry::ccw {A B C} {
    set dx1 [expr {$p1x - $p0x}]
    set dy1 [expr {$p1y - $p0y}]
    set dx2 [expr {$p2x - $p0x}]
    set dy2 [expr {$p2y - $p0y}]
    if {$dx1*$dy2 > $dy1*$dx2} {return 1}
    if {$dx1*$dy2 < $dy1*$dx2} {return -1}
    if {($dx1*$dx2 < 0) || ($dy1*$dy2 < 0)} {return -1}
    if {($dx1*$dx1 + $dy1*$dy1) < ($dx2*$dx2+$dy2*$dy2)} {return 1}
    return 0
}







###
#
# Overlap procedures
#
###

# ::math::geometry::intervalsOverlap
#
#       Check whether two intervals overlap.
#       Examples:
#         - (2,4) and (5,3) overlap with strict=0 and strict=1
#         - (2,4) and (1,2) overlap with strict=0 but not with strict=1
#
# Arguments:
#       y1,y2         the first interval
#       y3,y4         the second interval
#       strict        choosing strict or non-strict interpretation
#
# Results:
#       dooverlap     a boolean saying whether the intervals overlap
#
# Examples:
#     - intervalsOverlap 2 4 4 6 1
#       Result: 0
#     - intervalsOverlap 2 4 4 6 0
#       Result: 1
#     - intervalsOverlap 4 2 3 5 0
#       Result: 1
#
proc ::math::geometry::intervalsOverlap {y1 y2 y3 y4 strict} {
    if {$y1>$y2} {
	set temp $y1
	set y1 $y2
	set y2 $temp
    }
    if {$y3>$y4} {
	set temp $y3
	set y3 $y4
	set y4 $temp
    }
    if {$strict} {
	return [expr {$y2>$y3 && $y4>$y1}]
    } else {
	return [expr {$y2>=$y3 && $y4>=$y1}]
    }
}

# ::math::geometry::rectanglesOverlap
#
#       Check whether two rectangles overlap (see also intervalsOverlap).
#
# Arguments:
#       P1            upper-left corner of the first rectangle
#       P2            lower-right corner of the first rectangle
#       Q1            upper-left corner of the second rectangle
#       Q2            lower-right corner of the second rectangle
#       strict        choosing strict or non-strict interpretation
#
# Results:
#       dooverlap     a boolean saying whether the rectangles overlap
#
# Examples:
#     - rectanglesOverlap {0 10} {10 0} {10 10} {20 0} 1
#       Result: 0
#     - rectanglesOverlap {0 10} {10 0} {10 10} {20 0} 0
#       Result: 1
#
proc ::math::geometry::rectanglesOverlap {P1 P2 Q1 Q2 strict} {
    set b1x1 [lindex $P1 0]
    set b1y1 [lindex $P1 1]
    set b1x2 [lindex $P2 0]
    set b1y2 [lindex $P2 1]
    set b2x1 [lindex $Q1 0]
    set b2y1 [lindex $Q1 1]
    set b2x2 [lindex $Q2 0]
    set b2y2 [lindex $Q2 1]
    # ensure b1x1<=b1x2 etc.
    if {$b1x1 > $b1x2} {
	set temp $b1x1
	set b1x1 $b1x2
	set b1x2 $temp
    }
    if {$b1y1 > $b1y2} {
	set temp $b1y1
	set b1y1 $b1y2
	set b1y2 $temp
    }
    if {$b2x1 > $b2x2} {
	set temp $b2x1
	set b2x1 $b2x2
	set b2x2 $temp
    }
    if {$b2y1 > $b2y2} {
	set temp $b2y1
	set b2y1 $b2y2
	set b2y2 $temp
    }
    # Check if the boxes intersect
    # (From: Cormen, Leiserson, and Rivests' "Algorithms", page 889)
    if {$strict} {
	return [expr {($b1x2>$b2x1) && ($b2x2>$b1x1) \
		&& ($b1y2>$b2y1) && ($b2y2>$b1y1)}]
    } else {
	return [expr {($b1x2>=$b2x1) && ($b2x2>=$b1x1) \
		&& ($b1y2>=$b2y1) && ($b2y2>=$b1y1)}]
    }
}




package provide math::geometry 1.0



# Which of the following procedures are of general relevance and should
# thus be included in the math::geometry module?
if 0 {
    # angle (x1 y1 x2 y2): angle from the perpendicular to the line 
    # through (x1,y1) & (x2,y2) in radients
    public proc vangle {x1 y1 x2 y2}
    
    # returns the point placed in the middle of (x1,y1) and (x2,y2)
    public proc middle {x1 y1 x2 y2}

    #
    public proc bbox {coords}
    public proc verticallyInBbox {bbox x}
    public proc horizontallyInBbox {bbox y}
    public proc closestToWhichBboxSide {x y bbox}
    public proc closestToWhichBboxSides {x y bbox}

    # convert a list of reals to a list of integers (floor)
    public proc reals2integers {reallist}

    #
    public proc lineIsHorizontal {x1 y1 x2 y2}
    public proc lineIsVertical   {x1 y1 x2 y2}

    #
    public proc moveby {coords dx dy}
    public proc scaleby {coords scalex scaley}
    public proc mapBy {coords offsetX offsetY scale}

    # roundRect
    public proc roundRect {canvas x0 y0 x3 y3 radius args}
    # Same as roundRect, only "item" is not created by updated
    public proc updateRoundRect {canvas item x0 y0 x3 y3 radius args}
    # Calculates polygon coordinates for a rounded rectangle
    public proc getRoundRectCoords {x0 y0 x3 y3 radius approximateSmoothness}

    # containedInOval: takes an oval item, a canvas, and a point,
    # and returns 1 if the point is contained in the canvas
    public proc containedInOval {oval canvas x y}

    # makeStippleLine: takes one long polyline and returns a list of small line 
    # segments, which together forms a stippled line
    # - solidLength: length of the individual line segments
    # - spaceLength: length between the line segments
    # (note: none of the numbers need to be integers)
    public proc makeStippleLine {coords solidLength spaceLength }

    # normalizeLine: splits the line segment (x1,y1)->(x2,y2) into smaller
    # line segments, so that each line segment is max dist long.
    public proc normalizeLine {x1 y1 x2 y2 dist}
    # repeats normalizeLine for a polyline
    public proc normalizePolyline {coords dist}

    # returns whether x,y is inside the box defined by b1,b2
    public proc PointInBox {x y bx1 by1 bx2 by2}

    # returns the edge-point {x y} of the box (x1,y1) (top left)
    # with width w and height h closest to (logx,logy)
    public proc findClosestBoxEdgePoint {x1 y1 w h logx logy}

    # returns the distance from (px,py) to the box (x1,y1) (top left)
    # with width w and height h (bottom right) 
    public proc boxEdgeDist {x1 y1 w h px py}

    #
    public proc makeBbox {p1 p2 w}
    public proc makeLines {p1 p2 w l}

    ###
    # Logical <-> abs
    #
    # Supports translation between two coordinate systems, where the one coordinate
    # system is defined by the other coordinate system + an offset point + a zoom factor
    ###
    public proc logical2absList {coordList logicalXStart logicalYStart zoomFactor}
    public proc abs2logicalList {coordList logicalXStart logicalYStart zoomFactor}
    public proc abs2logicalDistance {absdistance zoomFactor}
    public proc logical2absDistance {distance zoomFactor}

    # Do the first box contain the second box?
    # If lessThan is false, the second box must be properly inside the first box
    public proc boxContains {b1x1 b1y1 b1x2 b1y2 b2x1 b2y1 b2x2 b2y2 lessThan}

    # Returns a point on the edge of the box: where the line intersects the box. 
    #
    # If the line intersects the box in more than one point, the point 
    # closest to the end point (x2,y2) is chosen.
    #
    # If the line segment (x1,y1)->(x2,y2) does not intersect
    # this class, then "none" is returned.
    public proc findBoxIntersectionPoint {x1 y1 x2 y2 bx1 by1 w h}

    # polylineIntersectsBox
    #
    public proc polylineIntersectsBox {polyline bx1 by1 bx2 by2}

    # box inside polygon?
    public proc boxContainedInPolyline {bx1 by1 bx2 by2 polyline}

    #
    public proc lineIntersectsWithPolyline {p1 p2 polyline}
}

