class Ant {
  
  PVector pos, v, a;
  float xoff; //offsets for perlin noise motion
  float yoff;
  int maxRange = 110;//max range to see a target
  Target t; // current target
  int c;  //color
  AntHill home;  // home location (PVector)
  ArrayList<Target> inventory = new ArrayList();
  float limbAngle = 0.0;  // limb rotation angle
  float limbV = 0.3;  // limb rotation velocity, radians
  int age = 0;
  AntSystem antSys;
  int maxAge = 2000;  // life of ant (frames)
  int decayedAge = 3000;  // remove ant from system after X frames
  float alphaDecay = 255.0 / ((float) (decayedAge - maxAge) );
  float deadAlpha;
  int vLimit = 2;
    
  Ant(AntHill home, AntSystem antSys){
    pos = new PVector(random(0,width), random(0,height));
    v = new PVector(0, 0);  //velocity
    a = new PVector(0, 0);//acceleration
    //offsets for perlin noise motion
    xoff = random(-50,50);
    yoff = random(-50,50);
    c = home.c;  //color
    c = color(red(c), green(c), blue(c), 255);
    deadAlpha = 255.0;
    this.home = home;  // home location (PVector)
    this.antSys = antSys;
  } 
  
  void draw() {
    fill(c);
    stroke(c);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(v.heading() + radians(90));  // align body with velocity
    // the 90 deg offset is due to the drawing commands being oriented "up"
    // while 0 deg on the grid is "right"
    scale(1.3);  // make the ant bigger
    ellipse(0, 5, 3, 10); // body
    noFill();
    
    // vary limb angle +/- 25 degrees
    float ra = radians(map(sin(limbAngle), -1, 1, -25, 25));
    
    pushMatrix();
    rotate(ra);
    arc(0,-4, 5, 10, 0, PI); //jaws
    popMatrix();
    
    pushMatrix();
    translate(0, 5);
    rotate(ra);
    line(-6, 0, 6, 0);  //mid-legs
    popMatrix();
    
    pushMatrix();
    translate(0, 11);
    rotate(-ra);
    arc(0, 0, 9, 5, PI, TWO_PI); //rear legs
    popMatrix();
    
    popMatrix();
    
    if (inventory.size() > 0) { inventory.get(0).draw(); }
  }


  void detectBait() {
    float nearestD = -1.0;
    int nearestI = -1;
    ArrayList<Target> bait = antSys.bait;
    
    for (int i=0; i<bait.size(); i++) {
      // calc distance to all targets
      float dist = PVector.sub(bait.get(i).pos, pos).mag();
      if ( (dist < maxRange) && (nearestD==-1.0 || dist < nearestD) ) {
          // found a closer target
          nearestD = dist;
          nearestI = i;
      }
    }
    t = nearestI == -1 ? null : bait.get(nearestI);
  }


  void applyForce(PVector force) {
    a.add(force);
  }
  

  // select movement strategy: forage, seek target, return home
  void selectBehavior() {
    if (home != t) {
      detectBait();  // look for bait unless heading home
    }
    if (t != null) {
      // seek target
      PVector dir = PVector.sub(t.pos, pos);
      float dist = dir.mag();
      if (dist < 2) {
        if (home == t) {
          // arrived at home: unload cargo
          home.depositBait();
          inventory.clear();
          t = null;
        } 
        else {
          // arrived, collect bait
          antSys.bait.remove(t);
          inventory.add(t);
          t.pos = pos;  // pos of bait is same as ant
          t = home;  // new destinaton: home
        }
      } 
      else {
        // go to target
        dir.normalize();
        dir.mult(maxRange/dist);
        a.add(dir);
        if (dist < 10) {
          a.add(v.copy().mult(-1/dist));  // decelerate: anti-orbit factor
        }
      }
    } 
    else {
      // No target: perlin noise random walker
      xoff += 0.01;
      yoff += 0.01;
      a.x = map(noise(xoff),0,1,-0.09, 0.1);
      a.y = map(noise(yoff),0,1,-0.09, 0.1);
    }
  }


  PVector calculateRepulsion(Ant m) {
    PVector force = PVector.sub(pos, m.pos); // Calculate direction of force
    float distance = force.mag(); // Distance between objects
    if (distance > 150) {
      force.mult(0); // too far away, ignore ant
    } 
    else {
      force.normalize();  // get direction
      float strength = 100 / (distance * distance); // Calculate force magnitude
      force.mult(strength); // Get force vector --> magnitude * direction
    }
    return force;
  }


  boolean isAlive() {
    boolean isLiving = false;
    if (age > decayedAge) {
      // remove dead body
      antSys.ants.remove(this);
    }
    else if (age > maxAge) {
      // dead ant
      //reduce color alpha value (ghost ant)
      deadAlpha -= alphaDecay;
      if (deadAlpha < 1) deadAlpha = 1;
      c = color(red(c), green(c), blue(c), (int) deadAlpha);
      // return bait to system
      if (inventory.size() > 0) { //<>//
        antSys.bait.add(inventory.get(0));
        inventory.clear();
      }
    } 
    else {
      isLiving = true; // live ant
    }
    return isLiving;
  }


  void update() {
    age += 1;
    if (isAlive()) {
      // live ant doing anty things...
      selectBehavior();
      avoidOthers(); 
  
      // apply motion updates
      a.limit(0.95);
      v.add(a);
      v.limit(vLimit);
      pos.add(v);
      checkBounds();
      a.mult(0);
      
      // move the legs
      limbAngle += limbV;
      limbAngle %= radians(360);
    }
  }


  void checkBounds() {
    //keep the ant on the screen
    if (pos.x < 2) {
      pos.x = 10;
      v.x *= -0.5;
      a.x = 0;
    } 
    else if (pos.x > width-2) {
      pos.x = width -10;
      v.x *= -0.5;
      a.x = 0;
    }
    if (pos.y < 2) {
      pos.y = 10;
      v.y *= -0.5;
      a.y *= 0;
    } 
    else if (pos.y > height-2) {
      pos.y = height -10;
      v.y *= -0.5;
      a.y = 0;
    }
  }


  // apply force to avoid ants of different color
  void avoidOthers() {
    ArrayList<Ant> ants = antSys.ants;
    for (int i=0; i<ants.size(); i++) {
      Ant other = ants.get(i);
      if ( (other.c != c) && other.isAlive()) {
        applyForce(calculateRepulsion(other));   
      }
    }
  }

}