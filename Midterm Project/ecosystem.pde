// Preys and predators are both movers
int num_preys = 10;
int timeElapsed = 0;
int lowAge = 40;
int highAge = 60;
int youngColor = color(15,155,15);
int oldColor = color(0, 0, 0);
FoodGenerator FG = new FoodGenerator();
Mover[] prey = new Mover[num_preys];
Mover predator;

// #TODO: All preys within a distance to the predator gains speed boost; Preys steer for food and increment hunger; predator rests after forage 

void setup() {
  size(1800, 1000);

  for (int i = 0; i < prey.length; i++) {
    // Each prey is initialized randomly.
    prey[i] = new Mover(random(1, 5), // mass
      random(width), random(height), "prey"); // initial location
  }
  // Predator has a heavier mass, less agile than its preys
  predator = new Mover(random(1,5), random(width), random(height), "predator");
}

void draw() {
  background(255);

  //timeElapsed = millis()/1000;
  text("Time elapsed: "+timeElapsed, 200, 100);  
  
  if(timeElapsed != millis()/1000){
    timeElapsed = millis()/1000;
    for (int i = 0; i < prey.length; i++) {
      if(prey[i] != null) prey[i].hunger_trigger();
    }
    
    if(timeElapsed % 5 == 0){
      FG.generateNew(timeElapsed);
    }
    //print(timeElapsed);
  }
  
  
  int idx = 0;
  float minDist = sqrt(1800*1800+1000*1000);
  // For each mprey
  for (int i = 0; i < prey.length; i++) {
    if (prey[i] != null){
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
  }
  // The predator is only attracted to the nearest prey
  //PVector force = prey[idx].attract(predator);
  // print(idx);
  //predator.applyForce(force);
  predator.seek(prey[idx].location);
  // The prey being chased would also run faster
  PVector escapeForce = prey[idx].attract(predator).mult(1.5);
  prey[idx].applyForce(escapeForce);
  for(int i=0; i<prey.length; i++){
    if(prey[i] != null){
      prey[i].update();
    prey[i].checkEdges();
    }
  }
  
  predator.update();
  // Check prey eaten by predator
  for(int i=0; i<prey.length; i++){
    if(prey[i]!=null && predator.checkEaten(prey[i])){
      prey[i] = null;
      predator.hunger = 100;
    }
  }
  
  for(int i=0; i<prey.length; i++){
    if(prey[i] != null){
      prey[i].display();
    }
  }
  predator.checkEdges();
  predator.display();
  FG.display(); 
}


class Food {
  PVector location;
  int average_size = 20;
  float size;
  
  Food(){
    location = new PVector(random(width), random(height));
    size = random(-10.0, 10.0) + average_size;
  }
  
  void display(){
    stroke(0);
    fill(255, 143, 163);
    circle(location.x, location.y, size*0.7);
  }
  
  boolean checkEaten(PVector m){
    if(abs(m.x - location.x) <= size && abs(m.y - location.y) <= size){
      return true;
    }else{
      return false;
    }
  }

}



class FoodGenerator {
  Food[] food_array;
  int min_food_num = 2;
  int average_size = 20;
  int variance = 8;
  int food_cnt = 0;
  int max_food = 10;
  
  FoodGenerator(){
    food_array = new Food[max_food];
    for(int i=0; i<food_array.length; i++){
      food_array[i] = null;
    }
  }

  void generateNew(int timeElapsed){
    int gen_num = round(noise(timeElapsed * 0.1) * variance);  
    if(gen_num + food_cnt > max_food) gen_num = max_food - food_cnt;
    
    int i = 0;
    int cnt = 0;
    while(cnt<gen_num){
      if(food_array[i] == null){
        food_array[i] = new Food();
        food_cnt += 1;
        cnt += 1;
      }
      i = (i+1) % food_array.length;
    }
  }
  
  void trackFood(Mover[] prey){
    for(int i=0; i<food_array.length; i++){
      if(food_array[i] != null){
        Food target = food_array[i];
        for(int j=0; j<prey.length; j++){
          if(prey[j] != null && target.checkEaten(prey[j].location)){
            prey[j].hunger += target.size;
            food_array[i] = null;
            food_cnt -= 1;
          }
        }
      }
    }
  
  }
  
  void display() {
    for(int i=0; i<food_array.length; i++){
      if(food_array[i] != null){
        food_array[i].display();
      }
    }
  }

}


// Predator is blue and preys are green
class Mover {

  PVector location;
  PVector velocity;
  PVector acceleration;
  int hunger;
  float mass;
  float G = 0.4;
  String type;
  int age;
  int maxAge;

  Mover(float _mass_, float _x_, float _y_, String _type) {
    mass = _mass_;
    location = new PVector(_x_, _y_);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    type = _type;
    hunger = 100;
    age = 0;
    maxAge = int(random(float(lowAge), float(highAge)));
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
    else if (type=="prey" && m.type=="predator") force.mult(5);

    return force;
  }
  
  void seek(PVector target) {
    PVector desired = PVector.sub(target,location);
    desired.normalize();
    desired.mult(mass*0.6);
    PVector steer = PVector.sub(desired,velocity);
    //steer.limit(maxforce);
    applyForce(steer);
  }

  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
  }

  void display() {
    
    if (hunger <= 0){
        stroke(255, 0, 0);
      }else{
        stroke(0);
      }
    
    if (type == "prey"){
      //println(age/float(maxAge));
      color displayedColor = lerpColor(youngColor, oldColor, age/float(maxAge));
      //println(displayedColor);
      fill(displayedColor);
    } 
    
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

void hunger_trigger() {
    if(hunger>0){
      hunger -= 5; 
    }
    if(hunger<=0){
      maxAge -= 1;
    }
    age += 1;
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
  
  boolean checkEaten(Mover m) {
    if( abs(location.x - m.location.x) <= 10 && abs(location.y - m.location.y) <= 10 ){
        return true;
    }else{
      return false;
    }
  }
  
}
