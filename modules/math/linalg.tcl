# linalg.tcl --
#    Linear algebra package, based partly on Hume's LA package,
#    partly on experiments with various representations of
#    matrices. Also the functionality of the BLAS library has
#    been taken into account.
#
#    General information:
#    - The package provides both a high-level general interface and
#      a lower-level specific interface for various LA functions
#      and tasks.
#    - The general procedures perform some checks and then call
#      the various specific procedures. The general procedures are
#      aimed for robustness.
#    - The specific procedures do not check anything, they are
#      designed for speed. Failure to comply to the interface
#      requirements will presumably lead to [expr] errors.
#    - Vectors are represented as lists, matrices as lists of
#      lists, where the rows are the innermost lists:
#
#      / a11 a12 a13 \
#      | a21 a22 a23 | == { {a11 a12 a13} {a21 a22 a23} {a31 a32 a33} }
#      \ a31 a32 a33 /
#

namespace eval ::math::linearalgebra {
    # Define the namespace
    namespace export dim shape
    namespace export norm norm_one norm_two norm_max
    namespace export dotproduct normalize
    namespace export axpy axpy_vect axpy_mat
    namespace export add add_vect add_mat
    namespace export sub sub_vect sub_mat
    namespace export scale scale_vect scale_mat
    namespace export rotate
    namespace export getrow getcol getelem setrow setcol setelem
    namespace export mkVector mkMatrix mkIdentity mkDiag
    namespace export mkHilbert mkDingdong mkBorder mkFrank
    namespace export solveGauss solveTriangular
}

# dim --
#     Return the dimension of an object (scalar, vector or matrix)
# Arguments:
#     obj        Object like a scalar, vector or matrix
# Result:
#     Dimension: 0 for a scalar, 1 for a vector, 2 for a matrix
#
proc ::math::linearalgebra::dim { obj } {
    return [llength [shape $obj]]
}

# shape --
#     Return the shape of an object (scalar, vector or matrix)
# Arguments:
#     obj        Object like a scalar, vector or matrix
# Result:
#     List of the sizes: empty list for a scalar, number of components
#     for a vector, number of rows and columns for a matrix
#
proc ::math::linearalgebra::shape { obj } {
    if { [llength $obj] <= 1 } {
       return {}
    }
    set result [llength $obj]
    if { [llength [lindex $obj 0]] <= 1 } {
       return $result
    } else {
       lappend result [llength [lindex $obj 0]]
    }
    return $result
}

# norm --
#     Compute the (1-, 2- or Inf-) norm of a vector
# Arguments:
#     vector     Vector (list of numbers)
#     type       Either 1, 2 or max/inf to indicate the type of
#                norm (default: 2, the euclidean norm)
# Result:
#     The (1-, 2- or Inf-) norm of a vector
#
proc ::math::linearalgebra::norm { vector {type 2} } {
    if { $type == 2 } {
       return [norm_two $vector]
    }
    if { $type == 1 } {
       return [norm_one $vector]
    }
    if { $type == "max" || $type == "inf" } {
       return [norm_max $vector]
    }
    return -code error "Unknown norm: $type"
}

# norm_one --
#     Compute the 1-norm of a vector
# Arguments:
#     vector     Vector
# Result:
#     The 1-norm of a vector
#
proc ::math::linearalgebra::norm_one { vector } {
    set sum 0.0
    foreach c $vector {
        set sum [expr {$sum+abs($c)}]
    }
    return $sum
}

# norm_two --
#     Compute the 2-norm of a vector (euclidean norm)
# Arguments:
#     vector     Vector
# Result:
#     The 2-norm of a vector
# Note:
#     Rely on the function hypot() to make this robust
#     against overflow and underflow
#
proc ::math::linearalgebra::norm_two { vector } {
    set sum 0.0
    foreach c $vector {
        set sum [expr {hypot($c,$sum)}]
    }
    return $sum
}

# norm_max --
#     Compute the inf-norm of a vector (maximum of its components)
# Arguments:
#     vector     Vector
# Result:
#     The inf-norm of a vector
#
proc ::math::linearalgebra::norm_max { vector } {
    set max [lindex $vector 0]
    foreach c $vector {
        set max [expr {abs($c)>$max? abs($c) : $max}]
    }
    return $max
}

