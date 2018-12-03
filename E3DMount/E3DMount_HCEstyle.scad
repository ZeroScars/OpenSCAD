echo(version=version());
debug = 0;
explode = $preview ? 0.1 : 0.0;
$fn = $preview ? 90 : 180;

use <Chamfers-for-OpenSCAD/Chamfer.scad>;

// Base plate dimensions
// ---------------------
E3D_plate_width = 62;    // Mount plate width
E3D_plate_heigth = 82;   // Mount plate height
E3D_mount_center = 39.5; // Mount center from top
E3D_mount_offset = E3D_plate_heigth/2 - E3D_mount_center; // Mount center offset
TopBearingCenter = 22.5; // Center of the top bearing seen from the mount center
BearingCenterPitch = 45; // Steel shafts offset
p_sc8uu_w = 18;          // Pitch of the SC8UU bearing (width)
p_sc8uu_h = 24;          // Pitch of the SC8UU bearing (height)
t_plate = 7;             // Mount plate thickness
E3Dholder_hw = 30;       // Width between the E3D holder fastener holes
beltholewidth = 52;      // Distance between the belt holes
beltholewidthSmall = 38; // Distance between the belt holes narrow
m4 = 4.40;               // M4 screw hole
m4_head = 8.0;           // M4 head size 7.4+
m4_t = 3.5;              // M4 nut thickness
m4_depth = 3.5;          // M4 depth of the M4 screw head
m3 = 3.30;               // M3 screw hole
m3_head = 6.4;           // M3 head size 6.0+
m3_head_t = 3.5;         // M3 hex head size 3.2+
m3_t = 2.6;              // M3 nut thickness
tol = 0.5;               // Tolerance used for clean cuts and various clearances
sensor_position_option = 1; // Bottom ABL sensor position [0:none, 1:right, 2:left] as seen from facing the holder

// Mount bottom
E3Dholder_h = 28-3.5+1.5;       // Height of the E3D holder above the plate
E3Dholder_w = 41;       // Width of the E3D holder above the plate
//E3Dholder_hw = 28;      // Width between the E3D holder fastener holes
E3Dholder_t = 12.5;     // Thickness of the E3D holder above the plate
E3Dholder_d1 = 12+0.2;  // Small diameter of the E3D holder above the plate
E3Dholder_d2 = 16+0.2;  // Large diameter of the E3D holder above the plate
E3Dholder_t_top = 4.0;  // Upper height of the E3D holder top height //E3Dholder_t_top = 3.7+0.25;  // Large diameter of the E3D holder top height
E3Dholder_t_btm = 2.55; // Lower height of the E3D holder bottom height //E3Dholder_t_btm = 2.55+0.25; // Large diameter of the E3D holder bottom height
beltholewidth = 52;     // Distance between the belt holes
coolerTunnelWidth = 20; // Width of the cooler tunnel
coolerTunnelHeight = 15;// Height of the cooler tunnel

// Mount top
E3DholderTop_t = 12.5;  // Thickness of the E3D holder cover plate

E3DBasePlate();
E3DmountBottom();
E3DmountTop();
E3DFanDuct();

