int carX, carY;
float worldAngle = 0;
int gridSize = 50;
int gridWidth = 16;
int gridHeight = 16;
boolean targetReached = false;
int flashStartTime;
float worldX, worldY;
float targetX, targetY;  // Declare targetX and targetY here

import processing.serial.*;

Serial myPort;  // The serial port
String command = "pulse 0 0 250";  // The command you want to send

void setup() {
  size(800, 800);
  carX = width / 2;
  carY = height / 2;
  worldX = (gridWidth * gridSize) / 2 - carX;
  worldY = (gridHeight * gridSize) / 2 - carY;
  placeTarget();
  
  println(Serial.list());

  // Change the 0 to the correct index of your serial port in the list
  String portName = Serial.list()[3];

  // Open the serial port at 9600 baud rate
  myPort = new Serial(this, portName, 9600);
}

void draw() {
  background(200, 255, 200);
  
  pushMatrix();
  translate(carX, carY);   // Translate to the car's position (center of the screen)
  rotate(-worldAngle);     // Rotate the world around the car

  drawGrid();

  if (!targetReached) {
    checkTarget();
    showHint();
    
    if(frameCount % 30 == 0) {
      myPort.write("pulse "+angle+" "+str(int(map(distance, 0, 800, 220, 75))) + " " + 100);
    }
    
    if(isTargetVisible) {
      fill(255, 110, 0);
      ellipse(targetX - worldX, targetY - worldY, 60, 60);
    }
    
  } else {
    int t = millis() - flashStartTime;
    if (t < 2000) {
      strokeWeight(0);
      fill(0, 0, 255 * ((t/400) % 2));
      ellipse(targetX - worldX, targetY - worldY, 60, 60);
    } else {
      targetReached = false;
      placeTarget();
    }
  }
  
  popMatrix();

  drawCar();  // Draw car after popMatrix to keep it non-rotated
}

void drawGrid() {
  for (int i = 0; i < gridWidth; i++) {
    for (int j = 0; j < gridHeight; j++) {
      if ((i + j) % 2 == 0) {
        fill(150);
      } else {
        fill(100);
      }
      rect(i * gridSize - worldX, j * gridSize - worldY, gridSize, gridSize);
    }
  }
}

void drawCar() {
  fill(0);
  rectMode(CENTER);
  rect(carX, carY, 20, 40, 10, 10, 0, 0);
}

void placeTarget() {
  targetX = int(random(0, gridWidth)) * gridSize + gridSize / 2;
  targetY = int(random(0, gridHeight)) * gridSize + gridSize / 2;
}

void checkTarget() {
  float distance = dist(carX, carY, targetX - worldX, targetY - worldY);
  if (distance < 30) {
    targetReached = true;
    flashStartTime = millis();
  }
}

float angle;
float distance;

void showHint() {
  float angleToTarget = atan2(targetY - worldY - carY, targetX - worldX - carX);
  float angleDifference = angleToTarget + worldAngle;
  
  while (angleDifference > TWO_PI) {
    angleDifference -= TWO_PI;
  }
  while (angleDifference < 0) {
    angleDifference += TWO_PI;
  }
  
  String hint = "";
  distance = int(dist(targetX - worldX, targetY - worldY, carX, carY));
  angle = int(degrees(angleDifference)/22.5);
  hint = str(angle)+", "+str(distance);
  
  fill(0);
  textAlign(CENTER);
  textSize(16);
  text(hint, width / 2, height - 20);
}

boolean isTargetVisible = true;
void keyPressed() {
  if (keyCode == UP) {
    float newWorldX = worldX + sin(worldAngle) * 5;
    float newWorldY = worldY - cos(worldAngle) * 5;
    if (canMoveTo(newWorldX, newWorldY)) {
      worldX = newWorldX;
      worldY = newWorldY;
    }
  } else if (keyCode == DOWN) {
    float newWorldX = worldX - sin(worldAngle) * 5;
    float newWorldY = worldY + cos(worldAngle) * 5;
    if (canMoveTo(newWorldX, newWorldY)) {
      worldX = newWorldX;
      worldY = newWorldY;
    }
  } else if (keyCode == LEFT) {
    worldAngle -= 0.03;
  } else if (keyCode == RIGHT) {
    worldAngle += 0.03;
  } else if (key == 't') {
    isTargetVisible = !isTargetVisible;
  }
}

boolean canMoveTo(float newWorldX, float newWorldY) {
  return true;
}
