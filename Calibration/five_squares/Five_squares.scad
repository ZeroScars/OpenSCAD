// Set constants as you like
width = 30;
depth = 30;
layer_height = 0.2;
first_layer_height = 0.2;
nr_of_layers = 2;
box_size = 180;

// Calculated parameters
height = first_layer_height + (nr_of_layers - 1) * layer_height;

// Draw the object
translate([-width/2, -depth/2,0]){
  cube(size = [width, depth, height], center = false);
  for (x=[-1:2:1]){
    for (y=[-1:2:1]){
      translate([x * (box_size-width)/2, y * (box_size-depth)/2, 0])
        cube(size = [width, depth, height], center = false);
    } 
  } 
}

// E.g. draw an enclosing box to make it fancy
//nozzle_width = 0.4;
//nr_of_lines = 2;
//tol = 0.1; // used for rendering
//translate([0,0,height/2]){
//  difference(){
//    cube(size = [box_size, box_size, height], center = true);
//    cube(size = [box_size-(2*(nozzle_width*nr_of_lines)), box_size-(2*(nozzle_width*nr_of_lines)), height + tol], center = true);
//  }
//}