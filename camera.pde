/*  Camera3D_Basic, Ira Winder, 2018
 *
 *  This script demonstrates the implementation of a "Camera" class that has ready-made UI and smooth camera transitions.
 */
 
class Camera {
  
  // Camera Geometry:
  //
  PVector boundary;
  float rotation;
  float MAX_ZOOM;
  float MIN_ZOOM;
  float X_DEFAULT;
  float Y_DEFAULT;
  float zoom;
  PVector offset;
  
  // UI: Scrollbars (horizontal and vertical)
  //
  HScrollbar hs;
  VScrollbar vs;

  // UI: Mouse Drag Information
  //
  XYDrag drag;
  
  // UI: Chunks used for selecting area in 3D
  //
  ChunkGrid cField;
  
  // UI: Active UI Input
  // Input -1 = none
  // Input  0 = drag
  // Input  1 = horizontal scroll bar
  // Input  2 = vertical scroll bar
  //
  int activeInput = -1;
  
  // UI: Superficial Parameters for drawing slider bars and text
  //
  int MARGIN   = 25;   // Pixels to use as buffer margin
  int LINE_COLOR = 255;  // (0-255) Default color for lines, text, etc
  int BASE_ALPHA = 50;   // (0-255) Default baseline alpha value
  
  // UI: Transparency fades over time
  //
  int FADE_TIMER = 300;
  int fadeTimer = 300;
  float uiFade = 1.0;  // 0.0 - 1.0
  
  // UI: Chunks used for selecting area in 3D
  //
  int CHUNK_RESOLUTION = 30; // number of horizontal chunk units
  int TOLERANCE = 15; // number of pixels within range to select
  
  // UI: Show Frame Rate
  //
  boolean showFrameRate = false;
  
  Camera(int toolbarWidth, PVector boundary) {
    this.boundary = boundary;
    
    // Initialize the Camera
    rotation = 0; // (0 - 2*PI)
    MAX_ZOOM = 0.1;
    MIN_ZOOM = 1.0;
    X_DEFAULT = 0;
    //Y_DEFAULT = 0;
    Y_DEFAULT = - 0.12 * boundary.y;
    zoom = 0.1;
    offset = new PVector(X_DEFAULT, Y_DEFAULT);
    int thirdPix  = int(0.3*height);
    
    // Initialize Horizontal Scrollbar
    hs = new HScrollbar(width - MARGIN - thirdPix, height - 1.5*MARGIN, thirdPix, MARGIN, 5);
    rotation = hs.getPosPI(); // (0 - 2*PI)
    
    // Initialize Vertical Scrollbar
    vs = new VScrollbar(width - int(1.5*MARGIN), MARGIN, MARGIN, thirdPix, 5);
    
    // Initialize Drag Funciton
    drag = new XYDrag(1.0, 7, MARGIN + toolbarWidth, MARGIN, width - 2*MARGIN + toolbarWidth, height - 2*MARGIN);
    
    // Initialize Selection Chunks
    cField = new ChunkGrid(CHUNK_RESOLUTION, TOLERANCE, MARGIN + toolbarWidth, MARGIN, width - 2*MARGIN + toolbarWidth, height - 2*MARGIN);
    
    reset();
  }
  
  // Set Camera Position based upon current parameters
  //
  void orient() {
    float eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ;
    
    // Camera Position
    eyeX = boundary.x * 0.5;
    //eyeY = (zoom/MIN_ZOOM - 0.5) * boundary.y;
    eyeY = 0.50 * boundary.y - zoom * 0.50 * boundary.y;
    eyeZ = boundary.z + pow(zoom, 4) * 2 * max(boundary.x, boundary.y);
    
    // Point of Camera Focus
    centerX = 0.50 * boundary.x;
    centerY = 0.50 * boundary.y;
    //centerZ = -1.0 * boundary.z;
    centerZ = boundary.z;
    
    // Axes Directionality (Do not change)
    upX =   0;
    upY =   0;
    upZ =  -1;
    
    camera(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ);
    lights(); // Default Lighting Condition
    
    // Rotate Reference Frame
    translate(0.5*boundary.x, 0.5*boundary.y, 0.5*boundary.z);
    rotate(rotation);
    translate(-0.5*boundary.x, -0.5*boundary.y, -0.5*boundary.z);
  
    // Translate Reference Frame
    translate(offset.x, offset.y, 0);
    
    update();
  }
  
