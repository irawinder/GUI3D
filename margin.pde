int s_vOffset = 300;
  
class Toolbar {
  int barWidth;
  int GAP;
  int s_width;
  int S_V_GAP = 70;
  int S_U_OFFSET = 25;
  
  String title, credit, explanation;
  
  ControlSlider s1;
  ControlSlider s2;
  ControlSlider s3;
  ControlSlider s4;
  
  RadioButton b1;
  RadioButton b2;
  RadioButton b3;
  
  Toolbar(int w, int g) {
    barWidth = w;
    GAP = g;
    s_width = barWidth - 3*S_U_OFFSET;
    
    initControls();
  }
  
  void initControls() {
    s1 = new ControlSlider();
    s1.name = "Slider 1";
    s1.keyPlus = 'w';
    s1.keyMinus = 'q';
    s1.xpos = GAP + S_U_OFFSET;
    s1.ypos = s_vOffset + 0*S_V_GAP;
    s1.len = s_width;
    s1.valMin = 0;
    s1.valMax = 100;
    s1.value = 50;
    
    s2 = new ControlSlider();
    s2.name = "Slider 2";
    s2.keyPlus = 's';
    s2.keyMinus = 'a';
    s2.xpos = GAP + S_U_OFFSET;
    s2.ypos = s_vOffset + 1*S_V_GAP;
    s2.len = s_width;
    s2.valMin = 0;
    s2.valMax = 100;
    s2.value = 50;
    
    s3 = new ControlSlider();
    s3.name = "Slider 3";
    s3.keyPlus = 'x';
    s3.keyMinus = 'z';
    s3.xpos = GAP + S_U_OFFSET;
    s3.ypos = s_vOffset + 2*S_V_GAP;
    s3.len = s_width;
    s3.valMin = 0;
    s3.valMax = 100;
    s3.value = 50;
    
    s4 = new ControlSlider();
    s4.name = "Slider 3";
    s4.keyPlus = 'x';
    s4.keyMinus = 'z';
    s4.xpos = GAP + S_U_OFFSET;
    s4.ypos = s_vOffset + 3*S_V_GAP;
    s4.len = s_width;
    s4.valMin = 0;
    s4.valMax = 100;
    s4.value = 50;
    
    b1 = new RadioButton();
    b1.name = "Button 1";
    b1.keyToggle = '1';
    b1.xpos = GAP + S_U_OFFSET;
    b1.ypos = s_vOffset + 4*S_V_GAP;
    b1.value = false;
    
    b2 = new RadioButton();
    b2.name = "Button 2";
    b2.keyToggle = '2';
    b2.xpos = GAP + S_U_OFFSET;
    b2.ypos = s_vOffset + int(4.5*S_V_GAP);
    b2.value = false;
    
    b3 = new RadioButton();
    b3.name = "Button 3";
    b3.keyToggle = '3';
    b3.xpos = GAP + S_U_OFFSET;
    b3.ypos = s_vOffset + 5*S_V_GAP;
    b3.value = false;
  }
  
  void pressed() {
    s1.listen();
    s2.listen();
    s3.listen(); 
    s4.listen(); 
    
    b1.listen(); 
    b2.listen(); 
    b3.listen(); 
  }
  
  void released() {
    s1.isDragged = false;
    s2.isDragged = false;
    s3.isDragged = false;
    s4.isDragged = false;
  }
  
  void restoreDefault() {
    s1.value = 50;
    s2.value = 50;
    s3.value = 50;
    s4.value = 50;
    
    b1.value = false;
    b2.value = false;
    b3.value = false;
  }
  