# dotproduct --
#     Compute the dot product of two vectors
# Arguments:
#     vect1      First vector
#     vect2      Second vector
# Result:
#     The dot product of the two vectors
#
proc ::math::linearalgebra::dotproduct { vect1 vect2 } {
    if { [llength $vect1] != [llength $vect2] } {
       return -code error "Vectors must be of equal length"
    }
    set sum 0.0
    foreach c1 $vect1 c2 $vect2 {
        set sum [expr {$sum + $c1*$c2}]
    }
    return $sum
}

# axpy --
#     Compute the sum of a scaled vector/matrix and another
#     vector/matrix: a*x + y
# Arguments:
#     scale      Scale factor (a) for the first vector/matrix
#     mv1        First vector/matrix (x)
#     mv2        Second vector/matrix (y)
# Result:
#     The result of a*x+y
#
proc ::math::linearalgebra::axpy { scale mv1 mv2 } {
    if { [llength [lindex $mv1 0]] > 1 } {
        return [axpy_mat $scale $mv1 $mv2]
    } else {
        return [axpy_vect $scale $mv1 $mv2]
    }
}

# axpy_vect --
#     Compute the sum of a scaled vector and another vector: a*x + y
# Arguments:
#     scale      Scale factor (a) for the first vector
#     vect1      First vector (x)
#     vect2      Second vector (y)
# Result:
#     The result of a*x+y
#
proc ::math::linearalgebra::axpy_vect { scale vect1 vect2 } {
    set result {}

    foreach c1 $vect1 c2 $vect2 {
        lappend result [expr {$scale*$c1+$c2}]
    }
    return $result
}

# axpy_mat --
#     Compute the sum of a scaled matrix and another matrix: a*x + y
# Arguments:
#     scale      Scale factor (a) for the first matrix
#     mat1       First matrix (x)
#     mat2       Second matrix (y)
# Result:
#     The result of a*x+y
#
proc ::math::linearalgebra::axpy_mat { scale mat1 mat2 } {
    set result {}
    foreach row1 $mat1 row2 $mat2 {
        lappend result [axpy_vect $scale $row1 $row2]
    }
    return $result
}

# add --
#     Compute the sum of two vectors/matrices
# Arguments:
#     mv1        First vector/matrix (x)
#     mv2        Second vector/matrix (y)
# Result:
#     The result of x+y
#
proc ::math::linearalgebra::add { mv1 mv2 } {
    if { [llength [lindex $mv1 0]] > 1 } {
        return [add_mat $mv1 $mv2]
    } else {
        return [add_vect $mv1 $mv2]
    }
}

# add_vect --
#     Compute the sum of two vectors
# Arguments:
#     vect1      First vector (x)
#     vect2      Second vector (y)
# Result:
#     The result of x+y
#
proc ::math::linearalgebra::add_vect { vect1 vect2 } {
    set result {}
    foreach c1 $vect1 c2 $vect2 {
        lappend result [expr {$c1+$c2}]
    }
    return $result
}

# add_mat --
#     Compute the sum of two matrices
# Arguments:
#     mat1       First matrix (x)
#     mat2       Second matrix (y)
# Result:
#     The result of x+y
#
proc ::math::linearalgebra::add_mat { mat1 mat2 } {
    set result {}
    foreach row1 $mat1 row2 $mat2 {
        lappend result [add_vect $row1 $row2]
    }
    return $result
}

# sub --
#     Compute the difference of two vectors/matrices
# Arguments:
#     mv1        First vector/matrix (x)
#     mv2        Second vector/matrix (y)
# Result:
#     The result of x-y
#
proc ::math::linearalgebra::sub { mv1 mv2 } {
    if { [llength [lindex $mv1 0]] > 0 } {
        return [sub_mat $mv1 $mv2]
    } else {
        return [sub_vect $mv1 $mv2]
    }
}

# sub_vect --
#     Compute the difference of two vectors
# Arguments:
#     vect1      First vector (x)
#     vect2      Second vector (y)
# Result:
#     The result of x-y
#
proc ::math::linearalgebra::sub_vect { vect1 vect2 } {
    set result {}
    foreach c1 $vect1 c2 $vect2 {
        lappend result [expr {$c1-$c2}]
    }
    return $result
}