// ============================================================================================
// Module that draws the base plate which holds the bearing housings and the E3D extruder
// ============================================================================================
module E3DBasePlate(){
    difference() {
      union(){
        translate([0,-E3D_mount_offset,0]){
          // Base plate
          // Center the plate around the E3D hotend holder
          cube([E3D_plate_width, E3D_plate_heigth,t_plate],center = true);
//          %translate([0,(42.75+7.5+E3Dholder_t)/2+E3D_mount_offset,0]){
//            cube([15,42.75+7.5,t_plate], center = true);
//          }
          translate([-5.5,E3D_mount_offset+(E3Dholder_t)/2+15/2,0]){
            hull(){
              cylinder(d = 15, h = t_plate, center = true);
              translate([0,42.75-15/2,0]) cylinder(d = 15, h = t_plate, center = true);
            }
          }
        }
      }
      // --------------------------------------------------------------------------------------------
      // Cut out hole for radial fan attachment
      // --------------------------------------------------------------------------------------------
      translate([-5.5,(E3Dholder_t)/2+42.75,0]){
        cylinder(d = 3.4, h = t_plate+tol, center = true);
        translate([0,0,t_plate/2-3.4/2]){
          cylinder(d = 3.8, h = 3.4+tol, center = true);
        }
      }
      
      // --------------------------------------------------------------------------------------------
      // Cut out SC8UU holes top bearing
      // --------------------------------------------------------------------------------------------
      // Translate position to the middle of the top bearings
      translate([0,TopBearingCenter+(p_sc8uu_h/2),]){
        for (n=[-1:2:1]) {
          translate([n*(p_sc8uu_w+((E3D_plate_width/2-p_sc8uu_w)/2)),0,0]){
            for (w=[0:1]) {
//            for (w=[0]) {
              for (h=[0:1]) {
                translate([-(n*w*p_sc8uu_w), -(h*p_sc8uu_h),0]){
                  // Cutt out through hole M4
                  cylinder(d=m4, h=(t_plate+debug)+tol, center = true);
                  // Countersink the M4 screw heads
                  translate([0,0,(t_plate-m4_depth)/2+tol/2]){
                    cylinder(d=m4_head,h=m4_depth+tol, center = true);
                  }
                }
              }
            }
          }
        }
        // --------------------------------------------------------------------------------------------
        // Cut out SC8UU holes bottom bearing
        // --------------------------------------------------------------------------------------------
        // Translate to center of the bottom bearing
        translate([0,-BearingCenterPitch-p_sc8uu_h/2,0]){
          for (w=[-1:2:1]) {
            for (h=[-1:2:1]) {
              translate([(w*p_sc8uu_w/2), (h*p_sc8uu_h/2)]){
                hull(){
                  translate([0,-1,0]) cylinder(d=m4,h=(t_plate)+2*tol, center = true);
                  translate([0, 1,0]) cylinder(d=m4,h=(t_plate)+2*tol, center = true);
                }
                translate([0,0,(t_plate-m4_depth)/2+tol/2]){
                  hull(){
                    translate([0,-1,0]) cylinder(d=m4_head,h=m4_depth+tol, center = true);
                    translate([0, 1,0]) cylinder(d=m4_head,h=m4_depth+tol, center = true);
                  }
                }
              }
            }
          }
        }
      }
      // --------------------------------------------------------------------------------------------
      // Cut out belt holder holes
      // --------------------------------------------------------------------------------------------
      for (w=[-1:2:1]){
        translate([w*(beltholewidth)/2,0,0]){
          cylinder(d=m3,h=(t_plate)+tol, center = true);
        }
        // second set of holes
        translate([w*(beltholewidthSmall)/2,-11,0]){
          cylinder(d=m3,h=(t_plate)+2*tol, center = true);
          // Nut
          translate([0,0,t_plate/2-m3_t+tol/2]){
            rotate([0,0,30]){
              cylinder(d=m3_head,h=(m3_t+tol), $fn=6, center = false);
            }
          }
        }
      }
      // --------------------------------------------------------------------------------------------
      // Cut E3D holder holes
      // --------------------------------------------------------------------------------------------
      for (w=[-1:2:1]) {
        translate([w*E3Dholder_hw/2,0,0]){
          cylinder(d=m3,h=(t_plate)+tol, center = true);
        }
        translate([w*E3Dholder_hw/2,0,-(t_plate+tol-m3_head_t)/2]){
          cylinder(d=m3_head,h=m3_head_t+tol, center = true);
        }
      }
      // --------------------------------------------------------------------------------------------
      // Cut out ABL sensor holder holes
      // --------------------------------------------------------------------------------------------
      translate([0,-E3D_plate_heigth/2+5.75,0]){
        for (h=[0:1]){
          for (w=[-1:2:1]){
            translate([w*(E3D_plate_width/2-5),h*21,0]){
              cylinder(d=m3,h=(t_plate)+tol, center = true);
              translate([0,0,-(t_plate-3.6)/2-tol/2]){
                cylinder(d=3.8,h=3.6+tol, center = true);
              }
            }
          }
        }
      }
      translate([0,-E3D_plate_heigth/2+16.25,0]){
        for (w=[-1:2:1]){
          translate([w*(E3D_plate_width-20)/2,0]){
            cylinder(d=m3,h=(t_plate)+2*tol, center = true);
            translate([0,0,-(t_plate-3.6)/2-tol/2]){
              cylinder(d=3.8,h=3.6+tol, center = true);
            }
          }
        }
      }
      // --------------------------------------------------------------------------------------------
      // Cut out cooler holes
      // --------------------------------------------------------------------------------------------
      translate([0,-E3D_plate_heigth/2-E3D_mount_offset+8.5,0]){
        for (w=[-1:2:1]){
          translate([w*(30/2),0,0]){
            cylinder(d=m3,h=(t_plate)+tol, center = true);
            translate([0,0,-(t_plate-3.6)/2-tol/2]){
              cylinder(d=3.8,h=3.6+tol, center = true);
            }
          }
        }
      }
    }
  }