  void draw() {
    camera();
    noLights();
    perspective();
    hint(DISABLE_DEPTH_TEST);
    
    pushMatrix();
    translate(GAP, GAP);
    
    // Shadow
    pushMatrix();
    translate(3, 3);
    noStroke();
    fill(0, 100);
    rect(0, 0, barWidth, height - 2*GAP, GAP);
    popMatrix();
    
    // Canvas
    fill(255, 50);
    noStroke();
    rect(0, 0, barWidth, height - 2*GAP, GAP);
    translate(S_U_OFFSET, S_U_OFFSET);
    textAlign(LEFT, TOP);
    fill(255);
    text(title + "\n" + credit + "\n\n" + explanation, 0, 0, barWidth - 2*S_U_OFFSET, height - 2*GAP - 2*S_U_OFFSET);
    popMatrix();
    
    s1.update();
    s1.drawMe();
    
    s2.update();
    s2.drawMe();
    
    s3.update();
    s3.drawMe();
    
    s4.update();
    s4.drawMe();
    
    b1.drawMe();
    b2.drawMe();
    b3.drawMe();
    
    hint(ENABLE_DEPTH_TEST);
  }
  
  boolean hover() {
    if (mouseX > GAP && mouseX < GAP + barWidth && 
        mouseY > GAP && mouseY < height - GAP) {
      return true;
    } else {
      return false;
    }
  }
}

class ControlSlider {
  String name;
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
  
  ControlSlider() {
    xpos = 0;
    ypos = 0;
    len = 200;
    diameter = 25;
    keyMinus = '-';
    keyPlus = '+';
    isDragged = false;
    valMin = 0;
    valMax = 0;
    value = 0;
  }
  
  void update() {
    //Keyboard Controls
    if ((keyPressed == true) && (key == keyMinus)) {value--;}
    if ((keyPressed == true) && (key == keyPlus)) {value++;}
    
    if (isDragged) {
      value = (mouseX-xpos)*(valMax-valMin)/len+valMin;
    }
  
    if(value < valMin) value = valMin;
    if(value > valMax) value = valMax;
  }
  
  void listen() {
    if((mouseY > (ypos-diameter/2)) && (mouseY < (ypos+diameter/2)) && (mouseX > (xpos-diameter/2)) && (mouseX < (xpos+len+diameter/2))) {
      isDragged = true;
    }
  }
  
  void drawMe() {
    fill(255);
    
    strokeWeight(1);
    fill(255);
    textAlign(LEFT, BOTTOM);
    text(name,xpos,ypos-0.75*diameter);
    textAlign(CENTER, CENTER);
    text(int(value),xpos+0.75*diameter+len,ypos);
    
    fill(255,100);
    stroke(100);
    rect(xpos,ypos-0.5*diameter,len,diameter,diameter);
    
    noStroke();
    fill(200, 200);
    ellipse(xpos+0.5*diameter+(len-1.0*diameter)*(value-valMin)/(valMax-valMin),ypos,diameter,diameter);
  }
}

class RadioButton {
  String name;
  int xpos;
  int ypos;
  int diameter;
  
  char keyToggle;
  
  int valMin;
  int valMax;
  
  boolean value;
  
  RadioButton() {
    xpos = 0;
    ypos = 0;
    diameter = 25;
    keyToggle = ' ';
    value = false;
  }
  
  void listen() {
    
    // Mouse Controls
    if((mouseY > (ypos-diameter/2)) && (mouseY < (ypos+diameter/2)) && (mouseX > xpos) && (mouseX < xpos+diameter)) {
      value = !value;
    }
    
    // Keyboard Controls
    if ((keyPressed == true) && (key == keyToggle)) {value = !value;}
  }
  
  void drawMe() {
    fill(255);
    
    strokeWeight(1);
    fill(255);
    textAlign(CENTER, CENTER);
    text(name,xpos + 2.5*diameter,ypos);
    
    noFill();
    stroke(100);
    strokeWeight(3);
    ellipse(xpos+0.5*diameter,ypos,diameter,diameter);
    
    noStroke();
    if (value) {
      fill(175);
    } else {
      fill(0);
    }
    ellipse(xpos+0.5*diameter,ypos,0.7*diameter,0.7*diameter);
  }
}