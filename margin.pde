
  
class Toolbar {
  int barX, barY, barW, barH; // X, Y, Width, and Height of Toolbar on Screen
  int contentW, contentH;     // pixel width and height of toolbar content accounting for margin
  int margin;                 // standard internal pixel buffer distance from edge of canvas
  int V_OFFSET = 35;          // standard vertical pixel distance between control elements
  int controlY;          // vertical position where controls begin
  
  String title, credit, explanation;
  ArrayList<ControlSlider> sliders;
  ArrayList<RadioButton> buttons;
  
  Toolbar(int barX, int barY, int barW, int barH, int margin) {
    this.barX = barX;
    this.barY = barY;
    this.barW = barW;
    this.barH = barH;
    this.margin = margin;
    contentW = barW - 2*margin;
    contentH = barH - 2*margin;
    sliders = new ArrayList<ControlSlider>();
    buttons = new ArrayList<RadioButton>();
    controlY = 300;
  }
  
  void addSlider(String name, String unit, int valMin, int valMax, float DEFAULT_VALUE, char keyMinus, char keyPlus) {
    int num = sliders.size() + buttons.size();
    ControlSlider s;
    
    s = new ControlSlider();
    s.name = name;
    s.unit = unit;
    s.keyPlus = keyPlus;
    s.keyMinus = keyMinus;
    s.xpos = barX + margin;
    s.ypos = controlY + num*V_OFFSET;
    s.len = contentW - margin;
    s.valMin = valMin;
    s.valMax = valMax;
    s.DEFAULT_VALUE = DEFAULT_VALUE;
    s.value = s.DEFAULT_VALUE;
    sliders.add(s);
  }
  
  void addButton(String name, boolean DEFAULT_VALUE, char keyToggle) {
    int num = sliders.size() + buttons.size();
    RadioButton b;
    
    b = new RadioButton();
    b.name = name;
    b.keyToggle = keyToggle;
    b.xpos = barX + margin;
    b.ypos = controlY + num*V_OFFSET;
    b.DEFAULT_VALUE = DEFAULT_VALUE;
    b.value = b.DEFAULT_VALUE;
    buttons.add(b);
  }
  
  void pressed() {
    if (sliders.size() > 0) for (ControlSlider s: sliders) s.listen();
    if (buttons.size() > 0) for (RadioButton   b: buttons) b.listen();
  }
  
  void released() {
    if (sliders.size() > 0) for (ControlSlider s: sliders) s.isDragged = false;
  }
  
  void restoreDefault() {
    if (sliders.size() > 0) for (ControlSlider s: sliders) s.value = s.DEFAULT_VALUE;
    if (buttons.size() > 0) for (RadioButton   b: buttons) b.value = b.DEFAULT_VALUE;
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
    fill(255, 50);
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
    if (isDragged) {
      value = (mouseX-xpos)*(valMax-valMin)/len+valMin;
    }
    if(value < valMin) value = valMin;
    if(value > valMax) value = valMax;
  }
  
  void listen() {
    if(mousePressed && (mouseY > (ypos-diameter/2)) && (mouseY < (ypos+diameter/2)) && (mouseX > (xpos-diameter/2)) && (mouseX < (xpos+len+diameter/2))) {
      isDragged = true;
    }
    
    //Keyboard Controls
    if ((keyPressed == true) && (key == keyMinus)) {value--;}
    if ((keyPressed == true) && (key == keyPlus))  {value++;}
  }
  
  void drawMe() {

    // Slider Info
    strokeWeight(1);
    fill(255);
    textAlign(LEFT, BOTTOM);
    text(name + " - " + keyMinus + " , " + keyPlus + " ",xpos,ypos-0.75*diameter);
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
    text(name + " [" + keyToggle + "]",xpos + 1.5*diameter,ypos);
    
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