## -*- tcl -*-
# ### ### ### ######### ######### #########
##
## C implementation for map::slippy
##
## See
##	http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Pseudo-Code
##
## for the coordinate conversions and other information.

# ### ### ### ######### ######### #########
## Requisites

package require critcl

critcl::tcl 8.6
critcl::license {Andreas Kupries} {BSD licensed.}

#package require critcl::cutil
#critcl::cutil::tracer on
#critcl::config trace
#critcl::debug symbols
#critcl::debug memory

# ### ### ### ######### ######### #########
## Custom argument and result processing

critcl::source c/point.tcl
critcl::source c/point-int.tcl
critcl::source c/wxh.tcl
critcl::source c/box.tcl

# ### ### ### ######### ######### #########
## API - Helper setup

critcl::ccode {
    #include <math.h>
    #include <stdlib.h>

    #ifndef M_PI
    #define M_PI (3.141592653589793238462643)
    #endif
    #define DEGTORAD     (M_PI/180.)	/* (2pi)/360 */
    #define RADTODEG     (180./M_PI)	/* 360/(2pi) */
    #define OURTILESIZE  (256)
    #define OURTILESIZED ((double) OURTILESIZE)
    #define TILES(z)     (1 << (z))

    #define OP Tcl_ObjPrintf
    #define BAD(f, ...) { if (msgv.o != 0) Tcl_ObjSetVar2 (interp, msgv.o, 0, OP (f, __VA_ARGS__), 0); return 0; }
}

# ### ### ### ######### ######### #########
## Implementation - Basics

critcl::cproc ::map::slippy::critcl_length {int level} int {
    return OURTILESIZE * TILES (level);
}

critcl::cproc ::map::slippy::critcl_tiles {int level} int {
    return TILES (level);
}

critcl::cconst ::map::slippy::critcl_tile_size int OURTILESIZE

# ### ### ### ######### ######### #########
## Implementation - Validation

# Force critcl_pstring to be declared for use by helper
critcl::cproc ::map::slippy::DOOM {pstring dummy} void {}
critcl::ccode {
    static critcl_pstring ms_pstring_empty() { critcl_pstring x = {0,0,0} ; return x; }

    // you initialize a struct variable as shown above. You cannot assign to it in the same manner
    // after initialization. You need a value of the proper type. The helper produces such a thing
    // for us. We use it as the default value for the optional `msgv` argument (a varname)
}

critcl::cproc ::map::slippy::critcl_tile_valid {
    Tcl_Interp* interp
    list        tile
    int         levels
    pstring    {msgv ms_pstring_empty()}
} boolean {
    if (tile.c != 3) \
	BAD ("Bad tile <%s>, expected 3 elements (zoom, row, col)", Tcl_GetString(tile.o));

    int    z;
    double r;
    double c;

    if (Tcl_GetIntFromObj    (interp, tile.v[0], &z) != TCL_OK) \
	BAD ("Bad tile <%s>, expected int for zoom",   Tcl_GetString(tile.o));

    if (Tcl_GetDoubleFromObj (interp, tile.v[1], &r) != TCL_OK) \
	BAD ("Bad tile <%s>, expected double for row", Tcl_GetString(tile.o));

    if (Tcl_GetDoubleFromObj (interp, tile.v[2], &c) != TCL_OK) \
	BAD ("Bad tile <%s>, expected double for col", Tcl_GetString(tile.o));

    if ((z < 0) || (z >= levels)) BAD ("Bad zoom level '%d' (max: %d)", z, levels);

    int tiles = TILES (z);

    if ((r < 0) || (r >= tiles) ||
	(c < 0) || (c >= tiles)) BAD ("Bad cell '%f %f' (max: %d)", r, c, tiles);

    return 1;
}

# ### ### ### ######### ######### #########
## Distance
#
# https://en.wikipedia.org/wiki/Haversine_formula
# https://wiki.tcl-lang.org/page/geodesy
# https://en.wikipedia.org/wiki/Geographical_distance	| For radius used in angle
# https://en.wikipedia.org/wiki/Earth_radius		| to meter conversion
##
# Go https://en.wikipedia.org/wiki/N-vector ?