// ============================================================================================

// ============================================================================================
// Module 
// ============================================================================================
module E3DmountBottom(){
  translate([0,0,t_plate/2+explode*1]){
    difference(){
      union(){
        // E3D holder mount
        translate([0,0,E3Dholder_h/2]){
          cube([E3D_plate_width, E3Dholder_t, E3Dholder_h], center = true);
        }
      }
      // --------------------------------------------------------------------------------------------
      // Cut out cooler tunnel
      // --------------------------------------------------------------------------------------------
      translate([0,0,coolerTunnelHeight/2-tol/2]){
        cube([coolerTunnelWidth, E3Dholder_t+tol, coolerTunnelHeight+tol], center = true);
      }
      // --------------------------------------------------------------------------------------------
      // Cut out radial fan notches
      // --------------------------------------------------------------------------------------------
      lNotchWidth = 3;
      lNotchHeight = 5;
      lNotchDepth = 1.5;
      lNotchZPos = 7.0;
      translate([-(coolerTunnelWidth+lNotchDepth)/2,(E3Dholder_t-lNotchHeight)/2,lNotchZPos]){
//        %cube([lNotchDepth, lNotchHeight, lNotchWidth], center = true);
        hull(){
          hull(){
            translate([0,-lNotchHeight/2+lNotchWidth/2,0]){
              sphere(d=lNotchWidth, $fn = 0, $fa = 1, $fs = 0.5);
            }
            translate([0,lNotchHeight/2,0]){
              sphere(d=lNotchWidth, $fn = 0, $fa = 1, $fs = 0.5);
            }
          }
          hull(){
            translate([lNotchDepth,-lNotchHeight/2+lNotchWidth/2,0]){
              sphere(d=lNotchWidth, $fn = 0, $fa = 1, $fs = 0.5);
            }
            translate([lNotchDepth,lNotchHeight/2,0]){
              sphere(d=lNotchWidth, $fn = 0, $fa = 1, $fs = 0.5);
            }
          }
        }
      }
      translate([(coolerTunnelWidth)/2+lNotchWidth/2+2,(E3Dholder_t)/2,lNotchZPos]){
        hull(){
          hull(){
            translate([0,-0.5,0]){
              sphere(d=lNotchWidth, $fn = 0, $fa = 1, $fs = 0.5);
            }
            translate([11-lNotchWidth,-0.5,0]){
              sphere(d=lNotchWidth, $fn = 0, $fa = 1, $fs = 0.5);
            }
          }
          hull(){
            translate([0,0.5,0]){
              sphere(d=lNotchWidth, $fn = 0, $fa = 1, $fs = 0.5);
            }
            translate([11-lNotchWidth,0.5,0]){
              sphere(d=lNotchWidth, $fn = 0, $fa = 1, $fs = 0.5);
            }
          }
        }
      }
      // --------------------------------------------------------------------------------------------
      // Cut out belt holder holes
      // --------------------------------------------------------------------------------------------
      translate([0,0,-tol/2]){
        for (w=[-1,1]) {
          translate([w*beltholewidth/2,0,0]){
            cylinder(d=m3,h=(2*t_plate)+2*tol, center = false);
            cylinder(d=4.8,h=5.2+tol, center = false);
          }
        }
      }
      // --------------------------------------------------------------------------------------------
      // Cut E3D holder holes
      // --------------------------------------------------------------------------------------------
      translate([0,0,-tol/2]){
        for (w=[-1,1]) {
          translate([w*E3Dholder_hw/2,0]){
            cylinder(d=m3,h=E3Dholder_h+tol, center = false);
            cylinder(d=4.8,h=5.2+tol, center = false);
            translate([0,0,E3Dholder_h-5.2]){
              cylinder(d=4.8,h=5.2+tol, center = false);
            }
          }
        }
      }
      // --------------------------------------------------------------------------------------------
      // Cut out the E3D hole for the radiator
      // --------------------------------------------------------------------------------------------
      rotate([90,0,0]){
        translate([0,E3Dholder_h,-(E3Dholder_t/2)]){
          E3DHead();
        }
      }
    }
  }
}
// ============================================================================================