# sub_mat --
#     Compute the difference of two matrices
# Arguments:
#     mat1       First matrix (x)
#     mat2       Second matrix (y)
# Result:
#     The result of x-y
#
proc ::math::linearalgebra::sub_mat { mat1 mat2 } {
    set result {}
    foreach row1 $mat1 row2 $mat2 {
        lappend result [sub_vect $row1 $row2]
    }
    return $result
}

# scale --
#     Scale a vector or a matrix
# Arguments:
#     scale      Scale factor (scalar; a)
#     mv         Vector/matrix (x)
# Result:
#     The result of a*x
#
proc ::math::linearalgebra::scale { scale mv } {
    if { [llength [lindex $mv 0]] > 1 } {
        return [scale_mat $scale $mv]
    } else {
        return [scale_vect $scale $mv]
    }
}

# scale_vect --
#     Scale a vector
# Arguments:
#     scale      Scale factor to apply (a)
#     vect       Vector to be scaled (x)
# Result:
#     The result of a*x
#
proc ::math::linearalgebra::scale_vect { scale vect } {
    set result {}
    foreach c $vect {
        lappend result [expr {$scale*$c}]
    }
    return $result
}

# scale_mat --
#     Scale a matrix
# Arguments:
#     scale      Scale factor to apply
#     mat        Matrix to be scaled
# Result:
#     The result of x+y
#
proc ::math::linearalgebra::scale_mat { scale mat } {
    set result {}
    foreach row $mat {
        lappend result [scale_vect $scale $row]
    }
    return $result
}

# rotate --
#     Apply a planar rotation to two vectors
# Arguments:
#     c          Cosine of the angle
#     s          Sine of the angle
#     vect1      First vector (x)
#     vect2      Second vector (y)
# Result:
#     A list of two elements: c*x-s*y and s*x+c*y
#
proc ::math::linearalgebra::rotate { c s vect1 vect2 } {
    set result1 {}
    set result2 {}
    foreach v1 $vect1 v2 $vect2 {
        lappend result1 [expr {$c*$v1-$s*$v2}]
        lappend result1 [expr {$s*$v1+$c*$v2}]
    }
    return [list $result1 $result2]
}

# transpose --
#     Transpose a matrix
# Arguments:
#     matrix     Matrix to be transposed
# Result:
#     The transposed matrix
#
proc transpose { matrix } {
   set row {}
   set transpose {}
   foreach c [lindex $matrix 0] {
      lappend row 0.0
   }
   foreach r $matrix {
      lappend transpose $row
   }

   set nr 0
   foreach r $matrix {
      set nc 0
      foreach c $r {
         lset transpose $nc $nr $c
         incr nc
      }
      incr nr
   }
   return $transpose
}

# matmul_mv --
#     Multiply a matrix and a column vector
# Arguments:
#     matrix     Matrix (applied left: A)
#     vector     Vector (interpreted as column vector: x)
# Result:
#     The vector A*x
#
proc matmul_mv { matrix vector } {
   set newvect {}
   foreach row $matrix {
      set sum 0.0
      foreach v $vector c $row {
         set sum [expr {$sum+$v*$c}]
      }
      lappend newvect $sum
   }
   return $newvect
}

# mkVector --
#     Make a vector of a given size
# Arguments:
#     ndim       Dimension of the vector
#     value      Default value for all elements (default: 0.0)
# Result:
#     A list with ndim elements, representing a vector
#
proc ::math::linearalgebra::mkVector { ndim {value 0.0} } {
    set result {}

    while { $ndim >= 0 } {
        lappend result $value
        incr ndim -1
    }
    return $result
}

# mkMatrix --
#     Make a matrix of a given size
# Arguments:
#     nrows      Number of rows
#     ncols      Number of columns
#     value      Default value for all elements (default: 0.0)
# Result:
#     A nested list, representing an nrows x ncols matrix
#
proc ::math::linearalgebra::mkMatrix { nrows ncols {value 0.0} } {
    set result {}

    while { $nrows >= 0 } {
        lappend result [mkVector $ncols $value]
        incr nrows -1
    }
    return $result
}