critcl::cproc ::map::slippy::critcl_geo_distance {tripoint geoa tripoint geob} double {
    // lat, lon are in degrees.

    // Convert all to radians
    double lata = DEGTORAD * geoa.y;
    double lona = DEGTORAD * geoa.x;
    double latb = DEGTORAD * geob.y;
    double lonb = DEGTORAD * geob.x;

    double dlat   = latb - lata;
    double dlon   = lonb - lona;
    double hsdlat = sin(dlat/2.);
    double hsdlon = sin(dlon/2.);

    double h      = hsdlat*hsdlat + cos(lata)*cos(latb)*hsdlon*hsdlon;

    // Distance base, clamp to -1..1, then to angle
    if (fabs(h) > 1.0) { h = (h > 0) ? 1 : -1; }

    double d = 2*asin(sqrt(h));

    // Convert to meters and return
    double meters = 6371009 * d;
    return meters;
}

# ### ### ### ######### ######### #########
## Implementation - Coordinate conversions.
#
# geo   = zoom, latitude, longitude
# tile  = zoom, row,      column
# point = zoom, y,        x

critcl::cproc ::map::slippy::critcl_geo_2tile {tripoint geo} tripoint-int {
    // lat, lon are in degrees.
    // The missing sec() function is computed using the 1/cos equivalency.

    int    zoom   = geo.z;
    double lat    = geo.y;
    double lon    = geo.x;

    int    tiles  = TILES (zoom);
    double latrad = DEGTORAD * lat;
    int    row    = (int) ((1 - (log(tan(latrad) + 1.0/cos(latrad)) / M_PI)) / 2 * tiles);
    int    col    = (int) (((lon + 180.0) / 360.0) * tiles);

    tripoint_int out;

    out.z = zoom;
    out.y = row;
    out.x = col;

    return out;
}

critcl::cproc ::map::slippy::critcl_geo_2tilef {tripoint geo} tripoint {
    int    zoom   = geo.z;
    double lat    = geo.y;
    double lon    = geo.x;

    int    tiles  = TILES (zoom);
    double latrad = DEGTORAD * lat;
    double row    = (1 - (log(tan(latrad) + 1.0/cos(latrad)) / M_PI)) / 2 * tiles;
    double col    = ((lon + 180.0) / 360.0) * tiles;

    tripoint out;
    out.z = zoom;
    out.y = row;
    out.x = col;

    return out;
}

critcl::ccode {
    static void geo_2point (int zoom, double lat, double lon, double* y, double* x) {
	int    tiles  = TILES (zoom);
	double latrad = DEGTORAD * lat;
	double row    = (1 - (log(tan(latrad) + 1.0/cos(latrad)) / M_PI)) / 2 * tiles;
	double col    = ((lon + 180.0) / 360.0) * tiles;

	*y = OURTILESIZE * row;
	*x = OURTILESIZE * col;
    }
}

critcl::cproc ::map::slippy::critcl_geo_2point {tripoint geo} tripoint {
    // Essence: [geo 2tile.float $geo] * $ourtilesize, with 'geo 2tile.float' inlined.

    tripoint out;

    out.z = geo.z;
    geo_2point (geo.z, geo.y, geo.x, &out.y, &out.x);

    return out;
}

critcl::cproc ::map::slippy::critcl_geo_2points {
    Tcl_Interp* interp
    int         levels
    tripoint    geo
} object0 {
    // Essence: [geo 2tile.float $geo] * $ourtilesize, with 'geo 2tile.float' inlined.

    Tcl_Obj** cl = (Tcl_Obj**) ckalloc (levels * sizeof(Tcl_Obj*));
    int z;
    for (z = 0; z < levels; z++) {
       tripoint out;

       out.z = z;
       geo_2point (z, geo.y, geo.x, &out.y, &out.x);

       cl[z] = tripoint_box (interp, &out);
    }

    Tcl_Obj* r = Tcl_NewListObj(levels, cl);
    ckfree (cl);
    return r;
}

