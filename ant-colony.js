/*
  Foraging ants system

  Ants seek bait.
  Every 2 bait returned to the anthill = new ant.
  30% of new ants have wings.
  Ants have a fixed lifespan.
  Deceased ants decay and are evenutally removed from the system

  Bait is added periodically.
  Click to add bait.
  Ants avoid contact with members of opposing colonies.

*/

var gNumColonies = 2;  // 0-4
var gNumAnts = 2;  // initial number of ants in each colony
var gBaitDelayFactor = 1;  // delay factor between add bait events

strokeWeight(1);


var Target = function(x, y) {
    // position
    if (x === undefined) {
        x = random(10, 390);
    }
    if (y === undefined) {
        y = random(10, 390);
    }
    this.pos = new PVector(x, y);
    this.color = color(133, 230, 227);
};

Target.prototype.draw = function() {
    stroke(0, 0, 0);
    fill(this.color);
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    ellipse(0, 0, 6, 6);
    popMatrix();
};


var AntHill = function(x, y, c, antSys) {
    Target.call(this, x, y);
    this.foodStore = 0;
    this.c = c;  //color
    this.antSys = antSys;
    this.newAntCost = 2;  // add new ant when this many baits returned
};

AntHill.prototype = Object.create(Target.prototype);

AntHill.prototype.draw = function() {
     noStroke();
     fill(this.c);
     pushMatrix();
     translate(this.pos.x, this.pos.y);
     ellipse(0, 0, 15, 15);
     popMatrix();
};

var Ant = function(home, antSys){
    this.pos = new PVector(random(0,width),
                           random(0,height));
    this.v = new PVector(0, 0);  //velocity
    this.a = new PVector(0, 0);//acceleration
    //offsets for perlin noise motion
    this.xoff = random(-50,50);
    this.yoff = random(-50,50);
    this.maxRange = 110;//max range to see a target
    this.t = null; // current target
    var c = home.c;  //color
    this.c = color(red(c), green(c), blue(c), 255);
    this.home = home;  // home location (PVector)
    this.inventory = [];
    this.limbAngle = 0;  // limb rotation angle
    this.limbV = 15;  // limb rotation velocity
    this.age = 0;
    this.antSys = antSys;
    this.maxAge = 2000;  // life of ant (frames)
    this.decayedAge = 3000;  // remove ant from system after X frames
    this.vLimit = 2;
};

var FlyingAnt = function(home, antSys) {
    Ant.call(this, home, antSys);
    this.vLimit = 4;
};


var AntSystem = function(cols, numA, delayF) {
    this.numColonies = cols;  // 0-4
    this.numAnts = numA;  // initial number of ants in each colony
    this.baitDelayFactor = delayF;  // delay factor between add bait events

    this.clock = 0;
    this.baitDelay = 0;
    this.r = new Random(1);

    this.bait = [new Target(), new Target()];

    this.antHills = [new AntHill(10,10, color(179, 16, 16, 128), this),
                    new AntHill(width-10, height-10, color(0, 0, 0, 128), this),
                    new AntHill(10, height-10, color(76, 133, 57, 128), this),
                    new AntHill(width-10, 10, color(179, 170, 6, 128), this)];
    this.ants = [];

    //initalize ants
    for (var i=0; i<this.numAnts; i++) {
        if (this.numColonies > 0) {
            // Red Ants
            this.ants.push(new Ant(this.antHills[0], this));
        }
        if (this.numColonies > 1) {
            // Black Ants
            this.ants.push(new Ant(this.antHills[1], this));
        }
        if (this.numColonies > 2) {
            // Green Ants
            this.ants.push(new Ant(this.antHills[2], this));
        }
        if (this.numColonies > 3) {
            // Yellow Ants
            this.ants.push(new Ant(this.antHills[3], this));
        }
    }
};