# mkIdent --
#     Make an identity matrix of a given size
# Arguments:
#     size       Number of rows/columns
# Result:
#     A nested list, representing an size x size identity matrix
#
proc ::math::linearalgebra::mkIdentity { size } {
    set result [mkMatrix $size $size 0.0]

    while { $size > 0 } {
        incr size -1
        lset result $size $size 1.0
    }
    return $result
}

# mkDiag --
#     Make a diagonal matrix of a given size
# Arguments:
#     diag       List of values to appear on the diagonal
#
# Result:
#     A nested list, representing a diagonal matrix
#
proc ::math::linearalgebra::mkDiagonal { diag } {
    set size   [llength $diag]
    set result [mkMatrix $size $size 0.0]

    while { $size > 0 } {
        incr size -1
        lset result $size $size [lindex $diag $size]
    }
    return $result
}

# mkHilbert --
#     Make a Hilbert matrix of a given size
# Arguments:
#     size       Size of the matrix
# Result:
#     A nested list, representing a Hilbert matrix
# Notes:
#     Hilbert matrices are very ill-conditioned wrt
#     eigenvalue/eigenvector problems. Therefore they
#     are good candidates for testing the accuracy
#     of algorithms and implementations.
#
proc ::math::linearalgebra::mkHilbert { size } {
    set size   [llength $diag]

    set result {}
    for { set j 0 } { $j < $size } { incr j } {
        set row {}
        for { set i 0 } { $i < $size } { incr i } {
            lappend row [expr {1.0/($i+$j+1.0)}]
        }
        lappend result $row
    }
    return $result
}

# mkDingdong --
#     Make a Dingdong matrix of a given size
# Arguments:
#     size       Size of the matrix
# Result:
#     A nested list, representing a Dingdong matrix
# Notes:
#     Dingdong matrices are imprecisely represented,
#     but have the property of being very stable in
#     such algorithms as Gauss elimination.
#
proc ::math::linearalgebra::mkDingdong { size } {
    set result {}
    for { set j 0 } { $j < $size } { incr j } {
        set row {}
        for { set i 0 } { $i < $size } { incr i } {
            lappend row [expr {0.5/($size-$i-$j-0.5)}]
        }
        lappend result $row
    }
    return $result
}

# getrow --
#     Get the specified row from a matrix
# Arguments:
#     matrix     Matrix in question
#     row        Index of the row
#
# Result:
#     A list with the values on the requested row
#
proc ::math::linearalgebra::getrow { matrix row } {
    lindex $matrix $row
}

# setrow --
#     Set the specified row in a matrix
# Arguments:
#     matrix     _Name_ of matrix in question
#     row        Index of the row
#     newvalues  New values for the row
#
# Result:
#     Updated matrix
# Side effect:
#     The matrix is updated
#
proc ::math::linearalgebra::setrow { matrix row newvalues } {
    upvar $matrix mat
    lset mat $row $newvalues
    return $mat
}

# getcol --
#     Get the specified column from a matrix
# Arguments:
#     matrix     Matrix in question
#     col        Index of the column
#
# Result:
#     A list with the values on the requested column
#
proc ::math::linearalgebra::getcol { matrix col } {
    set result {}
    foreach r $matrix {
        lappend result [lindex $row $col]
    }
}

# setcol --
#     Set the specified column in a matrix
# Arguments:
#     matrix     _Name_ of matrix in question
#     col        Index of the column
#     newvalues  New values for the column
#
# Result:
#     Updated matrix
# Side effect:
#     The matrix is updated
#
proc ::math::linearalgebra::setcol { matrix col newvalues } {
    upvar $matrix mat
    for { set i 0 } { $i < [llength $mat] } { incr i } {
        lset mat $i $col [lindex $newvalues $i]
    }
    return $mat
}

# getelem --
#     Get the specified element (row,column) from a matrix
# Arguments:
#     matrix     Matrix in question
#     row        Index of the row
#     col        Index of the column
#
# Result:
#     The matrix element (row,column)
#
proc ::math::linearalgebra::getcol { matrix row col } {
    lindex $matrix $row $col
}