  // resets and centers camera view
  //
  void reset() {
    hs.newspos = hs.xpos + hs.swidth/2 - hs.sheight/2;
    vs.newspos = vs.sposMin + 0.1*vs.sheight;
    drag.x_offset = 0;
    drag.y_offset = 0;
    drag.camX_init = X_DEFAULT;
    drag.camY_init = Y_DEFAULT;
    moved();
  }
  
  void moved() {
    uiFade = 1.0;
    fadeTimer = FADE_TIMER;
    orient();
    cField.checkChunks(mouseX, mouseY);
  }
  
  void pressed() {
    // Determine which output is active
    if (cam.hs.overEvent()) {
      activeInput = 1;
    } else if (cam.vs.overEvent()) {
      activeInput = 2;
    } else if (cam.drag.inExtents()) {
      activeInput = 0;
      drag.init();
    } else {
      activeInput = -1;
    }
  }
  
  class HScrollbar {
    float swidth, sheight;  // width and height of bar
    float xpos, ypos;       // x and y position of bar
    float spos, newspos;    // x position of slider
    float sposMin, sposMax; // max and min values of slider
    int loose;              // how loose/heavy
    boolean over;           // is the mouse over the slider?
    boolean locked;
    float ratio;
  
    HScrollbar (float xp, float yp, float sw, float sh, int l) {
      swidth = sw;
      sheight = sh;
      float widthtoheight = sw - sh;
      ratio = sw / widthtoheight;
      xpos = xp;
      ypos = yp-sheight/2;
      spos = xpos + swidth/2 - sheight/2;
      newspos = spos;
      sposMin = xpos;
      sposMax = xpos + swidth - sheight;
      loose = l;
    }
  
    void update() {
      if (overEvent()) {
        over = true;
      } else {
        over = false;
      }
      if (mousePressed && over) {
        locked = true;
      }
      if (!mousePressed) {
        locked = false;
      }
      if (locked) {
        newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
      }
      if (abs(newspos - spos) > 0.001) {
        spos = spos + (newspos-spos)/loose;
      }
    }
  
    float constrain(float val, float minv, float maxv) {
      return min(max(val, minv), maxv);
    }
  
    boolean overEvent() {
      if (mouseX > xpos && mouseX < xpos+swidth &&
         mouseY > ypos && mouseY < ypos+sheight) {
        return true;
      } else {
        return false;
      }
    }
  
    void display() {
      noStroke();
      fill(0.6*LINE_COLOR, BASE_ALPHA);
      rect(xpos, ypos, swidth, sheight, sheight);
      if (over || locked) {
        fill(LINE_COLOR, BASE_ALPHA);
      } else {
        fill(0.4*LINE_COLOR, BASE_ALPHA);
      }
      ellipse(spos + sheight/2, ypos + sheight/2, sheight, sheight);
      fill(LINE_COLOR, 255);
      textAlign(CENTER, BOTTOM);
      text("ROTATION", xpos + swidth/2, ypos - 14);
    }
  
    float getPos() {
      // Convert spos to be values between
      // 0 and the total width of the scrollbar
      return spos * ratio;
    }
    
    float getPosPI() {
      // Convert spos to be values between
      // 0 and 2PI
      return 2 * PI * (spos-sposMin) / (swidth-sheight);
    }
  }
  
  class VScrollbar {
    float swidth, sheight;    // width and height of bar
    float xpos, ypos;       // x and y position of bar
    float spos, newspos;    // y position of slider
    float sposMin, sposMax; // max and min values of slider
    int loose;              // how loose/heavy
    boolean over;           // is the mouse over the slider?
    boolean locked;
    float ratio;
  
    VScrollbar (float xp, float yp, float sw, float sh, int l) {
      swidth = sw;
      sheight = sh;
      float heighttowidth = sw - sh;
      ratio = sh / heighttowidth;
      xpos = xp-swidth/2;
      ypos = yp;
      spos = sheight/2;
      newspos = spos;
      sposMin = ypos;
      sposMax = ypos + sheight - swidth;
      loose = l;
    }
  
    void update() {
      if (overEvent()) {
        over = true;
      } else {
        over = false;
      }
      if (mousePressed && over) {
        locked = true;
      }
      if (!mousePressed) {
        locked = false;
      }
      if (locked) {
        newspos = constrain(mouseY-swidth/2, sposMin, sposMax);
      }
      if (abs(newspos - spos) > 0.001) {
        spos = spos + (newspos-spos)/loose;
      }
    }
  
