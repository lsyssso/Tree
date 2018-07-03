/**
Author: Siyang Liang 470288382
User can create new planet to move around the big planet in the middle, by clicking left mouse button
User can increase/decrease the size of the new planets by pressing UP and DOWN key
User can change the colour of the new planets by pressing LEFT and RIGHT key
User can rotate the space by dragging the cursor while holding right mouse button
User can zoom in by pressing 'W' and zoom out by pressing 'S'
User can reset camera setting by pressing 'R'
User can clear the image by pressing 'C'
**/

//the maximum radius of new planet
int MAX_RADIUS = 20;
//the minimum radius of new planet
int MIN_RADIUS = 5;
//centre of the image
float CENTRE_X, CENTRE_Y;
//the radius of new planet
int currentRadius;
//a list of preset colour
int[][] colours = {{128, 64, 64}, {64, 128, 64}, {64, 64, 128}, {128, 128, 64}, {128, 64, 128}, {64, 128, 128}, {128, 128, 128}};
//current colour choice
int colourIndex = 0;
//camera variable
float cameraX, cameraY, cameraZ, cameraAngle, cameraDistance;
//planet manager to manage every created planet
PlanetManager pm;

void setup()
{
  size(1680, 1050, P3D);
  smooth();
  background(10, 10, 10);
  noCursor();
  noStroke();
  fill(255, 255, 255);
  //default radius is 10
  currentRadius = 10;
  CENTRE_X = width/2;
  CENTRE_Y = height/2;
  //initial camera angle
  cameraAngle = 90;
  //as we only going to rotate the image around y axis, cameraY is not likely to change
  cameraY = CENTRE_Y;
  //the distance between camera and the centre of the image is 1000
  cameraDistance = 1000;
  //apply maths to get initial x value of camera position
  cameraX = CENTRE_X + cos(radians(cameraAngle)) * cameraDistance;
  //apply maths to get initial z value of camera position
  cameraZ = sin(radians(cameraAngle)) * 1000;
  //create new instance of planet manager
  pm = new PlanetManager();
}

void draw()
{
  clear(); //<>//
  background(10, 10, 10);
  //an ambient light to make image look better
  ambientLight(100, 100, 100);
  //the cursor will be a preview of the new planet going to be created
  pushMatrix();
  //ortho projection to ensure the cursor look the same as it moves around the canvas
  ortho();
  //reset the camera so the cursor always facing the user
  camera();
  translate(mouseX, mouseY, 300);
  //apply a point light to the cursor position
  pointLight(200, 200, 200, mouseX, mouseY, 300);
  //retrieve current colour setting
  fill(colours[colourIndex][0], colours[colourIndex][1], colours[colourIndex][2]);
  //render the cursor
  sphere(currentRadius);
  popMatrix();
  //change it back to perspective view
  perspective();
  //calculate the latest x and z value of camera position
  cameraX = CENTRE_X + cos(radians(cameraAngle)) * cameraDistance;
  cameraZ = sin(radians(cameraAngle)) * cameraDistance;
  //apply camera
  camera(cameraX, cameraY, cameraZ, CENTRE_X, CENTRE_Y, 0.0, 0.0, 1.0, 0.0);
  pm.tick();
}

void mousePressed()
{
  if(mouseButton == LEFT)
  {
    //add a new planet depending on mouse position
    pm.planetList.add(new Planet(currentRadius, new PVector(mouseX * sqrt(cameraDistance/1000), mouseY * sqrt(cameraDistance/1000), 0), colours[colourIndex][0], colours[colourIndex][1], colours[colourIndex][2]));
  }
}

void mouseDragged()
{
  if(mouseButton == RIGHT)
  {
    //the mouse is moving to the right
    if(mouseX > pmouseX)
    {
      //increase camera angle
      cameraAngle += 5;
    }
    //the mouse is moving to the left
    else if(mouseX < pmouseX)
    {
      //decrease camera angle
      cameraAngle -= 5;
    }
  }
}

void keyPressed()
{
  if(keyCode == UP)
  {
    //increase size
    if(currentRadius < MAX_RADIUS)
    {
      currentRadius += 1;
      
    }
  }
  else if(keyCode == DOWN)
  {
    //decrease size
    if(currentRadius > MIN_RADIUS)
    {
      currentRadius -= 1;
    }
  }
  else if(keyCode == RIGHT)
  {
    //switch to next colour
    if(colourIndex == colours.length - 1)
    {
      colourIndex = 0;
    }
    else
    {
      colourIndex += 1;
    }
  }
  else if(keyCode == LEFT)
  {
    //switch to previous colour
    if(colourIndex == 0)
    {
      colourIndex = colours.length - 1;
    }
    else
    {
      colourIndex -= 1;
    }
  }
  //clear all planet
  else if(key == 'c' || key == 'C')
  {
    pm.clear();
  }
  //reset camera angle to default, adjust camera distance to default
  else if(key == 'r' || key == 'R')
  {
    cameraAngle = 90;
    cameraDistance = 1000;
  }
  //decrease camera distance, zoom in
  else if(key == 'w' || key == 'W')
  {
    cameraDistance -= 100;
  }
  //increase camera distance, zoom out
  else if(key == 's' || key == 'S')
  {
    cameraDistance += 100;
  }
}

class Planet
{
  int radius;
  PVector position;
  PVector velocity;
  PVector acceleration;
  //to control the speed of planet movement, to simulate how they move in reaility
  float speedFactor;
  //colour of the planet
  int r, g, b;
  
  Planet(int newRadius, PVector newPosition, int red, int green, int blue)
  {
    radius = newRadius;
    position = newPosition;
    velocity = new PVector(0, 0, -10);
    //my method to work out the speed factor depends on how far it is away from the big planet in the middle
    float xDistance = position.x - CENTRE_X;
    float yDistance = position.y - CENTRE_Y;
    float distance = sqrt(xDistance * xDistance + yDistance * yDistance);
    speedFactor = distance * 3;
    r = red;
    g = green;
    b = blue;
  }
}

class PlanetManager
{
  //a list of planets
  ArrayList<Planet> planetList = new ArrayList<Planet>();
  
  void tick()
  /**
  tick() is called at every frame
  **/
  {
    //render the big planet in the middle
    fill(205, 205, 205);
    pushMatrix();
    translate(CENTRE_X, CENTRE_Y, 0); 
    sphere(150);
    popMatrix();
    float xDistance;
    float yDistance;
    //iterate through the planet list
    for(Planet p: planetList)
    {
      //the force apply to the planet depends on the distance between the planet and the big planet
      xDistance = p.position.x - CENTRE_X;
      yDistance = p.position.y - CENTRE_Y;
      //every frame the force comes from a different direction since the planet move in a circle
      p.acceleration = new PVector(xDistance, yDistance, p.position.z).div(p.speedFactor);
      //modify velocity and position
      p.velocity.sub(p.acceleration);
      p.position.add(p.velocity);
      //start rendering the planet
      pushMatrix();
      //translate to the position of the planet
      translate(p.position.x, p.position.y, p.position.z);
      //change the colour
      fill(p.r, p.g, p.b);
      //draw the sphere
      sphere(p.radius);
      popMatrix();
    }
    
  }
  
  void clear()
  {
    //create a new list to discard the old one
    planetList = new ArrayList<Planet>();
  }
}