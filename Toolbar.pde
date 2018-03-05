/*  TOOLBAR ALGORITHMS
 *  Ira Winder, ira@mit.edu, 2018
 *
 *  This class and associated sliders, radio buttons, and specialized 
 *  input are generalizable for parameterized models
 *  
 *  CLASSES CONTAINED:
 *
 *    Toolbar() - Toolbar that may implement ControlSlider(), Radio Button(), and TriSlider()
 *    -  ControlSlider() - A customizable horizontal slider ideal for generic parameritization of integers
 *    -  RadioButton()   - A customizable radio button ideal for generic parameritization of boolean
 *    -  TriSlider()     - A customizable triable slider that outputs three positive floats that add up to 1.0
 *
 *  MIT LICENSE:  Copyright 2018 Ira Winder
 *
 *               Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
 *               and associated documentation files (the "Software"), to deal in the Software without restriction, 
 *               including without limitation the rights to use, copy, modify, merge, publish, distribute, 
 *               sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
 *               furnished to do so, subject to the following conditions:
 *
 *               The above copyright notice and this permission notice shall be included in all copies or 
 *               substantial portions of the Software.
 *
 *               THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
 *               NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
 *               NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
 *               DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
 *               OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
  
class Toolbar {
  int barX, barY, barW, barH; // X, Y, Width, and Height of Toolbar on Screen
  int contentW, contentH;     // pixel width and height of toolbar content accounting for margin
  int margin;                 // standard internal pixel buffer distance from edge of canvas
  int CONTROL_H = 35;          // standard vertical pixel distance between control elements
  int controlY;          // vertical position where controls begin
  
  String title, credit, explanation;
  ArrayList<ControlSlider> sliders;
  ArrayList<RadioButton> buttons;
  ArrayList<TriSlider> tSliders;
  
  Toolbar(int barX, int barY, int barW, int barH, int margin) {
    this.barX = barX;
    this.barY = barY;
    this.barW = barW;
    this.barH = barH;
    this.margin = margin;
    contentW = barW - 2*margin;
    contentH = barH - 2*margin;
    sliders  = new ArrayList<ControlSlider>();
    buttons  = new ArrayList<RadioButton>();
    tSliders = new ArrayList<TriSlider>();
    controlY = 8*CONTROL_H;
  }
  
  void addSlider(String name, String unit, int valMin, int valMax, float DEFAULT_VALUE, char keyMinus, char keyPlus) {
    float num = sliders.size() + buttons.size() + 6*tSliders.size();
    ControlSlider s;
    s = new ControlSlider();
    s.name = name;
    s.unit = unit;
    s.keyPlus = keyPlus;
    s.keyMinus = keyMinus;
    s.xpos = barX + margin;
    s.ypos = controlY + int(num*CONTROL_H);
    s.len = contentW - margin;
    s.valMin = valMin;
    s.valMax = valMax;
    s.DEFAULT_VALUE = DEFAULT_VALUE;
    s.value = s.DEFAULT_VALUE;
    sliders.add(s);
  }
  
  void addButton(String name, int col, boolean DEFAULT_VALUE, char keyToggle) {
    float num = sliders.size() + buttons.size() + 6*tSliders.size();
    RadioButton b;
    b = new RadioButton();
    b.name = name;
    b.keyToggle = keyToggle;
    b.xpos = barX + margin;
    b.ypos = controlY + int(num*CONTROL_H);
    b.DEFAULT_VALUE = DEFAULT_VALUE;
    b.value = b.DEFAULT_VALUE;
    b.col = col;
    buttons.add(b);
  }
  
  void addTriSlider(String name, String name1, int col1, String name2, int col2, String name3, int col3) {
    float num = sliders.size() + buttons.size() + 6*tSliders.size();
    TriSlider t;
    t = new TriSlider();
    t.name = name;
    t.name1 = name1;
    t.col1 = col1;
    t.name2 = name2;
    t.col2 = col2;
    t.name3 = name3;
    t.col3 = col3;
    t.xpos = barX + margin;
    t.ypos = controlY + int(num*CONTROL_H);
    t.corner1.x = barX + 0.50*barW;
    t.corner1.y = controlY + (num+0.70)*CONTROL_H;
    t.corner2.x = barX + 0.33*barW;
    t.corner2.y = controlY + (num+2.90)*CONTROL_H;
    t.corner3.x = barX + 0.67*barW;
    t.corner3.y = controlY + (num+2.90)*CONTROL_H;
    t.avgX = (t.corner1.x+t.corner2.x+t.corner3.x)/3.0;
    t.avgY = (t.corner1.y+t.corner2.y+t.corner3.y)/3.0;
    t.avg = new PVector(t.avgX, t.avgY);
    t.r = t.avg.dist(t.corner1);
    t.pt = new PVector(t.avgX, t.avgY);
    t.calculateValues();
    tSliders.add(t);
  }
  
  void pressed() {
    if (sliders.size()  > 0) for (ControlSlider s: sliders ) s.listen();
    if (buttons.size()  > 0) for (RadioButton   b: buttons ) b.listen();
    if (tSliders.size() > 0) for (TriSlider     t: tSliders) t.listen();
  }
  
  void released() {
    if (sliders.size()  > 0) for (ControlSlider s: sliders ) s.isDragged = false;
    if (tSliders.size() > 0) for (TriSlider     t: tSliders) t.isDragged = false;
  }
  
  void restoreDefault() {
    if (sliders.size()  > 0) for (ControlSlider s: sliders ) s.value = s.DEFAULT_VALUE;
    if (buttons.size()  > 0) for (RadioButton   b: buttons ) b.value = b.DEFAULT_VALUE;
    if (tSliders.size() > 0) for (TriSlider     t: tSliders) t.pt    = new PVector(t.avgX, t.avgY);
  }
  
  // Draw Margin Elements
  //
  void draw() {
    camera();
    noLights();
    perspective();
    hint(DISABLE_DEPTH_TEST);
    
    pushMatrix();
    translate(barX, barY);
    
    // Shadow
    pushMatrix(); translate(3, 3);
    noStroke();
    fill(0, 100);
    rect(0, 0, barW, barH, margin);
    popMatrix();
    
    // Canvas
    fill(255, 20);
    noStroke();
    rect(0, 0, barW, barH, margin);
    
    // Canvas Content
    translate(margin, margin);
    textAlign(LEFT, TOP);
    fill(255);
    text(title + "\n" + credit + "\n\n" + explanation, 0, 0, contentW, contentH);
    popMatrix();
    
    // Sliders
    for (ControlSlider s: sliders) {
      s.update();
      s.drawMe();
    }
    
    // Buttons
    for (RadioButton b: buttons) {
      b.drawMe();
    }
    
    // TriSliders
    for (TriSlider t: tSliders) {
      t.update();
      t.drawMe();
    }
    
    hint(ENABLE_DEPTH_TEST);
  }
  
  boolean hover() {
    if (mouseX > barX && mouseX < barX + barW && 
        mouseY > barY && mouseY < barY + barH) {
      return true;
    } else {
      return false;
    }
  }
}

class ControlSlider {
  String name;
  String unit;
  int xpos;
  int ypos;
  int len;
  int diameter;
  char keyMinus;
  char keyPlus;
  boolean isDragged;
  int valMin;
  int valMax;
  float value;
  float DEFAULT_VALUE = 0;
  
  ControlSlider() {
    xpos = 0;
    ypos = 0;
    len = 200;
    diameter = 15;
    keyMinus = '-';
    keyPlus = '+';
    isDragged = false;
    valMin = 0;
    valMax = 0;
    value = 0;
  }
  
  void update() {
    if (isDragged) value = (mouseX-xpos)*(valMax-valMin)/len+valMin;
    checkLimit();
  }
  
  void listen() {
    if(mousePressed && (mouseY > (ypos-diameter/2)) && (mouseY < (ypos+diameter/2)) && (mouseX > (xpos-diameter/2)) && (mouseX < (xpos+len+diameter/2))) {
      isDragged = true;
    }
    
    //Keyboard Controls
    if ((keyPressed == true) && (key == keyMinus)) {value--;}
    if ((keyPressed == true) && (key == keyPlus))  {value++;}
    checkLimit();
  }
  
  void checkLimit() {
    if(value < valMin) value = valMin;
    if(value > valMax) value = valMax;
  }
  
  void drawMe() {

    // Slider Info
    strokeWeight(1);
    fill(255);
    textAlign(LEFT, BOTTOM);
    text( "[" + keyMinus + "," + keyPlus + "] " + name,xpos,ypos-0.75*diameter);
    textAlign(LEFT, CENTER);
    text(int(value) + " " + unit,xpos+6+len,ypos-1);
    
    // Slider Bar
    fill(100); noStroke();
    rect(xpos,ypos-0.15*diameter,len,0.3*diameter,0.3*diameter);
    // Bar Indentation
    fill(50);
    rect(xpos+3,ypos-1,len-6,0.15*diameter,0.15*diameter);
    // Bar Positive Fill
    fill(150);
    rect(xpos+3,ypos-1,0.5*diameter+(len-1.0*diameter)*(value-valMin)/(valMax-valMin),0.15*diameter,0.15*diameter);
    
    // Slider Circle
    noStroke();
    fill(200);
    ellipse(xpos+0.5*diameter+(len-1.0*diameter)*(value-valMin)/(valMax-valMin),ypos,diameter,diameter);
  }
}

class RadioButton {
  String name;
  int col;
  int xpos;
  int ypos;
  int diameter;
  char keyToggle;
  int valMin;
  int valMax;
  boolean value;
  boolean DEFAULT_VALUE;
  
  RadioButton() {
    xpos = 0;
    ypos = 0;
    diameter = 20;
    keyToggle = ' ';
    value = false;
    col = 200;
  }
  
  void listen() {
    
    // Mouse Controls
    if(mousePressed && (mouseY > (ypos-diameter)) && (mouseY < (ypos)) && (mouseX > xpos) && (mouseX < xpos+diameter)) {
      value = !value;
    }
    
    // Keyboard Controls
    if ((keyPressed == true) && (key == keyToggle)) {value = !value;}
  }
  
  void drawMe() {
    
    pushMatrix(); translate(0, -0.5*diameter, 0);
    
    // Button Info
    strokeWeight(1);
    if (value) { fill(255); }
    else       { fill(150); } 
    textAlign(LEFT, CENTER);
    text("[" + keyToggle + "] " + name,xpos + 1.5*diameter,ypos);
    
    // Button Holder
    noStroke(); fill(50);
    ellipse(xpos+0.5*diameter+1,ypos+1,diameter,diameter);
    fill(100);
    ellipse(xpos+0.5*diameter,ypos,diameter,diameter);
    
    // Button Circle
    noStroke();
    if (value) { fill(col); } 
    else       { fill( 0 ); } 
    ellipse(xpos+0.5*diameter,ypos,0.7*diameter,0.7*diameter);
    
    popMatrix();
  }
}

// Class that maps a point within a triangle to 3 values that add to 1.0
//
class TriSlider {
  float value1, value2, value3;
  String name, name1, name2, name3;
  int col1, col2, col3;
  int xpos, ypos;
  PVector pt, corner1, corner2, corner3;
  int diameter;
  boolean isDragged;
  float avgX, avgY, r;
  PVector avg;
  
  TriSlider() {
    diameter = 15;
    corner1 = new PVector(0, 0);
    corner2 = new PVector(0, 0);
    corner3 = new PVector(0, 0);
    pt      = new PVector(0, 0);
    xpos = 0;
    ypos = 0;
    isDragged = false;
    // Default
    value1 = 0.1;
    value2 = 0.2;
    value3 = 0.7;
  }
  
  void listen() {
    PVector mouse = new PVector(mouseX, mouseY);
    if (mouse.dist(avg) < r) isDragged = true;
  }
  
  void update() {
    
    // Update Mouse Condition
    if(isDragged || keyPressed) {
      PVector mouse = new PVector(mouseX, mouseY);
      if(mouse.dist(avg) > r && isDragged) {
        PVector ray = new PVector(mouse.x - avg.x, mouse.y - avg.y);
        ray.setMag(r);
        mouse = new PVector(avg.x, avg.y);
        mouse.add(ray);
      }
      if (mousePressed && isDragged) {
        pt.x = mouse.x;
        pt.y = mouse.y;
      }
      calculateValues();
    }
  }
  
  void calculateValues() {
    // Update Values
    float dist1, dist2, dist3;
    float pow = 3;
    float maxDist = 1.45*r;
    if (pt.dist(corner1) > maxDist) {
      dist1 = 0;
    } else {
      dist1 = 1 / pow(pt.dist(corner1) + 0.00001, pow);
    }
    if (pt.dist(corner2) > maxDist) {
      dist2 = 0;
    } else {
      dist2 = 1 / pow(pt.dist(corner2) + 0.00001, pow);
    }
    if (pt.dist(corner3) > maxDist) {
      dist3 = 0;
    } else {
      dist3 = 1 / pow(pt.dist(corner3) + 0.00001, pow);
    }
    float sum = dist1 + dist2 + dist3;
    
    dist1 /= sum;
    dist2 /= sum;
    dist3 /= sum;
    value1 = dist1;
    value2 = dist2;
    value3 = dist3;
  }
  
  void drawMe() {
    // Draw Background Circle + Triangle
    //
    noStroke();
    fill(50, 150);
    ellipse(avg.x+3, avg.y+3, 2*r, 2*r);
    fill(100, 150);
    ellipse(avg.x, avg.y, 2*r, 2*r);
    fill(100);
    beginShape();
    vertex(corner1.x, corner1.y);
    vertex(corner2.x, corner2.y);
    vertex(corner3.x, corner3.y);
    endShape(CLOSE);
    
    // Draw Cursor
    //
    fill(255);
    ellipse(pt.x, pt.y, diameter, diameter);
    
    // Draw Element Meta Information
    //
    textAlign(LEFT, TOP);
    text(name, xpos, ypos-16);
    textAlign(CENTER, CENTER); fill(col1);
    text(name1, avg.x,          avg.y+1.5*r);
    textAlign(LEFT,   CENTER); fill(col2);
    text(name2, xpos,           avg.y+1.5*r);
    textAlign(RIGHT,  CENTER); fill(col3);
    text(name3, xpos+2*(avg.x-xpos), avg.y+1.5*r);
    textAlign(CENTER, TOP);
    fill(col1);
    text(int(100*value1+0.5)+ "%", corner1.x, ypos);
    textAlign(RIGHT, TOP);
    fill(col2);
    text(int(100*value2+0.5) + "%   ", corner2.x, corner2.y);
    textAlign(LEFT, TOP);
    fill(col3);
    text("   " + int(100*value3+0.5) + "%", corner3.x, corner3.y);
  }
}