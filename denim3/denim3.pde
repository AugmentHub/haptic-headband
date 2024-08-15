int carX, carY;
float worldAngle = 0;
int gridSize = 75;
int gridWidth = 10;
int gridHeight = 10;
boolean targetReached = false;
int flashStartTime;
float worldX = 400;
float worldY = 400;
float targetX, targetY;  // Declare targetX and targetY here
boolean successSent;

boolean upPressed = false;
boolean downPressed = false;
boolean leftPressed = false;
boolean rightPressed = false;
boolean targetToggle = false;
boolean mute = false;

import processing.serial.*;

Serial myPort;  // The serial port
String command = "pulse 0 0 250";  // The command you want to send

void setup() {
  //size(800, 800);
  fullScreen();
  carX = width / 2;
  carY = height / 2;
  worldX = (gridWidth * gridSize) / 2;
  worldY = (gridHeight * gridSize) / 2;
  placeTarget();
  
  println(Serial.list());

  // Change the 0 to the correct index of your serial port in the list
  String portName = Serial.list()[3];

  // Open the serial port at 9600 baud rate
  myPort = new Serial(this, portName, 9600);
}

void draw() {
  background(200, 200, 255);
  
  pushMatrix();
  translate(carX, carY);   // Translate to the car's position (center of the screen)
  rotate(-worldAngle);     // Rotate the world around the car

  drawGrid();

  if (!targetReached) {
    checkTarget();
    showHint();
    
    if(frameCount % 5 == 0) {
      command = "pulse "+int(angle)+" "+ (mute ? "80":"0") + " " + str(int(map(distance, 0, 800, 105, 360))) +"\n";
      println(command);
      println("Target: " + targetX + ", " + targetY);
      println("World: " + worldX + ", " + worldY);
      println("worldAngle: " + worldAngle);
      myPort.write(command);
    }
    
    if(isTargetVisible) {
      strokeWeight(10);
      stroke(255, 0, 0);
      fill(200);
      ellipse(targetX - worldX, targetY - worldY, 50, 50);
      noStroke();
    }
    
  } else {
    if(!successSent) {
      myPort.write("success\n");
      successSent = true;
    }
    int t = millis() - flashStartTime;
    if (t < 2000) {
      strokeWeight(0);
      fill(0, 255 * ((t/400) % 2), 100 * ((t/400) % 2));
      ellipse(targetX - worldX, targetY - worldY, 60, 60);
    } else {
      targetReached = false;
      placeTarget();
    }
  }
  
  if (upPressed) {
    float newWorldX = worldX + sin(worldAngle) * 5;
    float newWorldY = worldY - cos(worldAngle) * 5;
    if (canMoveTo(newWorldX, newWorldY)) {
      worldX = newWorldX;
      worldY = newWorldY;
    }
  } if (downPressed) {
    float newWorldX = worldX - sin(worldAngle) * 5;
    float newWorldY = worldY + cos(worldAngle) * 5;
    if (canMoveTo(newWorldX, newWorldY)) {
      worldX = newWorldX;
      worldY = newWorldY;
    }
  } if (leftPressed) {
    worldAngle -= 0.03;
  } if (rightPressed) {
    worldAngle += 0.03;
  } if (targetToggle) {
    isTargetVisible = !isTargetVisible;
    targetToggle = false;
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
  targetX = int(random(1, gridWidth-1)) * gridSize + gridSize / 2;
  targetY = int(random(1, gridHeight-1)) * gridSize + gridSize / 2;
}

void checkTarget() {
  float distance = dist(targetX, targetY, worldX, worldY);
  if (distance < 40) {
    targetReached = true;
    successSent = false;
    flashStartTime = millis();
  }
}

float angle;
float distance;

void showHint() {
  float angleToTarget = radians(360) - atan2(targetX - worldX, targetY - worldY);
  
  float angleDifference = angleToTarget - worldAngle;
  
  while (angleDifference > TWO_PI) {
    angleDifference -= TWO_PI;
  }
  while (angleDifference < 0) {
    angleDifference += TWO_PI;
  }
  
  String hint = "";
  distance = int(dist(targetX, targetY, worldX, worldY));
  angle = int(degrees(angleDifference)/22.5);
  angle = (angle) % 16;
  hint = str(angle)+", "+str(distance);
  
  fill(0);
  textAlign(CENTER);
  textSize(16);
  text(hint, width / 2, height - 20);
}

boolean isTargetVisible = true;

void keyPressed() {
  if (key == 'w' || keyCode == UP) {
    upPressed = true;
  }
  if (key == 's' || keyCode == DOWN) {  
    downPressed = true;
  }
  if (key == 'a' || keyCode == LEFT) {
    leftPressed = true;
  }
  if (key == 'd' || keyCode == RIGHT) {
    rightPressed = true;
  }
}

void keyReleased() {
  if (key == 'w' || keyCode == UP) {
    upPressed = false;
  }
  if (key == 's' || keyCode == DOWN) {
    downPressed = false;
  }
  if (key == 'a' || keyCode == LEFT) {
    leftPressed = false;
  }
  if (key == 'd' || keyCode == RIGHT) {
    rightPressed = false;
  }
  
  if (key == 't') {
    targetToggle = true;
  }
  if (key == 'm') {
    mute = !mute;
  }
}

boolean canMoveTo(float newWorldX, float newWorldY) {
  return true;
}
