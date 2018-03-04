/*  Camera3D_Basic, Ira Winder, 2018
 *
 *  This script demonstrates the implementation of a "Camera" class that has ready-made UI, Sliders, Radio Buttons, I/O, and smooth camera transitions.
 */
 
Camera cam;
PVector B = new PVector(6000, 6000, 0); //Bounding Box for 3D Environment
int MARGIN = 25;

Toolbar bar;
int BAR_WIDTH = 250;

PVector objectLocation;
ArrayList<PVector> additions;

// Initiatizes program on startup
void setup() {
  size(1280, 800, P3D);
  //fullScreen(P3D);
  
  // Initialize 3D World Camera Defaults
  cam = new Camera (B, MARGIN);
  // eX, eW prevents accidental dragging when interactiong with toolbar
  cam.eX = MARGIN + BAR_WIDTH;
  cam.eW = width - BAR_WIDTH;
  cam.ZOOM_DEFAULT = 0.3;
  cam.ZOOM_POW = 1.75;
  cam.ZOOM_MAX = 0.1;
  cam.ROTATION_DEFAULT = PI; // (0 - 2*PI)
  cam.init(); //Must End with init() if any variables within Camera() are changed from default
    
  // Initialize Toolbar
  bar = new Toolbar(BAR_WIDTH, cam.margin);
  bar.title = "UI3D Visualization Template";
  bar.credit = "Ira Winder, 2018";
  bar.explanation = "Use these scripts as the framework for an explorable 3D model parameterized with sliders, radio buttons, and 3d Object Placement.";
  bar.explanation += "\n\nPress ' d ' to reset all inputs\nPress ' p ' to print camera to cons.";
  // Sample 3D objects to manipulate
  objectLocation = new PVector(B.x/2, B.y/2, 0);
  additions = new ArrayList<PVector>();
}

void draw() {
  background(0);
  
  // Update camera position settings for a number of frames after key updates
  if (cam.moveTimer > 0) {
    cam.moved();
  }
  
  // Draw and Calculate 3D Graphics 
  cam.orient();
  
  // ****
  // NOTE: Objects draw earlier in the loop will obstruct 
  // objects drawn afterward (despite alpha value!)
  // ****
  
  
  
  // -------------------------
  // Begin Drawing 3D Elements
  
  // Draw Rectangular plane comprising boundary area 
  fill(255, 50);
  rect(0, 0, B.x, B.y);
  
  // Draw Selection Field
  pushMatrix(); translate(0, 0, 1);
  image(cam.chunkField.img, 0, 0, B.x, B.y);
  popMatrix();
  
  // Draw Object to edit with arrow keys
  pushMatrix(); translate(objectLocation.x, objectLocation.y, objectLocation.z + 30/2.0);
  fill(255, 150); noStroke(); strokeWeight(1);
  box(30, 30, 30);
  popMatrix();
  
  // Draw mouse-based object additions
  if (additions.size() > 0) {
    for (PVector v: additions) {
      pushMatrix(); translate(v.x, v.y, v.z + 15/2.0);
      fill(#00FF00, 200); noStroke();
      box(15, 15, 15);
      popMatrix();
    }
  }
  
  // Draw Selection Cursor
  float cursorX = 0;
  float cursorY = 0;
  //cam.chunkField.drawCursor();
  
  if (cam.chunkField.closestFound) {
    Chunk c = cam.chunkField.closest;
    PVector loc = c.location;
    
    // Place Ghost of Object to Place
    pushMatrix(); translate(loc.x, loc.y, loc.z + 15/2.0);
    fill(#00FF00, 100); noStroke();
    box(15, 15, 15);
    popMatrix();
    
    // Calculate Curson Screen Location
    cursorX = screenX(loc.x, loc.y, loc.z + 30/2.0);
    cursorY = screenY(loc.x, loc.y, loc.z + 30/2.0);
  }
  
  // Calculate Object Screen Location
  float s_x = screenX(objectLocation.x, objectLocation.y, objectLocation.z + 30/2.0);
  float s_y = screenY(objectLocation.x, objectLocation.y, objectLocation.z + 30/2.0);
  
  
  
  // -------------------------
  // Begin Drawing 2D Elements
  camera(); noLights(); perspective(); 
  hint(DISABLE_DEPTH_TEST);
  
  // Draw Cursors
  noFill(); stroke(#FFFF00, 200);
  float diam = min(100, 5/pow(cam.zoom, 2));
  ellipse(s_x, s_y, diam, diam);
  fill(#FFFF00, 200); textAlign(LEFT, CENTER);
  text("OBJECT: Move with Arrow Keys", s_x + 0.6*diam, s_y);
  if (cam.chunkField.closestFound) {
    fill(#00FF00, 200); textAlign(LEFT, CENTER);
    text("Click to Place", cursorX + 0.3*diam, cursorY);
  }
  hint(ENABLE_DEPTH_TEST);
  
  // Draw Slider Bars for Controlling Zoom and Rotation (2D canvas begins)
  cam.drawControls();
  
  // Draw Margin Toolbar
  bar.draw();
}

void mousePressed() {
  cam.pressed();
  bar.pressed();
}

void mouseClicked() {
  if (cam.chunkField.closestFound) {
    additions.add(cam.chunkField.closest.location);
  }
}

void mouseReleased() {
  bar.released();
  cam.moved();
}

void mouseMoved() {
  cam.moved();
}

void keyPressed() {
  cam.moved();
  bar.pressed();
  
  switch(key) {
    case 'f':
      cam.showFrameRate = !cam.showFrameRate;
      break;
    case 'r':
      cam.reset();
      break;
    case 'd':
      additions.clear();
      bar.restoreDefault();
      break;
    case 'p':
      println("cam.offset.x = " + cam.offset.x);
      println("cam.offset.x = " + cam.offset.x);
      println("cam.zoom = "     + cam.zoom);
      println("cam.rotation = " + cam.rotation);
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