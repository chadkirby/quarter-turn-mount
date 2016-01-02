use <outer.scad>
handleBarD = 32.2;
thick = 3;
width = 12;
armThickness = 12;
desiredGapBetwComputerAndHandlebar = 6;
computerDims = [12, 62, 42];
offsetFromHandlebar = computerDims[1]/2 + desiredGapBetwComputerAndHandlebar;
mountY = offsetFromHandlebar + handleBarD/2;
shellD = 36;
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
module m4PanHeadScrew(length = 20) {
    translate([-length/2, 0, 0]) rotate([0, 90, 0]) screw(
        headD = 9.3,
        headLen = 100,
        nutFlat = 7.5,
        throughHoleD = 5,
        nutLen = 100,
        throughLen = length
    );
}
module m4ButtonScrew(length = 6) {
    screw(
        headD = 8,
        headLen = 15,
        nutFlat = 7.5,
        throughHoleD = 5,
        nutLen = 15,
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
    translateScrew(1) m4PanHeadScrew(10);
    translateScrew(-1) m4PanHeadScrew(10);
        moveToIntermediate() rotate([-30, 0, 0]) rotate([0, 0, 180/6]) translate([1, 0, 1]) m4ButtonScrew(4.5);
        translate([0, 0, 0]) moveToFar() rotate([30, 0, 0]) rotate([0, 0, 180/6]) translate([1, 0, 1]) m4ButtonScrew(4.5);
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
    translate([-armThickness - gap, 0, max(shellD/2, computerDims[2]/2 - width/2)])
        moveYToMountPoint()
            children();
}
module moveAndRotateToOuter(scaleA=[1,1,1]) {
        moveToOuter() rotate([0, 90, 0]) rotate([0,0,90])
                scale(scaleA) children();
}
module doveTail(inflate = 0) {
    thick = 5 + inflate/2;
    hgt = 5;
    translate([-gap + thick/2 - armThickness, 0, width/2 - hgt]) moveYToMountPoint() intersection() {
        scale([100, 1, 1]) cylinder(d1=8 + inflate, d2=7 + inflate, h=hgt, center=false);
        cube([thick, 100, 100], center=true);
    }
}
module holderAssembly() {
    difference() {
        hull() {
            outerShell();
            *translate([0, 0, width/2]) hull() {
                intermediatePoint();
                farPoint();
            };
        }
        moveAndRotateToOuter() bodyCutouts();
        screws();
    }
    moveAndRotateToOuter() bodyAdditions();
    *doveTail();
}
module outerHolder() {
    moveAndRotateToOuter() holderBody();
}
module outerShell() {
    moveAndRotateToOuter() rotate([0,0,90]) shell(height = armThickness);
}
module outerHull() {
    moveAndRotateToOuter() rotate([0,0,90]) cylinder(d=shellD + 0.5, h=100, center=true);
}
module moveToIntermediate() {
    translate([-armThickness/2 - gap, handleBarD/2 + offsetFromHandlebar - 11, 0]) children();
}
module intermediatePoint() {
    moveToIntermediate() cylinder(d=armThickness, h=width, center=true);
}

module moveToFar() {
    translate([0,22,0]) moveToIntermediate() children();
}
module farPoint() {
    translate([0, 0, -width/2]) moveToFar() cylinder(d=armThickness, h=width, center=false);
}
module mountArm() {
    scaleUp = (shellD + 0.5)/shellD;
    difference() {
        intersection() {
            hull() {
                intermediatePoint();
                farPoint();
            }
            moveAndRotateToOuter() rotate([0, 0, 180/8]) cylinder(d=(shellD + width)/cos(180/8), $fn=8, h=100, center=true);
        }
        screws();
        *doveTail(0.8);
        outerHull();
    }
}
module topMount() {
    difference() {
        cutoutHandlebarAndScrews() getHalf(-1) {
            ring();
            // bridge from the ring to the intermediatePoint
            hull() {
                translate([-armThickness/2 - gap, 0, 0]) translateScrew(1) rotate([0,-90,0]) cylinder(d=armThickness, h=armThickness, center=true);
;
                intermediatePoint();
            }
        }
        outerHull();

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
rotate([0, 0, 0]) {
    botMount();
    topMount();
    *holderAssembly();
}
translate([10, 25, armThickness/2 + 1]) rotate([0, -90, 90])
    holderAssembly();
translate([-42, 45, -4]) rotate([180, 0, 0]) insert();
