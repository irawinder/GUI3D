// Scrollbars (horizontal and vertical
HScrollbar hs;
VScrollbar vs;

// Drag Functions
XYDrag drag;

PVector boundary = new PVector(1000, 1000, 50);
// Fraction of screen height to use as margin
float MARGIN = 0.03;
// Default color for lines, text, etc
int lnColor = 255;  // (0-255)
// Default background color
int bgColor = 20;    // (0-255)
// Default baseline alpha value
int baseAlpha = 50; // (0-255)

// Initiatizes program on startup
void setup() {

  // Run application at a specified pixel dimension
  size(1280, 800, P3D);
  
  // Initialize the Camera
  initCamera();
  
  // Initialize Horizontal Scrollbar
  hs = new HScrollbar(width - int(height*MARGIN) - int(0.3*height), int((1-1.5*MARGIN)*height), int(0.3*height), int(MARGIN*height), 5);
  camRotation = hs.getPosPI(); // (0 - 2*PI)
  
  // Initialize Vertical Scrollbar
  vs = new VScrollbar(width - int(1.5*MARGIN*height), int(MARGIN*height), int(MARGIN*height), int(0.3*height), 5);
  
  // Initialize Drag Funciton
  drag = new XYDrag(1.0, 7, 5, 5, width - 10, int(0.85*height) - 5);
  
  resetControls();
  
}

void draw() {
  background(bgColor);
  
  // Update mouse and keyboard inputs
  updateInputs();
  
  // Draw 3D Graphics
  draw3D();
  
  // Draw 2D Graphics
  draw2D();
}

void draw2D() {
  camera();
  noLights();
  perspective();
  hint(DISABLE_DEPTH_TEST);
  
  // Draw Scroll Bars
  hs.display();
  vs.display();
  
  // Draw Help Text
  pushMatrix();
  translate(width/2, MARGIN*height);
  fill(lnColor, 255-baseAlpha);
  textAlign(CENTER, TOP);
  text("Press 'r' to reset camera position", 0, 0);
  translate(0, height - 2*MARGIN*height);
  textAlign(CENTER, BOTTOM);
  fill(lnColor, 2*baseAlpha);
  text("Copyright 2018 Ira Winder", 0, 0);
  popMatrix();
  
  hint(ENABLE_DEPTH_TEST);
}

void draw3D() {
  setCamera(boundary);
  
  pushMatrix();
  
  // Rotate Reference Frame
  translate(0.5*boundary.x, 0.5*boundary.y, 0.5*boundary.z);
  rotate(camRotation);
  translate(-0.5*boundary.x, -0.5*boundary.y, -0.5*boundary.z);
  
  // Translate Reference Frame
  translate(camOffset.x, camOffset.y, 0);
  
  // Draw Ground
    pushMatrix();
    translate(0, 0, -1);
    rect(0, 0, boundary.x, boundary.y);
    popMatrix();
  
  
  popMatrix();
}