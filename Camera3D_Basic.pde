Camera cam;
PVector b = new PVector(1000, 1000, 250); //Bounding Box for Environment

// Initiatizes program on startup
void setup() {
  size(1280, 800, P3D);
  cam = new Camera(b);
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
  fill(255, 50);
  box(b.x, b.y, b.z);
  
  cam.drawControls();
}

void mousePressed() {
  cam.pressed();
}

void mouseMoved() {
  cam.moved();
}

void keyPressed() {
  cam.moved();
  
  switch(key) {
    case 'r':
      cam.reset();
      break;
  }
}