# setelem --
#     Set the specified element (row,column) in a matrix
# Arguments:
#     matrix     _Name_ of matrix in question
#     row        Index of the row
#     col        Index of the column
#     newvalue   New value  for the element
#
# Result:
#     Updated matrix
# Side effect:
#     The matrix is updated
#
proc ::math::linearalgebra::setelem { matrix row col newvalue } {
    upvar $matrix mat
    lset mat $row $col $newvalue
    return $mat
}

# solveGauss --
#     Solve a system of linear equations using Gauss elimination
# Arguments:
#     matrix     Matrix defining the coefficients
#     bvect      Right-hand side (may be several columns)
#
# Result:
#     Solution of the system or an error in case of singularity
#
proc ::math::linearalgebra::solveGauss { matrix bvect } {
    set norows [llength $matrix]
    set nocols $norows

    for { set i 0 } { $i < $nocols } { incr i } {
        set sweep_row   [getrow $matrix $i]
        set bvect_sweep [getrow $bvect  $i]
        # No pivoting yet
        set sweep_fact [lindex $sweep_row $i]
        for { set j [expr {$i+1}] } { $j < $norows } { incr j } {
            set current_row   [getrow $matrix $j]
            set bvect_current [getrow $bvect  $j]
            set factor      [expr {-[lindex $current_row $i]/$sweep_fact}]

            lset matrix $j [axpy_vect $factor $sweep_row   $current_row]
            lset bvect  $j [axpy_vect $factor $bvect_sweep $bvect_current]
        }
    }

    return [solveTriangular $matrix $bvect]
}

# solveTriangular --
#     Solve a system of linear equations where the matrix is
#     upper-triangular
# Arguments:
#     matrix     Matrix defining the coefficients
#     bvect      Right-hand side (may be several columns)
#
# Result:
#     Solution of the system or an error in case of singularity
#
proc ::math::linearalgebra::solveTriangular { matrix bvect } {
    set norows [llength $matrix]
    set nocols $norows

    for { set i [expr {$nocols-1}] } { $i >= 0 } { incr i -1 } {
        set sweep_row   [getrow $matrix $i]
        set bvect_sweep [getrow $bvect  $i]
        set sweep_fact  [lindex $sweep_row $i]
        set norm_fact   [expr {1.0/$sweep_fact-1.0}]

        lset bvect $i [axpy_vect $norm_fact $bvect_sweep $bvect_sweep]

        for { set j [expr {$i-1}] } { $j >= 0 } { incr j -1 } {
            set current_row   [getrow $matrix $j]
            set bvect_current [getrow $bvect  $j]
            set factor     [expr {-[lindex $current_row $i]/$sweep_fact}]

            lset bvect  $j [axpy_vect $factor $bvect_sweep $bvect_current]
        }
    }

    return $bvect
}

if { 0 } {
Te doen:
behoorlijke testen!
matmul
solveGauss_band
transpose (sneller?)
modified Gram-Schmidt
svd
join_col, join_row
de overige testmatrices uit Nash
}

if { 0 } {
set matrix {{1.0  2.0 -1.0}
            {3.0  1.1  0.5}
            {1.0 -2.0  3.0}}
set bvect  {{1.0  2.0 -1.0}
            {3.0  1.1  0.5}
            {1.0 -2.0  3.0}}
puts [join [::math::linearalgebra::solveGauss $matrix $bvect] \n]
set bvect  {{4.0   2.0}
            {12.0  1.2}
            {4.0  -2.0}}
puts [join [::math::linearalgebra::solveGauss $matrix $bvect] \n]
}

if { 0 } {

   set vect1 {1.0 2.0}
   set vect2 {3.0 4.0}
   ::math::linearalgebra::axpy_vect 1.0 $vect1 $vect2
   ::math::linearalgebra::add_vect      $vect1 $vect2
   puts [time {::math::linearalgebra::axpy_vect 1.0 $vect1 $vect2} 50000]
   puts [time {::math::linearalgebra::axpy_vect 2.0 $vect1 $vect2} 50000]
   puts [time {::math::linearalgebra::axpy_vect 1.0 $vect1 $vect2} 50000]
   puts [time {::math::linearalgebra::axpy_vect 1.1 $vect1 $vect2} 50000]
   puts [time {::math::linearalgebra::add_vect      $vect1 $vect2} 50000]
}
