class FlyingAnt extends Ant {
  
  FlyingAnt(AntHill home, AntSystem antSys) {
    super(home, antSys);
    this.vLimit = 4;
  }

  void draw() {
    super.draw();
    stroke(0, 0, 0, alpha(c) * 0.39);
    fill(8, 8, 8, alpha(c) * 0.08);
    
    float rHeading = this.v.heading();
    float rFlap = radians(map(sin(this.limbAngle*3), -1, 1, -15, 15));
    
    // L wing
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    rotate(rHeading);
    pushMatrix();
    rotate(rFlap+ radians(30));
    ellipse(-13, 0, 15, 5);
    popMatrix();
    popMatrix();
    
    // R wing
    pushMatrix();
    translate(this.pos.x, this.pos.y);
    rotate(rHeading);
    pushMatrix();
    rotate(-rFlap - radians(30));
    ellipse(-13, 0, 15, 5);
    popMatrix();
    popMatrix();
  }
 
}