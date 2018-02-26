/*  Camera3D_Basic, Ira Winder, 2018
 *
 *  This script demonstrates the implementation of a "Camera" class that has ready-made UI and smooth camera transitions.
 */
 
Camera cam;
PVector b = new PVector(1000, 1000, 250); //Bounding Box for 3D Environment

Toolbar bar;
int toolbar_width = 250;

// Initiatizes program on startup
void setup() {
  size(1280, 800, P3D);
  //fullScreen(P3D);
  cam = new Camera (toolbar_width, b);
  bar = new Toolbar(toolbar_width, int(cam.MARGIN*height));
  
  bar.title = "UI3D Visualization Template";
  bar.credit = "Ira Winder, 2018";
  bar.explanation = "Use these scripts as the framework for an explorable 3D model parameterized with sliders and radio buttons.";
}

void draw() {
  background(0);
  
  // Draw 3D Graphics
  cam.orient();
  
  // Draw Rectangle
  fill(244, 200);
  rect(0, 0, b.x, b.y);
  
  // Draw Box
  translate(b.x/2, b.y/2, b.z/2);
  noFill();
  stroke(255, 50);
  box(b.x, b.y, b.z);
  
  // Draw Slider Bars for Controlling Zoom and Rotation
  cam.drawControls();
  
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
  }
}