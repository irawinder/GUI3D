/*  Camera3D_Basic, Ira Winder, 2018
 *
 *  This script demonstrates the implementation of a "Camera" class that has ready-made UI, 
 *  Sliders, Radio Buttons, I/O, and smooth camera transitions.
 */
 
// Camera Object with built-in GUI for navigation and selection
//
Camera cam;
PVector B = new PVector(6000, 6000, 0); // Bounding Box for 3D Environment
int MARGIN = 25; // Pixel margin allowed around edge of screen

// Semi-transparent Toolbar for information and sliders
//
Toolbar bar_left, bar_right; 
int BAR_X, BAR_Y, BAR_W, BAR_H;

PVector objectLocation; // Location of an Object a user can move with arrow keys
ArrayList<PVector> additions; // Locations of objects user can place with mouse

// Initiatizes program on startup
//
void setup() {
  size(1280, 800, P3D);
  //fullScreen(P3D);
  
  // Initialize Toolbar
  BAR_X = MARGIN;
  BAR_Y = MARGIN;
  BAR_W = 250;
  BAR_H = height - 2*MARGIN;
  
  // Left Toolbar
  bar_left = new Toolbar(BAR_X, BAR_Y, BAR_W, BAR_H, MARGIN);
  bar_left.title = "UI3D Visualization Template";
  bar_left.credit = "(Left-hand Toolbar)";
  bar_left.explanation = "Use these scripts as the framework for an explorable 3D model parameterized with sliders, radio buttons, and 3d Object Placement.";
  bar_left.explanation += "\n\nPress ' d ' to reset all inputs\nPress ' p ' to print camera to cons.";
  
  // Right Toolbar
  bar_right = new Toolbar(width - (BAR_X + BAR_W), BAR_Y, BAR_W, BAR_H, MARGIN);
  bar_right.title = "Analysis";
  bar_right.credit = "(Right-hand Toolbar)";
  bar_right.explanation = "Add outputs and summary data here.";
  
  // Initialize 3D World Camera Defaults
  cam = new Camera (B, MARGIN);
  // eX, eW (extentsX ...) prevents accidental dragging when interactiong with toolbar
  cam.eX = MARGIN + BAR_W;
  cam.eW = width - 2*(BAR_W + MARGIN);
  cam.ZOOM_DEFAULT = 0.3;
  cam.ZOOM_POW = 1.75;
  cam.ZOOM_MAX = 0.1;
  cam.ROTATION_DEFAULT = PI; // (0 - 2*PI)
  cam.init(); //Must End with init() if any variables within Camera() are changed from default
  
  // Sample 3D objects to manipulate
  objectLocation = new PVector(B.x/2, B.y/2, 0);
  additions = new ArrayList<PVector>();
}

// Runs once every frame of application
//
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
  
  // Field: Draw Rectangular plane comprising boundary area 
  fill(255, 50);
  rect(0, 0, B.x, B.y);
  
  // Field: Draw Selection Field
  pushMatrix(); translate(0, 0, 1);
  image(cam.chunkField.img, 0, 0, B.x, B.y);
  popMatrix();
  
  // Arrow-Object: Draw Object to edit with arrow keys
  pushMatrix(); translate(objectLocation.x, objectLocation.y, objectLocation.z + 30/2.0);
  fill(255, 150); noStroke(); strokeWeight(1);
  box(30, 30, 30);
  popMatrix();
  
  // Arrow-Object: Calculate Object's Screen Location
  float s_x = screenX(objectLocation.x, objectLocation.y, objectLocation.z + 30/2.0);
  float s_y = screenY(objectLocation.x, objectLocation.y, objectLocation.z + 30/2.0);
  
  // Click-Object: Draw mouse-based object additions
  if (additions.size() > 0) {
    for (PVector v: additions) {
      pushMatrix(); translate(v.x, v.y, v.z + 15/2.0);
      fill(#00FF00, 200); noStroke();
      box(15, 15, 15);
      popMatrix();
    }
  }
  
  // Click-Object: Draw Selection Cursor
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
  
  
  
  // -------------------------
  // Begin Drawing 2D Elements
  hint(DISABLE_DEPTH_TEST);
  camera(); noLights(); perspective(); 
  
  // Arrow-Object: Draw Cursor Text
  noFill(); stroke(#FFFF00, 200);
  float diam = min(100, 5/pow(cam.zoom, 2));
  ellipse(s_x, s_y, diam, diam);
  fill(#FFFF00, 200); textAlign(LEFT, CENTER);
  text("OBJECT: Move with Arrow Keys", s_x + 0.6*diam, s_y);
  
  // Click-Object: Draw Cursor Text
  if (cam.chunkField.closestFound) {
    fill(#00FF00, 200); textAlign(LEFT, CENTER);
    text("Click to Place", cursorX + 0.3*diam, cursorY);
  }
  
  hint(ENABLE_DEPTH_TEST);
  
  
  // Draw Slider Bars for Controlling Zoom and Rotation (2D canvas begins)
  cam.drawControls();
  
  // Draw Margin Toolbar
  bar_left.draw();
  bar_right.draw();
}

void mousePressed() {
  cam.pressed();
  bar_left.pressed();
  bar_right.pressed();
}

void mouseClicked() {
  if (cam.chunkField.closestFound) {
    additions.add(cam.chunkField.closest.location);
  }
}

void mouseReleased() {
  bar_left.released();
  bar_right.released();
  cam.moved();
}

void mouseMoved() {
  cam.moved();
}

void keyPressed() {
  cam.moved();
  bar_left.pressed();
  bar_right.pressed();
  
  switch(key) {
    case 'f':
      cam.showFrameRate = !cam.showFrameRate;
      break;
    case 'r':
      cam.reset();
      break;
    case 'd':
      additions.clear();
      bar_left.restoreDefault();
      bar_right.restoreDefault();
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