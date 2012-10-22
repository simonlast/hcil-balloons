import processing.video.*;

PShape s;

float PI = (float)Math.PI;

ArrayList<Balloon> balloons;
ArrayList<Balloon> toRemove;
color bkg = color(255);

PVector bSpeed = new PVector(.2,-3.5);

PVector maxSpeed = new PVector(.5,3.5);

float minOpacity = 255*.65;
float maxOpacity = 255*.95;
float damp = .7;
float bounciness;
float radDiv = 20.0;
float stringRad = 5;
color stringCol = color(172);

Balloon yellowBalloon;

void setup(){
  size(displayWidth,displayHeight);
  smooth();
  noStroke();
  shapeMode(CENTER);
  bounciness = width*.3;
  s = loadShape("logo.svg");
  balloons = new ArrayList<Balloon>();
  toRemove = new ArrayList<Balloon>();
}

void mousePressed(){
  balloons.add(new Balloon(mouseX,height+150,random(70,150)));  
}

void keyPressed(){
  if(key == 's'){
    if(yellowBalloon == null){
     yellowBalloon = new Balloon(width/2+s.width/25,height/2-s.height/7,80);
     yellowBalloon.c = color(255,220,75);
     yellowBalloon.grav = new PVector(); 
     yellowBalloon.v = new PVector();  
     yellowBalloon.front = false;
    }else{
     yellowBalloon.grav.y = -.01;  
     yellowBalloon.v.x = random(-.2,.2);      
    }
  }else{
    balloons.add(new Balloon(random(0,width),random(height+150,height*2),random(70,150)));  
  }
  
}

void draw(){
  background(bkg);
  
  if(yellowBalloon != null){
   yellowBalloon.render(false); 
  }
  for(Balloon b : balloons){
    b.render(false); 
  }
  shape(s, width/2, height/2, s.width*.8, s.height*.8);
  for(Balloon b : balloons){
    b.render(true); 
  }
  for(Balloon b : toRemove){
    balloons.remove(b);
  }
  toRemove = new ArrayList<Balloon>();
  //saveFrame("output/frames####.png");
}

class Balloon{
 PVector pos,v,grav,a;
 ArrayList<PVector> points; 
 ArrayList<PVector> trail;
 color c;
 float rad,rot;
 float opac,fullOpac;
 boolean front;
  
 Balloon(float x, float y, float rad){
  front = Math.random() > .5;
  trail = new ArrayList<PVector>();
  grav = new PVector(bSpeed.x*random(-1,1),bSpeed.y*random(.5,1.5));
  v = new PVector();
  this.rad = rad;
  fullOpac = random(minOpacity,maxOpacity);
  rot = 0;
  opac = 0;
  pos = new PVector(x,y);
  a = new PVector();
  c = color(random(150,220),random(150,220),random(150,220));
  points = new ArrayList<PVector>();
  for(int i=0; i<20; i++){
    double deg = (2*PI)/20*i;
    float dx = (float)Math.cos(deg)*rad;
    float dy = (float)Math.sin(deg)*rad;
    float distFromBottom = abs((float)(deg - PI/2));
    if(distFromBottom > PI/8){
      points.add(new PVector(dx,dy));
    }else{
      if(distFromBottom > PI/16){
        points.add(new PVector(dx,dy+rad/10));
      }else{
        points.add(new PVector(dx,dy+rad/4));
      }
    }
  }
  
 }

 void render(boolean front){
  
   if(this.front != front)
     return;
   
  if(pos.y < -1*(rad+100)){
   toRemove.add(this);
   return;
  }  
  
  bounceCheck(); 
  
  v.y += grav.y;
  pos.y += grav.x;

  if(v.y < -1*maxSpeed.y){
   v.y = -1*maxSpeed.y; 
  }
  pos.add(v);

  
  rot += (v.x-rot)*.02;
  
  pushMatrix();

  translate(pos.x,pos.y);
  rotate(rot/4);
  opac += (fullOpac-opac)*.05;
  fill(c,opac);
  
  noStroke();
  beginShape();
  for(PVector p : points){
   curveVertex(p.x,p.y); 
  }
  curveVertex(points.get(0).x,points.get(0).y);
  curveVertex(points.get(1).x,points.get(1).y);
  curveVertex(points.get(2).x,points.get(2).y);
  endShape();
  //ellipse(pos.x,pos.y,100,100);
  popMatrix();
  
 } 
 
 boolean bounceCheck(){
    for(Balloon c : balloons){
      if(c == this){
        continue;
      }
      float d = PVector.dist(pos,c.pos);
      if(d < rad+c.rad){
        
        float m1 = rad/radDiv;
        float m2 = c.rad/radDiv;

        PVector averagePos = new PVector((pos.x+c.pos.x)/2,(pos.y+c.pos.y)/2);
        PVector dX = new PVector(pos.x-averagePos.x,pos.y-averagePos.y);
        PVector cdX = new PVector(c.pos.x-averagePos.x,c.pos.y-averagePos.y);
        dX.mult(1/sq(d)*bounciness/m1);
        cdX.mult(1/sq(d)*bounciness/m2);
        v.add(dX);
        c.v.add(cdX);
        v.mult(damp);
        c.v.mult(damp);
        return true;
      }
    }
    return false;
  }
  
}