critcl::cproc ::map::slippy::critcl_tile_2geo {tripoint tile} tripoint {
    // Note: For integer row/col the geo location is for the upper left corner of the tile. To get
    //       the geo location of the center simply add 0.5 to the row/col values.

    int    zoom   = tile.z;
    double row    = tile.y;
    double col    = tile.x;

    double tiles  = TILES (zoom);
    double lat    = RADTODEG * (atan(sinh(M_PI * (1 - 2 * row / tiles))));
    double lon    = col / tiles * 360.0 - 180.0;

    tripoint out;

    out.z = zoom;
    out.y = lat;
    out.x = lon;

    return out;
}

critcl::cproc ::map::slippy::critcl_tile_2point {tripoint tile} tripoint {
    // Note: For integer row/col the pixel location is for the upper left corner of the tile. To get
    //       the pixel location of the center simply add 0.5 to the row/col values.

    int    zoom   = tile.z;
    double row    = tile.y;
    double col    = tile.x;

    tripoint out;

    out.z = zoom;
    out.y = OURTILESIZE * row;
    out.x = OURTILESIZE * col;

    return out;
}

critcl::cproc ::map::slippy::critcl_point_2geo {tripoint point} tripoint {

    int    zoom   = point.z;
    double y      = point.y;
    double x      = point.x;

    int    length = OURTILESIZE * TILES (zoom);
    double lat    = RADTODEG * (atan(sinh(M_PI * (1 - 2 * y / length))));
    double lon    = x / length * 360.0 - 180.0;

    tripoint out;

    out.z = zoom;
    out.y = lat;
    out.x = lon;

    return out;
}

critcl::cproc ::map::slippy::critcl_point_2tile {tripoint point} tripoint {

    int    zoom   = point.z;
    double y      = point.y;
    double x      = point.x;

    tripoint out;

    out.z = zoom;
    out.y = y / OURTILESIZE;
    out.x = x / OURTILESIZE;

    return out;
}

# ### ### ### ######### ######### #########
## Implementation

critcl::cproc ::map::slippy::critcl_fit_geobox {
    wxh canvdim
    box geobox
    int zmin
    int zmax
} int {
    int    canvw = canvdim.w;
    int    canvh = canvdim.h;
    double lat0  = geobox.lat0;
    double lon0  = geobox.lon0;
    double lat1  = geobox.lat1;
    double lon1  = geobox.lon1;

    // NOTE we assume ourtilesize == [map::slippy length 0].
    // Further, we assume that each zoom step "grows" the linear resolution by a factor 2
    // (that's the log(2) down there)

    canvw = abs (canvw);
    canvh = abs (canvh);

    int z = (int) (log(fmin(
			(canvh/OURTILESIZED) / (fabs(lat1 - lat0)/180.),
			(canvw/OURTILESIZED) / (fabs(lon1 - lon0)/360.)))
		/ log(2));
    // clamp
    z = ((z < zmin) ? zmin : ((z > zmax) ? zmax : z));

    // Now zoom is an approximation, since the scale factor isn't uniform across the map
    // (the vertical dimension depends on latitude). So we have to refine iteratively
    // (It is expected to take just one step):

    int z1, z0, hasz1, hasz0;

    hasz0 = hasz1 = 0;

    while (1) {
	// Now we can run "uphill",   getting z0 = z - 1
	// and            "downhill", getting z1 = z + 1
	// (borders from the last iteration)

	double x0, y0, x1, y1;

	geo_2point (z, lat0, lon0, &y0, &x0);
	geo_2point (z, lat1, lon1, &y1, &x1);

	double w = fabs(x1 - x0);
	double h = fabs(y1 - y0);

	if ((w > canvw) || (h > canvh)) {
	    // too big: shrink
	    if (hasz0) break; // but not if we came from below
	    if (z <= zmin) break; // can't be < zmin
	    z1 = z ; hasz1 = 1;
	    z --;
	} else {
	    // fits: grow
	    if (hasz1) break; // but not if we came from above
	    if (z >= zmax) break; // can't be > zmax
	    z0 = z ; hasz0 = 1;
	    z ++;
	}
    }

    if (hasz0) return z0;
    return z;
}

# ### ### ### ######### ######### #########
## Ready
return
