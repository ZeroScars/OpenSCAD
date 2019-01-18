echo(version=version());
debug = 1;
explode = $preview ? 0.1 : 0.0;
$fn = $preview ? 90 : 360;
tol = 0.2;

rotate([0,0,0]){
  translate([0,0,0]){ // positioning of the hinge
    filamentGuide();
  }
}

fgWidth =  20; // x-axis
fgLength = 50; // y-axis 
fgHeight =  8; // z-axis
fgRadiusFillet = 2.5;

dFilament = 1.75;

module filamentGuide(){
  difference(){
    union(){
      minkowski(){
        cube([fgWidth-2*fgRadiusFillet, fgLength-2*fgRadiusFillet, fgHeight/2],center = true);
        cylinder(r = fgRadiusFillet, h = fgHeight/2, center = true);
      }
    }
    // Cut out filament path
    translate([-4,0,0]){
      rotate([90,0,0]){
        cylinder(d = dFilament*1.14, h = fgLength+tol, center = true);
      }
    }
    // Cut out filament Bowden tube inserts
    
    // Section analysis, DEBUG == 1
    if (debug == 1){
      translate([0,0,10])
        cube([100, 100, 20],center = true);
    }
  }
}