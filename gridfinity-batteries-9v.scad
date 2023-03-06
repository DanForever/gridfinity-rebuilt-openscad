include <gridfinity-rebuilt-utility.scad>
include <gridfinity-battery-constants.scad>
include <roundedcube.scad>

// ===== INFORMATION ===== //
/*
 IMPORTANT: rendering will be better for analyzing the model if fast-csg is enabled. As of writing, this feature is only available in the development builds and not the official release of OpenSCAD, but it makes rendering only take a couple seconds, even for comically large bins. Enable it in Edit > Preferences > Features > fast-csg
 the magnet holes can have an extra cut in them to make it easier to print without supports
 tabs will automatically be disabled when gridz is less than 3, as the tabs take up too much space
 base functions can be found in "gridfinity-rebuilt-utility.scad"
 examples at end of file

 BIN HEIGHT
 the original gridfinity bins had the overall height defined by 7mm increments
 a bin would be 7*u millimeters tall
 the lip at the top of the bin (3.8mm) added onto this height
 The stock bins have unit heights of 2, 3, and 6:
 Z unit 2 -> 7*2 + 3.8 -> 17.8mm
 Z unit 3 -> 7*3 + 3.8 -> 24.8mm
 Z unit 6 -> 7*6 + 3.8 -> 45.8mm

https://github.com/kennetek/gridfinity-rebuilt-openscad

*/

// ===== PARAMETERS ===== //

/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;

/* [General Settings] */
// number of bases along x-axis
gridx = 1;  
// number of bases along y-axis   
gridy = 2;  
// bin height. See bin height information and "gridz_define" below.  
gridz = 3;   
// base unit
length = 42;

/* [Battery] */
// Modifies the diameter of the battery. If you want a tight fit, make the number smaller
battery_wiggleroom = -0.05;

// How high up from the floor you want the model. 0 would be flush with the bottom of the base
battery_z_offset = 1;

// How much extra space to insert between batteries
battery_spacing = 0.5;

/* [Compartments] */
// number of X Divisions
divx = 1;
// number of y Divisions
divy = 1;

/* [Toggles] */
// snap gridz height to nearest 7mm increment
enable_zsnap = false;
// enable upper lip for stacking other bins
enable_lip = true;

/* [Other] */
// determine what the variable "gridz" applies to based on your use case
gridz_define = 0; // [0:gridz is the height of bins in units of 7mm increments - Zack's method,1:gridz is the internal height in millimeters, 2:gridz is the overall external height of the bin in millimeters]

// overrides internal block height of bin (for solid containers). Leave zero for default height. Units: mm
height_internal = 0; 

/* [Base] */
style_hole = 3; // [0:no holes, 1:magnet holes only, 2: magnet and screw holes - no printable slit, 3: magnet and screw holes - printable slit]
// number of divisions per 1 unit of base along the X axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_x = 0;
// number of divisions per 1 unit of base along the Y axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_y = 0; 

// ===== IMPLEMENTATION ===== //

battery_width = ninevolt_battery_width + battery_wiggleroom;
battery_depth = ninevolt_battery_depth + battery_wiggleroom;
battery_height = ninevolt_battery_height;
battery_z = h_base + battery_z_offset;

working_area_width = (length * gridx) - (r_base * 2);
working_area_depth = (length * gridy) - (r_base * 2);

function batteryX(column) = column * (battery_width + battery_spacing);
function batteryY(row) = row * (battery_depth + battery_spacing);

// Calculate the maximum number of batteries that can be stored in a row or column based on the configuration of the box
function maxBatteriesLine(grid_size, battery_size) = floor(((length * grid_size) - (r_base * 2)) / (battery_size + battery_spacing));

// The length in mm of a row or column of batteries
function batteryLineLength(quantity, battery_size) = (quantity * (battery_size + battery_spacing)) - battery_spacing;

// The amount of space not occupied by batteries
function emptySpace(lineWidth, grid_size) = (grid_size * length) - lineWidth;

// The offset that should be applied to each battery so that the "grid" of batteries is propery centred
function batteryLineAdjustment(grid_size, battery_size, lineLength) =-((grid_size * length) / 2) + (battery_size/2) + (emptySpace(lineLength, grid_size)/2);

max_batteries_x = maxBatteriesLine(gridx, battery_width);
max_batteries_y = maxBatteriesLine(gridy, battery_depth);

battery_x_line_width = batteryLineLength(max_batteries_x, battery_width);
battery_y_line_width = batteryLineLength(max_batteries_y, battery_depth);

empty_space_x = working_area_width - battery_x_line_width;
empty_space_y = working_area_depth - battery_y_line_width;

battery_x_adjustment = -battery_x_line_width/2;//-empty_space_x / 2;
battery_y_adjustment = -battery_y_line_width/2;//batteryLineAdjustment(gridy, battery_depth, battery_y_line_width);

echo("max_batteries_x", max_batteries_x);
echo("max_batteries_y", max_batteries_y);
echo("battery_x_adjustment", battery_x_adjustment);
echo("battery_y_adjustment", battery_y_adjustment);

color("tomato") {
difference() {
    gridfinityInit(gridx, gridy, height(gridz, gridz_define, enable_lip, enable_zsnap), height_internal, length);
    
    for(x = [0:max_batteries_x - 1]) {
        for(y = [0:max_batteries_y - 1]) {
            translate([batteryX(x) + battery_x_adjustment, batteryY(y) + battery_y_adjustment, battery_z])
            //cube([battery_width, battery_depth, battery_height]);
            roundedcube([battery_width, battery_depth, battery_height], false, 2.5);
        }
    }   
}
gridfinityBase(gridx, gridy, length, div_base_x, div_base_y, style_hole);

}
