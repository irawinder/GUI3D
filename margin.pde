int s_vOffset = 300;
  
class Toolbar {
  int barWidth;
  int GAP;
  int s_width;
  int S_V_GAP = 70;
  int S_U_OFFSET = 25;
  
  String title, credit, explanation;
  
  controlSlider s1;
  controlSlider s2;
  controlSlider s3;
  
  Toolbar(int w, int g) {
    barWidth = w;
    GAP = g;
    s_width = barWidth - 3*S_U_OFFSET;
    
    initControls();
  }
  
  void initControls() {
    s1 = new controlSlider();
    s1.name = "Slider 1";
    s1.keyPlus = 'w';
    s1.keyMinus = 'q';
    s1.xpos = GAP + S_U_OFFSET;
    s1.ypos = s_vOffset + 0*S_V_GAP;
    s1.len = s_width;
    s1.valMin = 0;
    s1.valMax = 100;
    s1.value = 50;
    
    s2 = new controlSlider();
    s2.name = "Slider 2";
    s2.keyPlus = 's';
    s2.keyMinus = 'a';
    s2.xpos = GAP + S_U_OFFSET;
    s2.ypos = s_vOffset + 1*S_V_GAP;
    s2.len = s_width;
    s2.valMin = 0;
    s2.valMax = 100;
    s2.value = 50;
    
    s3 = new controlSlider();
    s3.name = "Slider 3";
    s3.keyPlus = 'x';
    s3.keyMinus = 'z';
    s3.xpos = GAP + S_U_OFFSET;
    s3.ypos = s_vOffset + 2*S_V_GAP;
    s3.len = s_width;
    s3.valMin = 0;
    s3.valMax = 100;
    s3.value = 50;
  }
  
  void pressed() {
    s1.listenClick();
    s2.listenClick();
    s3.listenClick();  
  }
  
  void released() {
    s1.isDragged = false;
    s2.isDragged = false;
    s3.isDragged = false;
  }
  
  void restoreDefault() {
    s1.value = 50;
    s2.value = 50;
    s3.value = 50;
  }
  
  void draw() {
    fill(255, 50);
    noStroke();
    pushMatrix();
    translate(GAP, GAP);
    rect(0, 0, barWidth, height - 2*GAP, GAP);
    translate(S_U_OFFSET, S_U_OFFSET);
    textAlign(LEFT, TOP);
    fill(255);
    text(title + "\n" + credit + "\n\n" + explanation, 0, 0, barWidth - 2*S_U_OFFSET, height - 2*GAP - 2*S_U_OFFSET);
    popMatrix();
    
    s1.listen();
    s1.drawMe();
    
    s2.listen();
    s2.drawMe();
    
    s3.listen();
    s3.drawMe();
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

class controlSlider {
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
  
  controlSlider() {
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
  
  void listen() {
    //Keyboard Controls
    if ((keyPressed == true) && (key == keyMinus)) {value--;}
    if ((keyPressed == true) && (key == keyPlus)) {value++;}
    
    if (isDragged) {
    value = (mouseX-xpos)*(valMax-valMin)/len+valMin;
    }
  
    if(value < valMin) value = valMin;
    if(value > valMax) value = valMax;
  }
  
  void listenClick() {
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
    text(int(value),xpos+diameter+len+5,ypos);
    
    stroke(100);
    fill(255,100);
    rect(xpos,ypos-0.5*diameter,len+0.5*diameter,diameter,diameter);
    
    stroke(150);
    fill(150);
    ellipse(xpos+0.5*diameter+(len-0.5*diameter)*(value-valMin)/(valMax-valMin),ypos,diameter,diameter);
  }
}