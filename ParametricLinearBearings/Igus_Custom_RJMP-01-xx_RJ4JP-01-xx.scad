// ==========================================================================
// Custom parametric Igus style linear bearing RJMP-01-xx and RJ4JP-01-xx 
// (https://www.thingiverse.com/thing:2476782) by 0scar is licensed under the 
// Creative Commons - Attribution - Non-Commercial - Share Alike license.
// http://creativecommons.org/licenses/by-nc-sa/3.0/
// ==========================================================================
echo(version=version());

// ==========================================================================
// The tables below show the parameter values of actual linear bearing types.
// These parameters can be used or altered for custom bearing design.
// ==========================================================================
// Parameters for RJMP-01-xx (shaft size xx, all dimensions in [mm])
// Designation  d1  d2  B   B1    s     dn
//------------------------------------------
// RJMP-01-06   6   12  19  13.5  1.1   11.5
// RJMP-01-08   8   16  25  16.2  1.1   15.2
// RJMP-01-10   10  19  29  21.6  1.3   17.5
// RJMP-01-12   12  22  32  22.6  1.3   20.5
// RJMP-01-16   16  26  36  24.6  1.3   24.2
// RJMP-01-20   20  32  45  31.2  1.6   29.6
// RJMP-01-25   25  40  58  43.7  1.85  36.5
// RJMP-01-30   30  47  68  51.7  1.85  43.5
//
// Parameters for RJ4JP-01-xx (shaft size xx, all dimensions in [mm])
// Designation  d1  d2  B   B1    s     dn
//------------------------------------------
// RJ4JP-01-08  8   15  24  17.5  1.1   14.3
// RJ4JP-01-10  10  19  29  22.0  1.3   18.0
// RJ4JP-01-12  12  21  30  23.0  1.3   20.0
// RJ4JP-01-16  16  28  37  26.5  1.6   26.6
// RJ4JP-01-20  20  32  42  30.5  1.6   30.3
// RJ4JP-01-25  25  40  59  41.1  1.85  37.5
// RJ4JP-01-30  30  45  64  44.6  1.85  42.5

// Options
doChamferLobe = false;    // Option to chamfer the outer lobes for easy insertion of shafts
SF = 1.0;                 // Allow for shrinkage of the material

// Bearing diameter related parameters
d1 = 8;                   // Inner diameter
d2 = 15;                  // Outer Diameter
d1tol = 0.0;              // Tolerance of shaft diameter
// Bearing length related parameters
B  = 24;                  // Bearing total length
B1 = 17.5;                // Distance between outer ring flanges
// Bearing ring cut-out
s  = 1.1;                 // Ring width
dn = 14.3;                // Ring diameter
// Other parameters (chamfer)
cd = 1.5;                 // Chamfer distance
ca = 30;                  // Chamfer angle
// Glide surface/lobe related parameters
da = 45;                  // Chamfer angle for glide surfaces for easy inner shaft insertion
gw = 1.5;                 // Gap width between glide surfaces (lobes)
ld = 0.5;                 // Lobe depth (percentage of d2 - d1)
// Custom long bearing parameters
Bel = 36;                 // Extra length for long bearings (e.g 60 - 24 = 36)
lbel = 0.6;               // Glide surface cut-out length as percentage of Bel
                          // Long bearing glide surface elongnation (determine the length of the glide surfaces)

// Change parameter values
vB  = (B + Bel) * SF;     // Bearing total length
vB1 = (B1 + Bel) * SF;    // Distance between outer ring flanges
vBel = Bel * SF;          // Extra length for long bearings
vd1tol = d1tol * SF;      // Tolerance of shaft diameter
vd1 = d1 * SF + vd1tol;   // Inner diameter
vd2 = d2 * SF;            // Outer Diameter
vs  = s * SF;             // Ring cut-out width
vdn = dn * SF;            // Ring cut-out diameter
vcd = cd * SF;            // Chamfer distance
vgw = gw * SF;            // Gap width between glide surfaces

tol = 0.5; // rendering tolerance, only for visual rendering, no effect on model dimensions
render_segments = $preview ? 90 : 360;
debug = 0;

// Create sketch of bearing block
difference() {
    union(){
        // Outer cylinder
        cylinder(h=vB-(2*vcd),d=vd2,$fn=render_segments,center=true);
        for (i=[-1,1]) {
            translate ([0,0,i*(vB-vcd)/2]) {
                ar1 = vd2/2;
                ar2 = ar1 - vcd*tan(ca);
                cylinder(h=vcd,r2=(i*((ar2-ar1)/2)+(ar1+ar2)/2),r1=(i*((ar1-ar2)/2)+(ar1+ar2)/2),$fn=render_segments,center=true);
            }
        }
    }
    // Center shaft subtraction
    // NOTE: Tolerance is already added to inner diameter
    cylinder(h=vB+tol,d=vd1,$fn=render_segments,center=true);
    // fastener ring gaps subtraction
    for (i=[-1,1]) {
        translate ([0,0,i*(vB1/2-vs/2)]) {
            // Ring gaps
            difference() {
                cylinder(h=vs,d=vd2+tol,$fn=render_segments,center=true);
                cylinder(h=vs,d=vdn,$fn=render_segments,center=true);
            }
        }
    }
    // Glide surface lobe creation
    for (i=[0:da:(180-da)]) {
        rotate ([0,0,i]) {
            // User customizable lobe depth
            intersection(){
                cube ([vgw,(vd2-vd1)*ld+vd1,vB+tol], center=true);
                cylinder(h=vB+tol,d=(vd2-vd1)*ld+vd1,$fn=render_segments,center=true);
            }
        }
    }
    // Extraction of middle glide part for large bearings
    // to reduce the glide surface, basically an upper and lower gliding surface should be enough.
    if (vBel > 0) {
        // Center part
        cylinder(h=(vBel)*lbel+tol/10,d=(vd2-vd1)*ld+vd1,$fn=render_segments,center=true);
        for (i=[-1,1]) {
            hc = (((vd2-vd1)*ld)/2)/tan(ca);
            translate ([0,0,i*(((vBel*lbel)/2)+hc/2)]) {
                ar1 = ((vd2-vd1)*ld+vd1)/2;
                ar2 = (vd1/2);
                cylinder(h=hc,r2=(i*((ar2-ar1)/2)+(ar1+ar2)/2),r1=(i*((ar1-ar2)/2)+(ar1+ar2)/2),$fn=render_segments,center=true);
            }
        }
        // Chamfer parts
    }
    // Extration of the outer chamfer for the glide lobes
    if (doChamferLobe) {
        for (i=[-1,1]) {
            translate ([0,0,i*(vB/2)]) {
                ar1 = (vd1)/2;
                ar2 = ((vd2-vd1)*ld+vd1)/2;
                cylinder(h=(((vd2-vd1)*ld)*tan(ca)),r2=(i*((ar2-ar1)/2)+(ar1+ar2)/2),r1=(i*((ar1-ar2)/2)+(ar1+ar2)/2),$fn=render_segments,center=true);
            }
        }
    }
    if (debug) {
        cube ([(vd2+tol)/2,(vd2+tol)/2,(vB+tol)/2]);
        translate ([0, 0, -(vB)/2]) {
            cube ([(vd2+tol),(vd2+tol),(vB+tol)/2], center=true);
        }
    }
}