// ============================================================================================
// Module 
// ============================================================================================
module E3DHead(){
  // Center bore
  translate([0,0,-tol/2]){
    cylinder(d=E3Dholder_d1,h=E3Dholder_t+tol, center = false);
  }
  // Top cut out
  translate([0,0,-tol])
  {
    cylinder(d=E3Dholder_d2,h=E3Dholder_t_top+tol, center = false);
  }
  // Bottom cut out
  translate([0,0,E3Dholder_t_top+6-0.3]){
    cylinder(d=E3Dholder_d2,h=E3Dholder_t_btm+tol, center = false);
  }
}
// ============================================================================================

// ============================================================================================
// Module 
// ============================================================================================
module E3DmountTop(){
  translate([0,0,t_plate/2+E3Dholder_h+explode*2]){
    difference(){
      union(){
        // E3D holder mount
        translate([0,0,E3DholderTop_t/2]){
          cube([E3D_plate_width, E3Dholder_t, E3DholderTop_t], center = true);
        }
      }
      // --------------------------------------------------------------------------------------------
      // Cut E3D holder holes
      // --------------------------------------------------------------------------------------------
      translate([0,0,-tol/2]){
        for (w=[-1,1]) {
          translate([w*E3Dholder_hw/2,0,0]){
            cylinder(d=m3,h=E3DholderTop_t+tol, center = false);
            translate([0,0,E3DholderTop_t-m3_head_t/2+tol/2]){
              cylinder(d=m3_head,h=m3_head_t+tol, center = true);
            }
          }
        }
      }
      // --------------------------------------------------------------------------------------------
      // Cut out the E3D hole for the radiator
      // --------------------------------------------------------------------------------------------
      rotate([90,0,0]){
        translate([0,-0.2,-(E3Dholder_t/2)]){ // X,Z,Y-
          E3DHead();
        }
      }
    }
  }
}
// ============================================================================================

// ============================================================================================
// Module 
// ============================================================================================
module E3DFanDuct(){
  translate([0,-2,t_plate/2+explode/2]){
    rotate([0,90,90]){
      import("HCE_FanDuct_v6.stl", convexity=3);
    }
  }
}
// ============================================================================================

// ============================================================================================
// Module 
// ============================================================================================
// ============================================================================================

