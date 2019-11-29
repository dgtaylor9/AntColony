import java.util.Random;

class AntSystem {

  int numColonies;
  int numAnts;
  int baitDelay;
  float baitDelayFactor;
  int clock;
  ArrayList<Target> bait = new ArrayList();
  AntHill[] antHills = new AntHill[4];
  ArrayList<Ant> ants = new ArrayList();
  int foodStore = 0;
  
  
  AntSystem(int cols, int numA, float delayF) {
    numColonies = cols;  // 0-4
    numAnts = numA;  // initial number of ants in each colony
    baitDelayFactor = delayF;  // delay factor between add bait events

    clock = 0;
    baitDelay = 0;

    bait.add(new Target());
    bait.add(new Target());
    
    antHills[0] = new AntHill(10,10, color(179, 16, 16, 128), this);
    antHills[1] = new AntHill(width-10, height-10, color(0, 0, 0, 128), this);
    antHills[2] = new AntHill(10, height-10, color(76, 133, 57, 128), this);
    antHills[3] = new AntHill(width-10, 10, color(179, 170, 6, 128), this);
    
    //initalize ants
    for (int i=0; i<numAnts; i++) {
      if (numColonies > 0) {
          // Red Ants
          ants.add(new Ant(antHills[0], this));
      }
      if (numColonies > 1) {
          // Black Ants
          ants.add(new Ant(antHills[1], this));
      }
      if (numColonies > 2) {
          // Green Ants
          ants.add(new Ant(antHills[2], this));
      }
      if (numColonies > 3) {
          // Yellow Ants
          ants.add(new Ant(antHills[3], this));
      }
    }
  }

  // Periodically add a new target "near" the center.
  void generateTargets() {
    // Location determined by a normal distribution
    clock++;
    if (clock > baitDelay) {
      bait.add(new Target( (int) (randomGaussian()*150 + width/2),
                           (int) (randomGaussian()*150 + height/2)));
      clock = 0;
      baitDelay = (int)(baitDelayFactor * (float) random(20, 200));
    }
  }

  void run() {
    generateTargets();  // periodically add bait
    for (int i = 0; i < numColonies; i++) {
        antHills[i].draw();
    }
    for (int i = 0; i < bait.size(); i++) {
        bait.get(i).draw();
    }
    for (int i = 0; i<ants.size(); i++) {
        ants.get(i).draw();
        ants.get(i).update();
    }
  }
 
}