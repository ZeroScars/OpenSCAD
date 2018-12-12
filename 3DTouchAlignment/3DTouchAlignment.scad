echo(version=version());
debug = 0;
explode = $preview ? 0.1 : 0.0;
$fn = $preview ? 90 : 360;

x_size = 60; // mm
y_size = 7;  // mm
z_size = 5;  // mm
tol = 0.2;

sensor_offset = 8.3; // mm

difference(){
  union(){
    cube([x_size, y_size, z_size]);
    translate([x_size,y_size/2,0]){
      cylinder(d=13,h=z_size+sensor_offset);
    }
  }
  translate([x_size,y_size/2,-tol]){
    cylinder(d=3.5,h=z_size+sensor_offset+2*tol);
  }
}