    float constrain(float val, float minv, float maxv) {
      return min(max(val, minv), maxv);
    }
  
    boolean overEvent() {
      if (mouseX > xpos && mouseX < xpos+swidth &&
         mouseY > ypos && mouseY < ypos+sheight) {
        return true;
      } else {
        return false;
      }
    }
  
    void display() {
      noStroke();
      fill(0.6*LINE_COLOR, 2*BASE_ALPHA);
      rect(xpos, ypos, swidth, sheight, swidth);
      if (over || locked) {
        fill(LINE_COLOR, 2*BASE_ALPHA);
      } else {
        fill(0.4*LINE_COLOR, 4*BASE_ALPHA);
      }
      ellipse(xpos + swidth/2, spos + swidth/2, swidth, swidth);
      fill(LINE_COLOR, 255);
      textAlign(CENTER, TOP);
      text("ZOOM", xpos + swidth/2, ypos + sheight + 21);
    }
  
    float getPos() {
      // Convert spos to be values between
      // 0 and the total width of the scrollbar
      return spos * ratio;
    }
    
    float getPosZoom() {
      // Convert spos to be values between
      // 0 and 2PI
      return MIN_ZOOM + (MAX_ZOOM - MIN_ZOOM) * spos / sheight;
    }
  }
  
  // Helper Class For Enhanced, Smoothed Mouse UI
  class XYDrag {
    float scaler;
    float loose;
    
    float x_init;
    float y_init;
    float x_offset;
    float y_offset;
    float x_smooth;
    float y_smooth;
    
    float x, y;
    
    float camX_init;
    float camY_init;
    
    // Extent of Clickability
    int extentX;
    int extentY;
    int extentW;
    int extentH;
    
    XYDrag(float s, float l, int eX, int eY, int eW, int eH ) {
      scaler = s;
      loose = l;
      
      extentX = eX;
      extentY = eY;
      extentW = eW;
      extentH = eH;
    }
    
    boolean inExtents() {
      if (mouseX > extentX && mouseX < extentX+extentW && mouseY > extentY && mouseY < extentY+extentH) {
        return true; 
      } else {
        return false;
      }
    }
    
    void init() {
      x_init = mouseX;
      y_init = mouseY;
      camX_init = offset.x;
      camY_init = offset.y;
      x_smooth = 0;
      y_smooth = 0;
    }
    
    void update() {
      if (mousePressed) {
        x_offset = - (mouseX - x_init);
        y_offset = - (mouseY - y_init);
      }
      if (abs(x_smooth - x_offset) > 1) {
        x_smooth = x_smooth + (x_offset-x_smooth)/loose;
      }
      if (abs(y_smooth - y_offset) > 1) {
        y_smooth = y_smooth + (y_offset-y_smooth)/loose;
      }
      x = scaler*x_smooth;
      y = scaler*y_smooth;
    }
    
    boolean updating() {
      if (abs(x_smooth - x_offset) > 1 || abs(y_smooth - y_offset) > 1) {
        return true;
      } else {
        return false;
      }
    }
    
    // Coordinate Rotation Transformation:
    // x' =   x*cos(theta) + y*sin(theta)
    // y' = - x*sin(theta) + y*cos(theta)
    
    float getX() {
      return camX_init + x*cos(rotation) + y*sin(rotation);
    }
    
    float getY() {
      return camY_init - x*sin(rotation) + y*cos(rotation);
    }
  }
  
  void update() {
    // Fade input controls when not in use
    if (mousePressed) {
      uiFade = 1.0;
      fadeTimer = FADE_TIMER;
    } else {
      if (fadeTimer > 0) {
        fadeTimer--;
      } else {
        if (uiFade > 0.1) {
          uiFade *= 0.99;
        } else {
          uiFade = 0;
        }
      }
    }
    // Update All Scroll, Drag, and Chunk Inputs
    if (!mousePressed) {
      if (drag.updating()) {
        drag.update();
        offset.x = drag.getX();
        offset.y = drag.getY();
      }
      hs.update();
      rotation = hs.getPosPI();
      vs.update();
      zoom = vs.getPosZoom();
      
    // Update Drag Only
    } else if (activeInput == 0) {
      drag.update();
      offset.x = drag.getX();
      offset.y = drag.getY();
      
    // Update Horizontal Scroll Bar Only
    } else if (activeInput == 1) {
      hs.update();
      rotation = hs.getPosPI();
      
    // Update Vertical Scroll Bar Only
    } else if (activeInput == 2) {
      vs.update();
      zoom = vs.getPosZoom();
    }
  }
  
