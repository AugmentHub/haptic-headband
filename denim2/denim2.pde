int carX, carY;
float carAngle;
int targetX, targetY;
boolean targetReached = false;
int flashStartTime;

import processing.serial.*;

Serial myPort;  // The serial port
String command = "pulse 0 0 250";  // The command you want to send

void setup() {
  size(800, 800);
  carX = width / 2;
  carY = height / 2;
  carAngle = 0;
  placeTarget();
  
  println(Serial.list());

  // Change the 0 to the correct index of your serial port in the list
  String portName = Serial.list()[3];

  // Open the serial port at 9600 baud rate
  myPort = new Serial(this, portName, 9600);
}

void draw() {
  background(200, 255, 200);
  
  if (!targetReached) {
    checkTarget();
    showHint();
    
    if(frameCount % 30 == 0) {
      myPort.write("pulse "+angle+" "+str(int(map(distance, 0, 800, 220, 75))) + " " + 100);
    }
    
    if(isTargetVisible) {
      fill(255, 110, 0);
      ellipse(targetX, targetY, 60, 60);
    }
    
  } else {
    int t = millis() - flashStartTime;
    if (t < 2000) {
      strokeWeight(0);
      fill(0, 0, 255 * ((t/400) % 2));
      ellipse(targetX, targetY, 60, 60);
    } else {
      targetReached = false;
      placeTarget();
    }
  }
  
  drawCar();
}

void drawCar() {
  pushMatrix();
  translate(carX, carY);
  rotate(carAngle);
  fill(0);
  rectMode(CENTER);
  rect(0, 0, 40, 20);
  popMatrix();
}

void placeTarget() {
  targetX = int(random(30, width - 30));
  targetY = int(random(30, height - 30));
}

void checkTarget() {
  float distance = dist(carX, carY, targetX, targetY);
  if (distance < 30) {
    targetReached = true;
    flashStartTime = millis();
  }
}

float angle;
float distance;

void showHint() {
  float angleToTarget = atan2(targetY - carY, targetX - carX);
  float angleDifference = angleToTarget - carAngle;
  
  while (angleDifference > TWO_PI) {
    angleDifference -= TWO_PI;
  }
  while (angleDifference < 0) {
    angleDifference += TWO_PI;
  }
  
  String hint = "";
  distance = int(dist(targetX, targetY, carX, carY));
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
    carX += cos(carAngle) * 5;
    carY += sin(carAngle) * 5;
  } else if (keyCode == DOWN) {
    carX -= cos(carAngle) * 5;
    carY -= sin(carAngle) * 5;
  } else if (keyCode == LEFT) {
    carAngle -= 0.1;
  } else if (keyCode == RIGHT) {
    carAngle += 0.1;
  } else if (key == 't') {
    isTargetVisible = !isTargetVisible;
  }
}
