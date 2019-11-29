/*
  Foraging ants system
  
  Ants seek bait.
  Every 2 bait returned to the anthill = new ant.
  30% of new ants have wings.
  Ants have a fixed lifespan.
  Deceased ants decay and are eventually removed from the system.
  
  Bait is added periodically.
  Click to add bait.
  Ants avoid contact with members of opposing colonies.
*/

int gNumColonies = 4;  // 0-4
int gNumAnts = 2;  // initial number of ants in each colony
float gBaitDelayFactor = 1;  // delay factor between add bait events
AntSystem systemOfAnts;

void setup() {
  size(800, 800);
  strokeWeight(1);
  systemOfAnts = new AntSystem(gNumColonies, gNumAnts, gBaitDelayFactor);
}

void draw() {
  background(255, 255, 255);
  systemOfAnts.run(); //<>//
}

// add new target at mouse coords
void mouseClicked() {
  int b = 3; // edge buffer size
  if (mouseX > b && mouseX < width-b && mouseY > b && mouseY < height-b) {
    systemOfAnts.bait.add(new Target(mouseX, mouseY));
  }
}