  // Object that defines an area that is sensitive to user-based mouse selection
  //
  class Chunk {
    PVector location; // location of chunk
    float size; // cube size of chunk
    float s_x, s_y; // screen location of chunk
    boolean hover;
    
    Chunk(PVector location, float size) {
      this.location = location;
      this.size = size;
      hover = false;
    }
    
    void setScreen() {
      s_x = screenX(location.x, location.y, location.z);
      s_y = screenY(location.x, location.y, location.z);
    }
    
    void draw() {
      noFill();
      if (hover) {
        stroke(#FFFF00, 255);
        strokeWeight(2);
        pushMatrix();
        translate(location.x, location.y, location.z + size/2);
        box(size, size, size);
        popMatrix();
      } else {
        stroke(100, 100);
        strokeWeight(1);
        rect(location.x-size/2, location.y-size/2, size, size);
      }
      
    }
  }
  
  // Grid of Chunks
  //
  class ChunkGrid {
    int resolution, tolerance;
    ArrayList<Chunk> selectionGrid;
    Chunk closest;
    boolean closestFound;
    
    // Extent of Clickability
    int extentX;
    int extentY;
    int extentW;
    int extentH;
    
    ChunkGrid(int resolution, int tolerance, int eX, int eY, int eW, int eH) {
      this.resolution = resolution;
      this.tolerance = tolerance;
      
      Chunk chunk; PVector chunkLocation;
      selectionGrid = new ArrayList<Chunk>();
      float chunkU  = boundary.x / resolution;
      float chunkV  = boundary.y / resolution;
      for(int u=0; u<chunkU; u++) {
        for(int v=0; v<chunkV; v++) {
          chunkLocation = new PVector(u*resolution, v*resolution);
          chunk = new Chunk(chunkLocation, resolution);
          selectionGrid.add(chunk);
        }
      }
      closestFound = false;
      
      extentX = eX;
      extentY = eY;
      extentW = eW;
      extentH = eH;
    }
    
    // Returns the location of chunk closest to user's mouse position
    //
    void checkChunks(int mouseX, int mouseY) {
      closestFound = false;
      
      // Updates Screenlocation for all chunks
      for (Chunk chunk: selectionGrid) chunk.setScreen();
      
      // Discovers closest chunk to mouse
      PVector mouse = new PVector(mouseX, mouseY);
      Chunk c; PVector c_location; int c_index = -1;
      float dist = Float.POSITIVE_INFINITY;
      for (int i=0; i<selectionGrid.size(); i++) {
        c = selectionGrid.get(i);
        c.hover = false;
        c_location = new PVector(c.s_x, c.s_y);
        if (mouse.dist(c_location) < dist && mouse.dist(c_location) < TOLERANCE) {
          dist = mouse.dist(c_location);
          c_index = i;
        }
      }
      
      // Retrieve and store closest chunk found
      if (mouseX > extentX && mouseX < extentX+extentW && mouseY > extentY && mouseY < extentY+extentH) {
        
        if (c_index >= 0) {
          closestFound = true;
          closest = selectionGrid.get(c_index);
          closest.hover = true;
        }
      }
    }
    
    void draw() {
      for (Chunk c: selectionGrid) c.draw();
    }
  }
  
  // Renders the UI on a 2D canvas that writes over any 3D image
  //
  void drawControls() {
    camera();
    noLights();
    perspective();
    hint(DISABLE_DEPTH_TEST);
    
    // Draw Scroll Bars
    hs.display();
    vs.display();
    
    // Draw Help Text
    pushMatrix();
    translate(width/2, MARGIN);
    fill(LINE_COLOR, 255-BASE_ALPHA);
    textAlign(CENTER, TOP);
    text("Press 'r' to reset camera position", 0, 0);
    if (showFrameRate) text("(F)ramerate: " + int(frameRate*10)/10.0, 0, 16);
    translate(0, height - 2*MARGIN);
    textAlign(CENTER, BOTTOM);
    fill(LINE_COLOR, 2*BASE_ALPHA);
    text("Copyright 2018 Ira Winder", 0, 0);
    popMatrix();
    
    hint(ENABLE_DEPTH_TEST);
  }
}