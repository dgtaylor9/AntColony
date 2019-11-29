class AntHill extends Target {
  
  int foodStore = 0;
  int c;  //color
  AntSystem antSys;
  int newAntCost = 2;  // add new ant when this many baits returned
  float percentFlying = 0.3;

  AntHill(int x, int y, int c, AntSystem antSys) {
    super(x, y);
    foodStore = 0;
    this.c = c;  //color
    this.antSys = antSys;
    newAntCost = 2;  // add new ant when this many baits returned
  }
  
  void draw() {
    noStroke();
    fill(c);
    pushMatrix();
    translate(pos.x, pos.y);
    ellipse(0, 0, 15, 15);
    popMatrix();
  }
  
  void depositBait() {
    foodStore += 1;
    if (foodStore >= newAntCost) {
      // create a new ant
      foodStore -= newAntCost;
      Ant a;
      if (random(1) < percentFlying) {
          a = new FlyingAnt(this, antSys);
      } else {
          a = new Ant(this, antSys);
      }
      a.pos = pos.copy();
      antSys.ants.add(a);
    }
  }

}