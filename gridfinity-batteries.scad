include <gridfinity-rebuilt-utility.scad>
include <gridfinity-battery-constants.scad>

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
gridy = 1;  
// bin height. See bin height information and "gridz_define" below.  
gridz = 3;   
// base unit
length = 42;

/* [Battery] */
// Select which kind of cell type you want to be able to store in your gridfinity box
battery_type = 1; //[0: AAA, 1: AA, 2: C, 3: D]

// Modifies the diameter of the battery. If you want a tight fit, make the number smaller
battery_wiggleroom = 0.01;

// How high up from the floor you want the model. 0 would be flush with the bottom of the base
battery_z_offset = 0;

// How much extra space to insert between batteries
battery_spacing = 0.1;

/* [Compartments] */
// number of X Divisions
divx = 1;
// number of y Divisions
divy = 1;

/* [Toggles] */
// internal fillet for easy part removal
enable_scoop = true;
// snap gridz height to nearest 7mm increment
enable_zsnap = false;
// enable upper lip for stacking other bins
enable_lip = true;

/* [Other] */
// determine what the variable "gridz" applies to based on your use case
gridz_define = 0; // [0:gridz is the height of bins in units of 7mm increments - Zack's method,1:gridz is the internal height in millimeters, 2:gridz is the overall external height of the bin in millimeters]
// the type of tabs
style_tab = 1; //[0:Full,1:Auto,2:Left,3:Center,4:Right,5:None]

// overrides internal block height of bin (for solid containers). Leave zero for default height. Units: mm
height_internal = 0; 

/* [Base] */
style_hole = 3; // [0:no holes, 1:magnet holes only, 2: magnet and screw holes - no printable slit, 3: magnet and screw holes - printable slit]
// number of divisions per 1 unit of base along the X axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_x = 0;
// number of divisions per 1 unit of base along the Y axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_y = 0; 



// ===== IMPLEMENTATION ===== //

battery_diameter = battery_data[battery_type][0] + battery_wiggleroom;
battery_length = battery_data[battery_type][1];

battery_radius = (battery_diameter / 2);
battery_z = h_base + battery_z_offset;

function batteryPos(index, grid_size) = (index * (battery_diameter + battery_spacing));
function batteryX(column) = batteryPos(column, gridx);
function batteryY(row) = batteryPos(row, gridy);

// Calculate the maximum number of batteries that can be stored in a row or column based on the configuration of the box
function maxBatteries(grid_size) = floor((length * grid_size) / (battery_diameter + battery_spacing));

// The length in mm of a row or column of batteries
function batteryLineWidth(quantity) = (quantity * (battery_diameter + battery_spacing)) - battery_spacing;

// The amount of space not occupied by batteries
function emptySpace(lineWidth, grid_size) = (grid_size * length) - lineWidth;

// The offset that should be applied to each battery so that the "grid" of batteries is propery centred
function batteryLineAdjustment(lineWidth, grid_size) = -((grid_size * length) / 2) + battery_radius + (emptySpace(lineWidth, grid_size)/2);

max_batteries_x = maxBatteries(gridx);
max_batteries_y = maxBatteries(gridy);

battery_x_line_width = batteryLineWidth(max_batteries_x);
battery_y_line_width = batteryLineWidth(max_batteries_y);

battery_x_adjustment = batteryLineAdjustment(battery_x_line_width, gridx);
battery_y_adjustment = batteryLineAdjustment(battery_y_line_width, gridy);

color("tomato") {
difference() {
    gridfinityInit(gridx, gridy, height(gridz, gridz_define, enable_lip, enable_zsnap), height_internal, length);
    
    for(x = [0:max_batteries_x - 1]) {
        for(y = [0:max_batteries_y - 1]) {
            translate([batteryX(x) + battery_x_adjustment, batteryY(y) + battery_y_adjustment, battery_z])
            cylinder(battery_length, battery_radius, battery_radius);
        }
    }   
}
gridfinityBase(gridx, gridy, length, div_base_x, div_base_y, style_hole);

}