// Periodically add a new target "near" the center.
AntSystem.prototype.generateTargets = function() {
  // Location determined by a normal distribution
  this.clock++;
  if (this.clock > this.baitDelay) {
    this.bait.push(new Target(
        this.r.nextGaussian()*60 +width/2,
        this.r.nextGaussian()*60 + height/2));
      this.clock = 0;
      this.baitDelay = this.baitDelayFactor * random(20, 200);
  }
};



Ant.prototype.draw = function() {
    var x = this.pos.x;
    var y = this.pos.y;
    fill(this.c);
    stroke(this.c);
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    rotate(this.v.heading() +90);  // align body with velocity
    // the 90 deg offset is due to the drawing commands being oriented "up"
    // while 0 deg on the grid is "right"
    scale(1.3);  // make the ant bigger
    ellipse(0, 5, 3, 10); // body
    noFill();

    // vary limb angle +/- 25 degrees
    var ra = map(sin(this.limbAngle), -1, 1, -25, 25);

    pushMatrix();
    rotate(ra);
    arc(0,-4, 5, 10, 0, 180); //jaws
    popMatrix();

    pushMatrix();
    translate(0, 5);
    rotate(ra);
    line(-6, 0, 6, 0);  //mid-legs
    popMatrix();

    pushMatrix();
    translate(0, 11);
    rotate(-ra);
    arc(0, 0, 9, 5, 180, 360); //rear legs
    popMatrix();

    popMatrix();

    if (this.inventory.length > 0) {
        this.inventory[0].draw();
    }
};

Ant.prototype.detectBait = function() {
    var nearestD = null;
    var nearestI = null;
    var bait = this.antSys.bait;

    for (var i=0; i<bait.length; i++) {
      // calc distance to all targets
      var dist = PVector.sub(bait[i].pos,
                             this.pos).mag();
      if ( (dist < this.maxRange) &&
      (nearestD===null || dist < nearestD) ) {
          // found a closer target
          nearestD = dist;
          nearestI = i;
      }
    }
    if (nearestI === null) {
        this.t = null; // no target found in range
    } else {
        // assign target
        this.t = bait[nearestI];
    }
};

Ant.prototype.applyForce = function(force) {
    this.a.add(force);
};

// select movement strategy: forage, seek target, return home
Ant.prototype.selectBehavior = function() {
    if (this.home !== this.t) {
        this.detectBait();  // look for bait unless heading home
    }
    if (this.t !== null) {
        // seek target
        var dir = PVector.sub(this.t.pos, this.pos);
        var dist = dir.mag();
        if (dist < 2) {
            if (this.home === this.t) {
                // arrived at home: unload cargo
                this.home.depositBait();
                this.inventory = [];
                this.t = null;
            } else {
              // arrived, collect bait
              this.antSys.bait.splice(this.antSys.bait.indexOf(this.t), 1);
              this.inventory.push(this.t);
              this.t.pos = this.pos;  // pos of bait is same as ant
              this.t = this.home;  // new destinaton: home
            }
        } else {
            // go to target
            dir.normalize();
            dir.mult(20 /  dist);
            this.a.add(dir);
        }
    } else {
        // No target: perlin noise random walker
        this.xoff += 0.01;
        this.yoff += 0.01;
        this.a.x = map(noise(this.xoff),0,1,-0.09, 0.1);
        this.a.y = map(noise(this.yoff),0,1,-0.09, 0.1);
    }
};

Ant.prototype.calculateRepulsion = function(m) {
    var force = PVector.sub(this.pos, m.pos); // Calculate direction of force
    var distance = force.mag(); // Distance between objects

    if (distance > 150) {
        force.mult(0); // too far away, ignore ant
    } else {
        force.normalize();  // get direction
        var strength = 100 / (distance * distance); // Calculate force magnitude
        force.mult(strength); // Get force vector --> magnitude * direction
    }
    return force;
};

