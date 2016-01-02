use <outer.scad>
handleBarD = 32.2;
thick = 3;
width = 12;
desiredGapBetwComputerAndHandlebar = 6;
computerDims = [12, 62, 42];
offsetFromHandlebar = computerDims[1]/2 + desiredGapBetwComputerAndHandlebar;
mountY = offsetFromHandlebar + handleBarD/2;
gap = 1;
big = 1000;
$fs = 1;
$fa = 6;

module screw(headD, nutFlat = 0, throughHoleD, threadD, throughLen = 0, threadLen = 0, headLen, nutLen) {
    // head
    translate([0, 0, -headLen]) cylinder(d=headD, h=headLen, center=false);
    // through hole
    cylinder(d=throughHoleD, h=throughLen, center=false);
    // through
    /*translate([0, 0, -throughLen]) cylinder(d=threadD, h=threadLen, center=false);*/
    translate([0, 0, throughLen])
        if (nutFlat > 0) {
            // nut
            cylinder(d=nutFlat/cos(180/6), h=nutLen, center=false, $fn=6);
        } else {
            // thread
            cylinder(d=threadD, h=threadLen, center=false);
        }
}
module m4screw(length = 20) {
    translate([-length/2, 0, 0]) rotate([0, 90, 0]) screw(
        headD = 9.3,
        headLen = 100,
        nutFlat = 7.5,
        throughHoleD = 5,
        nutLen = 100,
        throughLen = length
    );
}
module socket5_40(length = 9.5) {
    screw(
       headD = 6,
       headLen = 100,
       threadD = 3,
       throughHoleD = 3.75,
       throughLen = 2.5,
       threadLen = length -2.5
   );
}
module handlebar() {
    cylinder(d=handleBarD, h=big, center=true, $fn=60);
}
module computer() {
    translate([-computerDims[0]/2, 0, 0]) moveToOuter() cube(computerDims, center=true);
}
module translateScrew(direction = 1) {
    translate([0,direction*(width/2 + handleBarD/2), 0]) children();
}

module moveYToMountPoint() {
    translate([0, mountY, 0]) children();
}

module screwHolder(direction = 1) {
    translateScrew(direction) rotate([0,-90,0]) rotate([0,0,180/8]) cylinder(d=width/cos(180/8), $fn=8, h=20, center=true);
}

module fastenerAssembly() {
    screwHolder(1);
    screwHolder(-1);
}
module screws() {
    translateScrew(1) m4screw(10);
    translateScrew(-1) m4screw(10);
    translate([0, 0, 3.5]) {
        moveToIntermediate() socket5_40(15);
        moveToFar() socket5_40(15);
    }
}
module ring() {
    hull() {
        cylinder(r = handleBarD/2 + thick, h=width, center=true, $fn=60);
        fastenerAssembly();
    }
}
module cutoutHandlebarAndScrews() {
    difference() {
        children();
        handlebar();
        screws();
    }
}

module getHalf(direction=1) {
    intersection() {
        children();
        translate([direction * (big/2 + gap), 0, 0]) cube([big, big, big], center=true);
    }
}

module botMount() {
    getHalf(1) cutoutHandlebarAndScrews() ring();
}

module moveToOuter() {
    translate([-11, 0, computerDims[2]/2 + 4])
        moveYToMountPoint()
            children();
}
module moveAndRotateToOuter(scaleA=[1,1,1]) {
        moveToOuter() rotate([0, 90, 0]) rotate([0,0,90])
                scale(scaleA) children();
}
module doveTail(inflate = 0) {
    translate([2.5 - width + gap, 0, 0]) moveYToMountPoint() intersection() {
        scale([10, 1, 1]) cylinder(d1=6 + inflate, d2=4 + inflate, h=width, center=true);
        cube([5 + inflate/2, 100, 100], center=true);
    }
}
module holderAssembly() {
    difference() {
        hull() {
            outerShell();
            translate([0, 0, width]) hull() {
                intermediatePoint();
                farPoint();
            };
        }
        moveAndRotateToOuter() bodyCutouts();
        screws();
    }
    moveAndRotateToOuter() bodyAdditions();
    doveTail();
}
module outerHolder() {
    moveAndRotateToOuter() holderBody();
}
module outerShell() {
    moveAndRotateToOuter() rotate([0,0,90]) shell();
}
module moveToIntermediate() {
    translate([-5 - gap, handleBarD/2 + offsetFromHandlebar - 11, 0]) children();
}
module intermediatePoint() {
    moveToIntermediate() cylinder(d=10, h=width, center=true);
}

module moveToFar() {
    translate([0,22,0]) moveToIntermediate() children();
}
module farPoint() {
    translate([0, 0, -width/2]) moveToFar() cylinder(d=10, h=width, center=false);
}
module mountArm() {
    difference() {
        hull() {
            intermediatePoint();
            farPoint();
        }
        screws();
        doveTail(0.6);
    }
}
module topMount() {
    difference() {
        cutoutHandlebarAndScrews() getHalf(-1) {
            ring();
            // bridge from the ring to the intermediatePoint
            hull() {
                translate([-gap,0,0]) screwHolder(1);
                intermediatePoint();
            }
        }
        // make sure we can rotate the rflkt in and out
        translate([-6, 0, 0]) moveToOuter() {
            rotate([0, 90, 0]) cylinder(
                d = 1 + sqrt(computerDims[1] * computerDims[1] + computerDims[2] * computerDims[2]),
                h=12,
                center=true
            );
        }
        computer(); // just for visualization
    }

    mountArm();
}
botMount();
topMount();
//translate([10, 45, 5]) rotate([0, -90, 90])
    holderAssembly();
