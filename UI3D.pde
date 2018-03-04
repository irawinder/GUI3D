/*  Camera3D_Basic, Ira Winder, 2018
 *
 *  This script demonstrates the implementation of a "Camera" class that has ready-made UI, 
 *  Sliders, Radio Buttons, I/O, and smooth camera transitions.
 */
 
// Camera Object with built-in GUI for navigation and selection
//
Camera cam;
PVector B = new PVector(3000, 3000, 0); // Bounding Box for 3D Environment
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
  bar_left.explanation = "";
  bar_left.controlY = BAR_Y + 100;
  bar_left.addSlider("Slider A", "%", 0, 100, 25, 'q', 'w');
  bar_left.addSlider("Slider B", "%", 0, 100, 50, 'a', 's');
  bar_left.addSlider("SPACER",   "%", 0, 100, 50, 'a', 's');
  bar_left.addSlider("Slider C", "%", 0, 100, 75, 'z', 'x');
  bar_left.addSlider("Slider D", "%", 0, 100, 25, 'i', 'o');
  bar_left.addSlider("SPACER",   "%", 0, 100, 50, 'a', 's');
  bar_left.addSlider("Slider E", "%", 0, 100, 50, 'k', 'l');
  bar_left.addSlider("Slider F", "%", 0, 100, 75, ',', '.');
  bar_left.addSlider("SPACER",   "%", 0, 100, 50, 'a', 's');
  bar_left.addTriSlider("TriSlider", "value1", #FF00FF, "value2", #FFFF00, "value3", #00FFFF);
  bar_left.addButton("Item A", true, '1');
  bar_left.addButton("Item B", true, '2');
  bar_left.addButton("Item C", true, '3');
  bar_left.addButton("Item D", true, '4');
  bar_left.addButton("Item W", true, '1');
  bar_left.addButton("Item X", true, '2');
  bar_left.addButton("Item Y", true, '3');
  bar_left.addButton("Item Z", true, '4');
  for (int i=0; i<4; i++) {
    bar_left.buttons.get(i+4).xpos = bar_left.barX + bar_left.barW/2; 
    bar_left.buttons.get(i+4).ypos = bar_left.buttons.get(i).ypos;
  }
  // Delete Spacers
  bar_left.sliders.remove(8);
  bar_left.sliders.remove(5);
  bar_left.sliders.remove(2);
  
  
  // Right Toolbar
  bar_right = new Toolbar(width - (BAR_X + BAR_W), BAR_Y, BAR_W, BAR_H, MARGIN);
  bar_right.title = "Analysis";
  bar_right.credit = "(Right-hand Toolbar)";
  bar_right.explanation = "Framework for explorable 3D model parameterized with sliders, radio buttons, and 3D Cursor.";
  bar_right.explanation += "\n\nAdd outputs, summary data, or ore inputs here.";
  bar_right.explanation += "\n\nPress ' d ' to reset all inputs\nPress ' p ' to print camera settings";
  bar_right.controlY = BAR_Y + 230;
  bar_right.addButton("Button D", true, '5');
  bar_right.addButton("Button E", false,'6');
  bar_right.addButton("Button F", true, '7');
  bar_right.addButton("Button G", true, '8');
  bar_right.addButton("Button H", true, '9');
  bar_right.addSlider("SPACER", "kg", 50, 100, 72, '<', '>');
  bar_right.addSlider("Slider 1", "kg", 50, 100, 72, '<', '>');
  bar_right.addSlider("Slider 2", "kg", 50, 100, 72, '<', '>');
  bar_right.addSlider("Slider 3", "kg", 50, 100, 72, '<', '>');
  bar_right.addSlider("Slider 4", "kg", 50, 100, 72, '<', '>');
  bar_right.addSlider("Slider 5", "kg", 50, 100, 72, '<', '>');
  bar_right.addSlider("Slider 6", "kg", 50, 100, 72, '<', '>');
  bar_right.addSlider("Slider 7", "kg", 50, 100, 72, '<', '>');
  bar_right.addSlider("Slider 8", "kg", 50, 100, 72, '<', '>');
  bar_right.addSlider("Slider 9", "kg", 50, 100, 72, '<', '>');
  bar_right.sliders.remove(0);
  
  // Initialize 3D World Camera Defaults
  cam = new Camera (B, MARGIN);
  // eX, eW (extentsX ...) prevents accidental dragging when interactiong with toolbar
  cam.eX = MARGIN + BAR_W;
  cam.eW = width - 2*(BAR_W + MARGIN);
  cam.ZOOM_DEFAULT = 0.25;
  cam.ZOOM_POW     = 1.75;
  cam.ZOOM_MAX     = 0.10;
  cam.ZOOM_MIN     = 0.75;
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