Ant.prototype.isAlive = function() {
    if (this.age > this.decayedAge) {
        // remove dead body
        var ants = this.antSys.ants;
        for (var i=0; i<ants.length; i++) {
            if (ants[i] === this) {
             ants.splice(i, 1);
             break;
            }
        }
    }
    else if (this.age > this.maxAge) {
        // dead ant
        var c = this.c;  //reduce color alpha value (ghost ant)
        if (alpha(c) > 100) {
            this.c = color(red(c), green(c), blue(c), 100);
        }
        // return bait to system
        if (this.inventory.length > 0) {
            this.antSys.bait.push(this.inventory[0]);
            this.inventory = [];
        }
    } else {
        // live ant
        return true;
    }
};

Ant.prototype.update = function() {
    this.age += 1;
    if (this.isAlive()) {
        // live ant doing anty things...
        this.selectBehavior();
        this.avoidOthers();

        // apply motion updates
        this.a.limit(0.9);
        this.v.add(this.a);
        this.v.limit(this.vLimit);
        this.pos.add(this.v);
        this.checkBounds();
        this.a.mult(0);

        // move the legs
        this.limbAngle += this.limbV;
        this.limbAngle %= 360;
    }
};

Ant.prototype.checkBounds = function() {
    //keep the ant on the screen
    if (this.pos.x < 2) {
     this.pos.x = 10;
     this.v.x *= -0.5;
     this.a.x = 0;
    } else if (this.pos.x > width-2) {
        this.pos.x = width -10;
        this.v.x *= -0.5;
        this.a.x = 0;
    }
    if (this.pos.y < 2) {
        this.pos.y = 10;
        this.v.y *= -0.5;
        this.a.y *= 0;
    } else if (this.pos.y > height-2) {
        this.pos.y = height -10;
        this.v.y *= -0.5;
        this.a.y = 0;
    }
};

// apply force to avoid ants of different color
Ant.prototype.avoidOthers = function() {
    var ants = this.antSys.ants;
    for (var i=0; i<ants.length; i++) {
        if ( (ants[i].c !== this.c) && ants[i].isAlive()) {
            this.applyForce(this.calculateRepulsion(ants[i]));
        }
    }
};



FlyingAnt.prototype = Object.create(Ant.prototype);

FlyingAnt.prototype.draw = function() {
    Ant.prototype.draw.call(this);
    stroke(0, 0, 0, 100);
    fill(8, 8, 8, 20);

    var rHeading = this.v.heading();
    var rFlap = map(sin(this.limbAngle*3), -1, 1, -15, 15);

    // L wing
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    rotate(rHeading);
    pushMatrix();
    rotate(rFlap+ 30);
    ellipse(-13, 0, 15, 5);
    popMatrix();
    popMatrix();

    // R wing
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    rotate(rHeading);
    pushMatrix();
    rotate(-rFlap - 30);
    ellipse(-13, 0, 15, 5);
    popMatrix();
    popMatrix();
};


AntHill.prototype.depositBait = function() {
    this.foodStore += 1;
    if (this.foodStore >= this.newAntCost) {
        // create a new ant
        this.foodStore -= this.newAntCost;
        var a;
        if (random() < 0.3) {
            a = new FlyingAnt(this, this.antSys);
        } else {
            a = new Ant(this, this.antSys);
        }
        a.pos = this.pos.get();
        this.antSys.ants.push(a);
    }
};

AntSystem.prototype.run = function() {
    this.generateTargets();  // periodically add bait

    for (var i = 0; i < this.numColonies; i++) {
        this.antHills[i].draw();
    }

    for (var i = 0; i < this.bait.length; i++) {
        this.bait[i].draw();
    }

    for (var i = 0; i<this.ants.length; i++) {
        this.ants[i].update();
        this.ants[i].draw();
    }
};

var systemOfAnts = new AntSystem(gNumColonies, gNumAnts, gBaitDelayFactor);

// add new target at mouse coords
mouseClicked = function() {
    var b = 3; // edge buffer size
    if (mouseX > b && mouseX < width-b &&
         mouseY > b && mouseY < height-b) {
      systemOfAnts.bait.push(new Target(mouseX, mouseY));
    }
};

draw = function() {
    background(255, 255, 255);
    systemOfAnts.run();
};
