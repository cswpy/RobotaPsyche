// Preys and predators are both movers
Mover[] prey = new Mover[10];
Mover predator;
Attractor a;
void setup() {
  size(1800, 1000);

  for (int i = 0; i < prey.length; i++) {
    // Each prey is initialized randomly.
    prey[i] = new Mover(random(1, 5), // mass
      random(width), random(height), "prey"); // initial location
  }
  // Predator has a heavier mass, less agile than its preys
  predator = new Mover(random(5,10), random(width), random(height), "predator");
}

void draw() {
  background(255);

  int idx = 0;
  float minDist = sqrt(1800*1800+1000*1000);
  // For each mprey
  for (int i = 0; i < prey.length; i++) {

    // All the preys would run away from the predator
    PVector force = predator.attract(prey[i]);
    prey[i].applyForce(force);
    //PVector aForce = a.attract(prey[i]);
    //prey[1].applyForce(aForce);
    
    // Note down the minimum distance between the preys and the predator
    float dist = PVector.dist(predator.location, prey[i].location);
    if (dist < minDist){
      minDist = dist;
      idx = i;
    }
  }
  // The predator is only attracted to the nearest prey
  PVector force = predator.attract(prey[idx]);
  // print(idx);
  predator.applyForce(force);
  // The prey being chased would also run faster
  PVector escapeForce = prey[idx].attract(predator).mult(2.5);
  prey[idx].applyForce(escapeForce);
  for(int i=0; i<prey.length; i++){
    prey[i].update();
    prey[i].checkEdges();
    prey[i].display();
  }
  predator.update();
  predator.checkEdges();
  predator.display();
    
}


class Attractor {
  float mass;
  PVector location;
  float G;

  Attractor() {
    location = new PVector(width/2, height/2);

    // Big mass so the force is greater than vehicle-vehicle force
    mass = 70;
    G = 0.4;
  }

  PVector attract(Mover m) {
    PVector force = PVector.sub(location, m.location);
    float distance = force.mag();


    distance = constrain(distance, 5.0, 25.0);

    force.normalize();
    float strength = (G * mass * m.mass) / (distance * distance);
    force.mult(strength);
    return force;
  }

  void display() {
    stroke(0);
    fill(175, 200);
    ellipse(location.x, location.y, mass*2, mass*2);
  }
}


// Predator is blue and preys are red
class Mover {

  PVector location;
  PVector velocity;
  PVector acceleration;
  float mass;
  float G = 0.4;
  String type;

  Mover(float _mass_, float _x_, float _y_, String _type) {
    mass = _mass_;
    location = new PVector(_x_, _y_);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    type = _type;
  }

  // Newton’s second law.
  void applyForce(PVector force) {
    // Receive a force, divide by mass, and add to acceleration.
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  // The Mover now knows how to attract another Mover.
  PVector attract(Mover m) {

    PVector force = PVector.sub(location, m.location);
    float distance = force.mag();
    distance = constrain(distance, 5.0, 25.0);
    force.normalize();

    float strength = (G * mass * m.mass) / (distance * distance);
    force.mult(strength);

    // If the color is different then we will be repelled
    if (type=="predator" && m.type=="prey") force.mult(-1);
    else if (type=="prey" && m.type=="predator") force.mult(2.5);

    return force;
  }


  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
  }

  void display() {
    stroke(0);
    if (type == "prey") fill(255, 0, 0);
    else fill (0, 0, 255);

    // Rotate the mover to point in the direction of travel
    // Translate to the center of the move
    pushMatrix();
    translate(location.x, location.y);
    rotate(velocity.heading());
    // It took lots of trial and error
    // and sketching on paper
    // to get the triangle
    // pointing in the right direction
    triangle(0, 5, 0, -5, 20, 0);
    popMatrix();
  }

  // With this code an object bounces when it hits the edges of a window.
  // Alternatively objects could vanish or reappear on the other side
  // or reappear at a random location or other ideas. Also instead of
  // bouncing at full-speed vehicles might lose speed. So many options!

  void checkEdges() {
    if (location.x > width) {
      location.x = width;
      velocity.x *= -1; // full velocity, opposite direction
      velocity.x *= 0.8; // lose a bit of energy in the bounce
    } else if (location.x < 0) {
      location.x = 0;
      velocity.x *= -1; // full velocity, opposite direction
      velocity.x *= 0.8; // lose a bit of energy in the bounce
    }

    if (location.y > height) {
      location.y = height;
      velocity.y *= -1; // full velocity, opposite direction
      velocity.y *= 0.8; // lose a bit of energy in the bounce
    } else if (location.y < 0) {
      location.y = 0;
      velocity.y *= -1; // full velocity, opposite direction
      velocity.y *= 0.8; // lose a bit of energy in the bounce
    }
  }
}
