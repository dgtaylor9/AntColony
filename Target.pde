class Target {
  
  PVector pos;
  int c;
  
  Target() {
    this(0,0); 
  }
  
  Target(int x, int y) {
    if (x == 0) { x = (int) random(10, 390); } // position
    if (y == 0) { y = (int) random(10, 390); }
    
    pos = new PVector(x, y);
    checkBounds(pos);
    c = color(133, 230, 227);
  }

  void draw() {
    stroke(0, 0, 0);
    fill(c);
    pushMatrix();
    translate(pos.x, pos.y);
    ellipse(0, 0, 6, 6);
    popMatrix();
  }
 
   void checkBounds(PVector pos) {
    //keep the target on the screen
    if (pos.x < 2) {
      pos.x = 10;
    } 
    else if (pos.x > width-2) {
      pos.x = width -10;
    }
    if (pos.y < 2) {
      pos.y = 10;
    } 
    else if (pos.y > height-2) {
      pos.y = height -10;
    }
  }
  
}