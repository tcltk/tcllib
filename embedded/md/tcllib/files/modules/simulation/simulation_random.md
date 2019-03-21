
[//000000001]: # (simulation::random - Tcl Simulation Tools)
[//000000002]: # (Generated from file 'simulation_random.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (simulation::random(n) 0.1 tcllib "Tcl Simulation Tools")

# NAME

simulation::random - Pseudo-random number generators

# <a name='toc'></a>Table Of Contents

  -  [Table Of Contents](#toc)

  -  [Synopsis](#synopsis)

  -  [Description](#section1)

  -  [PROCEDURES](#section2)

  -  [Keywords](#keywords)

  -  [Category](#category)

  -  [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl ?8.4?  
package require simulation::random 0.1  

[__::simulation::random::prng_Bernoulli__ *p*](#1)  
[__::simulation::random::prng_Discrete__ *n*](#2)  
[__::simulation::random::prng_Poisson__ *lambda*](#3)  
[__::simulation::random::prng_Uniform__ *min* *max*](#4)  
[__::simulation::random::prng_Exponential__ *min* *mean*](#5)  
[__::simulation::random::prng_Normal__ *mean* *stdev*](#6)  
[__::simulation::random::prng_Pareto__ *min* *steep*](#7)  
[__::simulation::random::prng_Gumbel__ *min* *f*](#8)  
[__::simulation::random::prng_chiSquared__ *df*](#9)  
[__::simulation::random::prng_Disk__ *rad*](#10)  
[__::simulation::random::prng_Sphere__ *rad*](#11)  
[__::simulation::random::prng_Ball__ *rad*](#12)  
[__::simulation::random::prng_Rectangle__ *length* *width*](#13)  
[__::simulation::random::prng_Block__ *length* *width* *depth*](#14)  

# <a name='description'></a>DESCRIPTION

This package consists of commands to generate pseudo-random number generators.
These new commands deliver

  - numbers that are distributed normally, uniformly, according to a Pareto or
    Gumbel distribution and so on

  - coordinates of points uniformly spread inside a sphere or a rectangle

For example:

    set p [::simulation::random::prng_Normal -1.0 10.0]

produces a new command (whose name is stored in the variable "p") that generates
normally distributed numbers with a mean of -1.0 and a standard deviation of
10.0.

# <a name='section2'></a>PROCEDURES

The package defines the following public procedures for *discrete*
distributions:

  - <a name='1'></a>__::simulation::random::prng_Bernoulli__ *p*

    Create a command (PRNG) that generates numbers with a Bernoulli
    distribution: the value is either 1 or 0, with a chance p to be 1

      * float *p*

        Chance the outcome is 1

  - <a name='2'></a>__::simulation::random::prng_Discrete__ *n*

    Create a command (PRNG) that generates numbers 0 to n-1 with equal
    probability.

      * int *n*

        Number of different values (ranging from 0 to n-1)

  - <a name='3'></a>__::simulation::random::prng_Poisson__ *lambda*

    Create a command (PRNG) that generates numbers according to the Poisson
    distribution.

      * float *lambda*

        Mean number per time interval

The package defines the following public procedures for *continuous*
distributions:

  - <a name='4'></a>__::simulation::random::prng_Uniform__ *min* *max*

    Create a command (PRNG) that generates uniformly distributed numbers between
    "min" and "max".

      * float *min*

        Minimum number that will be generated

      * float *max*

        Maximum number that will be generated

  - <a name='5'></a>__::simulation::random::prng_Exponential__ *min* *mean*

    Create a command (PRNG) that generates exponentially distributed numbers
    with a given minimum value and a given mean value.

      * float *min*

        Minimum number that will be generated

      * float *mean*

        Mean value for the numbers

  - <a name='6'></a>__::simulation::random::prng_Normal__ *mean* *stdev*

    Create a command (PRNG) that generates normally distributed numbers with a
    given mean value and a given standard deviation.

      * float *mean*

        Mean value for the numbers

      * float *stdev*

        Standard deviation

  - <a name='7'></a>__::simulation::random::prng_Pareto__ *min* *steep*

    Create a command (PRNG) that generates numbers distributed according to
    Pareto with a given minimum value and a given distribution steepness.

      * float *min*

        Minimum number that will be generated

      * float *steep*

        Steepness of the distribution

  - <a name='8'></a>__::simulation::random::prng_Gumbel__ *min* *f*

    Create a command (PRNG) that generates numbers distributed according to
    Gumbel with a given minimum value and a given scale factor. The probability
    density function is:

    P(v) = exp( -exp(f*(v-min)))

      * float *min*

        Minimum number that will be generated

      * float *f*

        Scale factor for the values

  - <a name='9'></a>__::simulation::random::prng_chiSquared__ *df*

    Create a command (PRNG) that generates numbers distributed according to the
    chi-squared distribution with df degrees of freedom. The mean is 0 and the
    standard deviation is 1.

      * float *df*

        Degrees of freedom

The package defines the following public procedures for random point sets:

  - <a name='10'></a>__::simulation::random::prng_Disk__ *rad*

    Create a command (PRNG) that generates (x,y)-coordinates for points
    uniformly spread over a disk of given radius.

      * float *rad*

        Radius of the disk

  - <a name='11'></a>__::simulation::random::prng_Sphere__ *rad*

    Create a command (PRNG) that generates (x,y,z)-coordinates for points
    uniformly spread over the surface of a sphere of given radius.

      * float *rad*

        Radius of the disk

  - <a name='12'></a>__::simulation::random::prng_Ball__ *rad*

    Create a command (PRNG) that generates (x,y,z)-coordinates for points
    uniformly spread within a ball of given radius.

      * float *rad*

        Radius of the ball

  - <a name='13'></a>__::simulation::random::prng_Rectangle__ *length* *width*

    Create a command (PRNG) that generates (x,y)-coordinates for points
    uniformly spread over a rectangle.

      * float *length*

        Length of the rectangle (x-direction)

      * float *width*

        Width of the rectangle (y-direction)

  - <a name='14'></a>__::simulation::random::prng_Block__ *length* *width* *depth*

    Create a command (PRNG) that generates (x,y,z)-coordinates for points
    uniformly spread over a block

      * float *length*

        Length of the block (x-direction)

      * float *width*

        Width of the block (y-direction)

      * float *depth*

        Depth of the block (z-direction)

# <a name='keywords'></a>KEYWORDS

[math](../../../../index.md#math), [random
numbers](../../../../index.md#random_numbers),
[simulation](../../../../index.md#simulation), [statistical
distribution](../../../../index.md#statistical_distribution)

# <a name='category'></a>CATEGORY

Mathematics

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2004 Arjen Markus <arjenmarkus@users.sourceforge.net>
