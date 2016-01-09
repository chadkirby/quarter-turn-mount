use <outer.scad>
handleBarD = 32.2;
thick = 2.5;
width = 12;
direction = -1; // -1 puts the computer to the left of the mount arm; 1 would put the computer to the right, if it weren't broken
armThickness = 12;
desiredGapBetwComputerAndHandlebar = 8;
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
        nutFlat = 7.25,
        throughHoleD = 5,
        nutLen = 100,
        throughLen = length
    );
}
module m4ButtonScrew(length = 6) {
    // translate([0, 0, direction == 1 ? 0 : 5])
    // rotate([0, direction == 1 ? 0 : 180, 0])
    screw(
        headD = 8,
        headLen = 15,
        nutFlat = 7.25,
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
    translate([direction * (-computerDims[0]/2), 0, 0]) moveToOuter() cube(computerDims, center=true);
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
module rotateFastener() {
    rotate([0, 0, direction * 72]) children();
}
module fastenerAssembly() {
    screwHolder(1);
    rotateFastener() screwHolder(-1);
}
module screws() {
    rotate([0, direction == 1 ? 0 : 180, 0]) translateScrew(1) m4PanHeadScrew(10);
    rotateFastener() rotate([0, 180, 0]) translateScrew(-1) m4PanHeadScrew(10);

    moveToIntermediate() rotate([-30, 0, 0]) rotate([0, 0, 180/6]) translate([0, 0, 1]) m4ButtonScrew(4.5);
    translate([0, 0, 0]) moveToFar() rotate([30, 0, 0]) rotate([0, 0, 180/6]) translate([0, 0, 1]) m4ButtonScrew(4.5);
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
module getBottom() {
    intersection() {
        children();
        //translate([-(big/2 + gap), (big/2 + gap), 0]) cube([big, big, big], center=true);
        hull() {
            rotate([0, 180, 0]) {
                moveToIntermediateX() translate([0, width/2, 0]) cylinder(d=width, h=100, center=true);
                moveToIntermediateX() translate([0, 100, 0]) cylinder(d=width, h=100, center=true);
                translate([100, 0, 0]) cylinder(d=width, h=100, center=true);
            }
            rotateFastener() translate([0, -1000, 0]) cylinder(d=0.1, h=100, center=true);
        }
    }
}
module getTop() {
    intersection() {
        children();
        difference() {
            cube([big, big, big], center=true);
            hull() {
                rotate([0, 180, 0]) translate([width/2 - gap, 0, 0]) {
                    translate([0, width/2, 0]) cylinder(d=width, h=100, center=true);
                    translate([0, 100, 0]) cylinder(d=width, h=100, center=true);
                    translate([100, 0, 0]) cylinder(d=width, h=100, center=true);
                }
                rotateFastener() translate([0, -75, 0]) cylinder(r=gap, h=100, center=true);
            }
        }
    }
}

module botMount() {
    getBottom() cutoutHandlebarAndScrews() ring();
}

module moveToOuter() {
    translate([direction * (-armThickness - gap), 0, max(shellD/2, computerDims[2]/2 - width/2)])
        moveYToMountPoint()
            children();
}
module moveAndRotateToOuter(scaleA=[1,1,1]) {
        moveToOuter() rotate([0, direction * 90, 0]) rotate([0,0,90])
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
    translate([direction * -1.5, 0, 0]) {
        difference() {
            outerShell();
            moveAndRotateToOuter() bodyCutouts();
            translate([direction * 1.5, 0, 0])screws();
        }
        moveAndRotateToOuter() bodyAdditions();
    }
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
module moveToIntermediateX() {
    translate([direction * (-armThickness/2 - gap), 0, 0]) children();
}
module moveToIntermediate() {
    moveToIntermediateX() translate([0, handleBarD/2 + offsetFromHandlebar - 11, 0]) children();
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
    rotate([0, 0, 0]) difference() {
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
        cutoutHandlebarAndScrews() getTop() {
            ring();
            // bridge from the ring to the intermediatePoint
            hull() {
                moveToIntermediateX() translateScrew(1) rotate([0,-90,0]) cylinder(d=armThickness, h=armThickness, center=true);
;
                intermediatePoint();
            }
        }
        outerHull();

        // make sure we can rotate the rflkt in and out
        translate([direction * -6, 0, 0]) moveAndRotateToOuter() {
            cylinder(
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
translate([0, direction * 25, armThickness/2 + 2.5]) rotate([0, direction * -90, 90])
    holderAssembly();
translate([-42, 45, -4]) rotate([180, 0, 0]) insert();
