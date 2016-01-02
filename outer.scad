$fs = 1;
$fa = 6;

module index(inflate = 0) {
    xoffset = 20;
    difference() {
        hull() {
            scale([1,1,1]) holderBody();
            translate([xoffset,0,0]) cylinder(d=10, h=10, center=false);
        }
        shell();
        translate([xoffset+1,0,0]) cylinder(d=3, h=100, center=true);
    }
}

module shell(inflate=0, height = 10) {
    cylinder(d=36 + inflate, h=height, center=false, $fn=60);
}
module bodyCutouts() {
    // form the lip that holds the cleat tabs
    translate([0,0,1.25]) cylinder(d=30, h=100, center=false, $fn=60);
    // make the through-hole for the cleat body
    cylinder(d=26, h=100, center=true, $fn=60);
    // make the cutout to insert the cleat tabs
    cleatTabs(5, 1.5, 5.1, cutout = 1);
}
module bodyAdditions() {
    translate([0, 31.25/2, 0]) cylinder(d=3, h=5, center=false);
    translate([0, -31.25/2, 0]) cylinder(d=3, h=5, center=false);
}
module holderBody() {
    difference() {
        shell();
        bodyCutouts();
    }
    bodyAdditions();
}
module cleatSmallCyl(height=3, inflate = 0) {
    cylinder(d=inflate + 24.9, h=height, center=false, $fn=60);
}
module cleatLargeCyl(h=1.5, inflate = 0) {
    cylinder(d=inflate + 28.6, h=h, center=false, $fn=60);
}
module cleatTabs(inflateX = 0, inflateY = 0, height = 1.5, cutout = 0) {
    intersection() {
        translate([0, 0, -cutout]) cleatLargeCyl(height + cutout, inflateX);
        cube([100, 11 + inflateY, 100], center=true);
    }
}
module indent(depth = 1, inflateX= 0, inflateY = 0) {
    hull() {
        translate([11.95 + inflateX, 0, 0]) cube([0.1, 2.5 + inflateY, depth * 2], center=true);
        translate([0, 0, -1.1]) cube([1, 0.1, 0.1], center=true);
    }
}
module indents(depth = 1) {
    indent(depth);
    rotate([0, 0, 180]) indent(depth);
}
module cleat() {
    cleatSmallCyl(3);
    cleatTabs();
}

module insertIndent(depth = 1, inflateX= 0, inflateY = 0) {
    yy = 2.45/2;
    rotate([0, 0, 90]) hull() {
        translate([11.95 + inflateX, 0, 0]) {
            cube([0.1, 1, depth * 2], center=true);
            translate([0, yy, 0]) cube([0.1, 0.1, 0.1], center=true);
            translate([0, -yy, 0]) cube([0.1, 0.1, 0.1], center=true);
        }
        translate([0, 0, -(depth + 0.5)]) cube([1, 0.1, 0.1], center=true);
    }
}

module insert() {
    // glue-in insert to secure the cleat
    difference() {
        union() {
            cleatSmallCyl(height = 2, inflate = -0.5);
            cleatTabs(4, 0.5, height = 2);
            rotate([0, 180, 0]) insertIndent(1.25, -0.75, -0.5);
            rotate([0, 180, 180]) insertIndent(1.25, -0.75, -0.5);
        }
        // make bendy wing things
        difference() {
            cube([9, 100, 100], center = true);
            cube([7.5, 100, 100], center = true);
            cube([100, 12, 100], center = true);
        }
        cylinder(d=4, h=10, center=true);
    }
}

*translate([0, 0, 2.75]) rotate([0, 180, 90]) difference() {
    cleat();
    indents(1);
}
holderBody();
!rotate([0, 180, 0]) insert();
