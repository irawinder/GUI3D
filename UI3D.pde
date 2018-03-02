/*  Camera3D_Basic, Ira Winder, 2018
 *
 *  This script demonstrates the implementation of a "Camera" class that has ready-made UI and smooth camera transitions.
 */
 
Camera cam;
PVector b = new PVector(1000, 1000, 250); //Bounding Box for 3D Environment

Toolbar bar;
int toolbar_width = 250;

PVector objectLocation;

// Initiatizes program on startup
void setup() {
  size(1280, 800, P3D);
  //fullScreen(P3D);
  cam = new Camera (toolbar_width, b);
  bar = new Toolbar(toolbar_width, int(cam.MARGIN*height));
  
  bar.title = "UI3D Visualization Template";
  bar.credit = "Ira Winder, 2018";
  bar.explanation = "Use these scripts as the framework for an explorable 3D model parameterized with sliders and radio buttons.";
  
  objectLocation = new PVector(b.x/2, b.y/2, 0);
}

void draw() {
  background(0);
  
  // Draw 3D Graphics
  cam.orient();
  
  // Draw Object
  pushMatrix();
  translate(objectLocation.x, objectLocation.y, objectLocation.z);
  fill(255); stroke(0); strokeWeight(1);
  box(30, 30, 30);
  popMatrix();
  
  // Draw Rectangle
  fill(244, 200);
  rect(0, 0, b.x, b.y);
  
  // Draw Box
  pushMatrix();
  translate(b.x/2, b.y/2, b.z/2);
  noFill(); stroke(255, 50);
  box(b.x, b.y, b.z);
  popMatrix();

  // Calculate Cursor Location
  float s_x = screenX(objectLocation.x, objectLocation.y, objectLocation.z);
  float s_y = screenY(objectLocation.x, objectLocation.y, objectLocation.z);
  
  // Draw Slider Bars for Controlling Zoom and Rotation (2D canvas begins)
  cam.drawControls();
  
  // Draw Cursor
  noFill();
  stroke(#FFFF00, 200);
  ellipse(s_x, s_y, 50, 50);
  fill(#FFFF00, 200);
  textAlign(LEFT, CENTER);
  text("OBJECT: Move with Arrow Keys", s_x + 30, s_y);
  
  // Draw Margin Toolbar
  bar.draw();
}

void mousePressed() {
  cam.pressed();
  bar.pressed();
}

void mouseReleased() {
  bar.released();
}

void mouseMoved() {
  cam.moved();
}

void keyPressed() {
  cam.moved();
  bar.pressed();
  
  switch(key) {
    case 'r':
      cam.reset();
      bar.restoreDefault();
      break;
    case '-':
      objectLocation.z -= 20;
      break;
    case '+':
      objectLocation.z += 20;
      break;
  }
  
  if (key == CODED) {
    if (keyCode == UP) {
      objectLocation.y -= 20;
    } else if (keyCode == DOWN) {
      objectLocation.y += 20;
    } else if (keyCode == LEFT) {
      objectLocation.x -= 20;
    } else if (keyCode == RIGHT) {
      objectLocation.x += 20;
    } 
  }
}