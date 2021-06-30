import oscP5.*;
import netP5.*;
import hypermedia.net.*;
import java.util.Set;
import br.campinas.redrawing.MessageManager;
import br.campinas.redrawing.data.BodyPose;
import br.campinas.redrawing.data.BodyVel;
import br.campinas.redrawing.data.Gesture;
import processing.sound.*;

//Creates the message manager, setting the message queue size of 5 (per data type) and true for deleting old messages 
MessageManager msgManager = new MessageManager(5, true);
JSONObject json;
UDP udp;

SoundFile face1;
SoundFile face2;
SoundFile face3;
SoundFile face4;
SoundFile face5;
SoundFile face6;
SoundFile rotUP;
SoundFile rotDOWN;
SoundFile rotLEFT;
SoundFile rotRIGHT;

PImage backgroundBlur;
PImage fistImage;
PImage okImage;
PImage oneImage;
PImage twoImage;
PImage threeImage;


private int[][] keypoints;
private String[] keypointsName;
private float[] previousHandPos;
private float[] handPos;
private float Zp = 0;
private float Z = 0;
private float[] neck_pos;
private float[] nose_pos;
private float[] eye_r_pos;
private float[] eye_l_pos;
private float[] shoulder_r_pos;
private float[] shoulder_l_pos;
private float[] wrist_r_pos;
private float [] wrist_l_pos;
private float[] wrist_r_vel;
private float[] wrist_l_vel;
private PVector estimetedHandPos;


public ArrayList<Trajectory> trajectories = new ArrayList<Trajectory>();
public Trajectory traj;

private int redValue;
private int greenValue;
private int blueValue;
private int yellowValue;
private boolean eraser = false;
private boolean MOTION_BLUR = false;
private int counter = 0;
private ArrayList<Integer> colors = new ArrayList<Integer>();
private int quadrantColor;
private int quadrant;
private int face = 1;
private int myCurrentRandomNumber;
private int drawMode = 1;
private String cubeRotation = "";
private String actualGesture = "";
private String previousGesture = "";
private int gestureCount = 0;
private int actualFrame = 0;
private int previousFrame =0;
private float loadingStep = 0;
private String soundMode = "embodie";//"pottery","games", "embodie", "piano"

private boolean blazeposeMode = true;
private boolean enableMouseControl = true;
private boolean wasDrawing = false;
private boolean editingMode = false;
private boolean enableSlerp = false;
private boolean enableInterpolation = false;
private boolean isGestureLoading = false;
private boolean firstEditing = true;


void setup() {

  soundSetup();



  fullScreen();
  colorMode(HSB, 360, 100, 100);
  udp = new UDP( this, 6000); // Trocar pela porta que você usar
  udp.listen( true ); 


  backgroundBlur = loadImage("background.jpg");
  backgroundBlur.resize(width, height);
  fistImage = loadImage("fist.png");
  fistImage.resize(150, 150);
  okImage = loadImage("ok.png");
  okImage.resize(150, 150);
  oneImage = loadImage("one.png");
  oneImage.resize(150, 150);
  twoImage = loadImage("two.png");
  twoImage.resize(150, 150);
  threeImage = loadImage("three.png");
  threeImage.resize(150, 150);
  //estimetedHandPos = new float[3] ;
  //estimetedHandPos2 = new float[3] ;
  estimetedHandPos = new PVector(0, 0);
  previousHandPos = new float[3]; 
  handPos = new float[3];
  keypoints = new int[0][3];
  keypointsName = new String[0];
  drawBackground();
  setQuadrants();

  traj = new Trajectory(new PVector(0, 0), new PVector(0, 0), 0, 0, 1);//Para salvar trajetória
}

void draw() {

  fill(10, 0, 100);
  noStroke();
  rect(0, 0, 130, 120);
  textSize(34);
  fill(0, 0, 0);
  text("Modo:"+ drawMode, 0, 35);
  text("Face:"+ face, 0, 70);

  if (enableSlerp) {
    text("Slerp", 0, 105);
  } else if (enableInterpolation) {
    text("Lerp", 0, 105);
  }

  verifyQuadrants();
  rotateCube(this.cubeRotation);

  //verifica se esta no modo de edição
  if (editingMode) {

    if (firstEditing) {
      tint(255, 127);
      image(backgroundBlur, 0, 0);
      tint(255, 255);
      firstEditing = false;
    }
    //verifica de abaixou as maos para detectar o gesto

    face1.stop();
    face2.stop();
    face3.stop();
    face4.stop();
    face5.stop();
    face6.stop();
    actualGesture = updateGesture();

    if (actualGesture != "") {
      if (previousGesture == actualGesture) {
        isGestureLoading = true;
        drawLoading();
        displayGestureSilhouette(previousGesture);
        //Verifica se manteve o mesmo comando por 10 iterações =~ 4 segundos para executar o comando
        gestureCount++;
        if (gestureCount == 8) {
          executeGestureCommand(previousGesture);
          clearGestureLoading();
        }
      } else {
        previousGesture = actualGesture;
        gestureCount = 0;
        clearGestureLoading();
      }
    }
  } else {
    firstEditing = true;
    //atualisa posição do traço dependendo do modo 
    if (enableMouseControl) {
      if (mousePressed) {
        updateMouseData(this.face);
        playFaceSound(this.face);
      }
    } 
    if (msgManager.hasMessage(BodyPose.class) && !enableMouseControl )
    {
      previousFrame = actualFrame;
      actualFrame = frameCount;
      updateOAKData(this.face);
      playFaceSound(this.face);

      //verifica condição de ambas as mãos levantadas para entrar no modo de edição
      if (wrist_l_pos[1] < nose_pos[1] && wrist_r_pos[1] < nose_pos[1]) {
        editingMode = true;
      }
    } 



    //para apagar tela e salvar em um arquivo de imagem.
    if (this.eraser) {
      print("salvou");
      saveFrame("savedSession"+"_"+day()+"-"+month()+"-"+year()+"_"+hour()+"-"+minute()+"-"+second()+".tif"); 
      drawBackground();
      eraserTrajectory();
      this.eraser = false;

      counter = counter + 1;
    }
    drawRabisco();
  }
}  

void drawRabisco() {



  //verifica o quadrante e as coordenadas do traço dependendo de cada face
  this.quadrantColor = setColors(this.quadrant);

  setReferences(this.face); 


  float firstSpeed = dist(this.previousHandPos[0], this.previousHandPos[1], this.handPos[0], this.handPos[1]);//dist(Xp*width, Yp*height, X*width, Y*height);



  float lineWidth = map(firstSpeed, 5, 50, 2, 20);
  lineWidth = constrain(lineWidth, 0, 100);


  noStroke();
  fill(0, 100);
  strokeCap(ROUND);
  stroke(quadrantColor, int(random(80, 100)), 100);
  strokeWeight(lineWidth);
  switch(drawMode) {
  case 1: 
    line(this.previousHandPos[0], previousHandPos[1], this.handPos[0], this.handPos[1]);
    break;
  case 2: 
    point(this.handPos[0], this.handPos[1]);
    break;
  case 3: 
    rect(this.handPos[0], this.handPos[1], random(80), random(80));
    break;
  }
}
//Receive the message and give it to the manager
void receive(byte[] data, String ip, int port)
{
  data = subset(data, 0, data.length);
  String message = new String( data );

  msgManager.insertMessage(message);
} 

void displayGestureSilhouette(String gesture) {
  switch (gesture) {
  case "ONE":
    image(oneImage, width-170, 20);
    break;
  case "PEACE":
    image(twoImage, width-170, 20);
    break;
  case "THREE":
    image(threeImage, width-170, 20);
    break;
  case "OK":
    image(okImage, width-170, 20);
    break;
  case "FIST":
    image(fistImage, width-170, 20);
    break;
  default: 
    clearGestureLoading();
    break;
  }
}
String updateGesture() {
  String gestureStr = "";
  if (msgManager.hasMessage(Gesture.class))
  {
    Gesture gesture = msgManager.getData(Gesture.class);

    if (gesture.gesture != null && gesture.gesture != "NONE") {

      switch (gesture.gesture) {
      case "ONE":
        gestureStr = "ONE";
        break;
      case "PEACE":
        gestureStr = "PEACE";
        break;
      case "THREE":
        gestureStr = "THREE";
        break;
      case "OK":
        gestureStr = "OK";
        break;
      case "FIST":
        gestureStr = "FIST";
        break;
      default: 
        gestureStr = "";
      }
    }
  }
  return gestureStr;
}

void drawLoading() {

  if (this.isGestureLoading) {
    noStroke();
    fill(235, 100, 100);
    arc(width-95, 95, 160, 160, PI + PI/2, PI + PI/2 + this.loadingStep, PIE);
    fill(0, 0, 100);
    ellipse(width-95, 95, 150, 150);

    this.loadingStep += 0.89;
  } else {
    clearGestureLoading();
  }
}

void clearGestureLoading() {
  this.isGestureLoading = false;
  this.loadingStep = 0;
  noStroke();
  fill(0, 0, 100);
  ellipse(width-95, 95, 165, 165);
}

void updateMouseData(int face)
{
  if (wasDrawing) {
    this.previousHandPos[0] = this.handPos[0];
    this.previousHandPos[1] = this.handPos[1];
  }

  //Verifica em qual face está para mudar escolher os eixos apropriados. 
  //Mudar para função, estava dando conflita da maneira que fiz.
  switch(face) {
  case 1: 
    this.handPos[0] = map(float(mouseX), 0, width, 0, 1)*width;
    this.handPos[1] = map(float(mouseY), 0, height, 0, 1)*height;
    break;
  case 2: 
    this.handPos[0] = -map(float(mouseY), 0, height, 0, 1)*width;//-this.Z;
    this.handPos[1] = map(float(mouseX), 0, width, 0, 1)*height;//this.handPos[1];
    break;
  case 3: 
    this.handPos[0] = map(float(mouseX), 0, width, 0, 1)*width;
    this.handPos[1] = -map(float(mouseY), 0, height, 0, 1)*height;//this.Z;
    break;
  case 4: 
    this.handPos[0] = -map(float(mouseX), 0, width, 0, 1)*width;//this.Z;
    this.handPos[1] = map(float(mouseY), 0, height, 0, 1)*height;
    ;
    break;
  case 5: 
    this.handPos[0] = -map(float(mouseX), 0, width, 0, 1)*width;//this.handPos[0];
    this.handPos[1] = -map(float(mouseY), 0, height, 0, 1)*height;//-this.Z;
    break;
  case 6: 
    this.handPos[0] = map(float(mouseX), 0, width, 0, 1)*width;
    this.handPos[1] = -map(float(mouseY), 0, height, 0, 1)*height;
    break;
  }

  if (!wasDrawing) {
    this.previousHandPos[0] = this.handPos[0];
    this.previousHandPos[1] = this.handPos[1];
  }

  verifyQuadrants();
  this.traj.update(new PVector(this.handPos[0], this.handPos[1]), new PVector(this.previousHandPos[0], this.previousHandPos[1]), this.quadrant, this.drawMode);


  wasDrawing = true;
  //}
}


//Função para atualizar os pontos recebidos dos modelos, blazepose ou ligthpose
void updateOAKData(int face)
{
  //BodyPose bodyvel = msgManager.getData(BodyVel.class);  
  //neck_pos = bodypose.keypoints.get("NECK");
  //eye_r_pos = bodypose.keypoints.get("EYE_R");
  //eye_l_pos = bodypose.keypoints.get("EYE_L");
  //shoulder_r_pos = bodypose.keypoints.get("SHOULDER_R");
  //shoulder_l_pos = bodypose.keypoints.get("SHOULDER_L");

  BodyPose bodypose = msgManager.getData(BodyPose.class);
  nose_pos = bodypose.keypoints.get("NOSE");

  if (blazeposeMode) {
    if (bodypose.keypoints.get("WRIST_L") != null) {
      wrist_l_pos = bodypose.keypoints.get("WRIST_L");
      this.previousHandPos[0] =  this.handPos[0];
      this.previousHandPos[1] =  this.handPos[1];
      if (wrist_l_pos[0] != Float.POSITIVE_INFINITY && wrist_l_pos[1] != Float.POSITIVE_INFINITY) {
        //Verifica em qual face está para mudar escolher os eixos apropriados. 
        //Mudar para função, estava dando conflita da maneira que fiz.
        estimetedHandPos = estimateHandPosition();
        switch(face) {
        case 1: 
          this.handPos[0] = estimetedHandPos.x;
          this.handPos[1] = estimetedHandPos.y;
          break;
        case 2: 
          this.handPos[0] = -estimetedHandPos.y*width/height;//-this.Z;
          this.handPos[1] = estimetedHandPos.x*height/width;//this.handPos[1];
          break;
        case 3: 
          this.handPos[0] = estimetedHandPos.x;
          this.handPos[1] = -estimetedHandPos.y;//this.Z;
          break;
        case 4: 
          this.handPos[0] = -estimetedHandPos.x;//this.Z;
          this.handPos[1] = estimetedHandPos.y;
          break;
        case 5: 
          this.handPos[0] = -estimetedHandPos.x;//this.handPos[0];
          this.handPos[1] = -estimetedHandPos.y;//-this.Z;
          break;
        case 6: 
          this.handPos[0] = estimetedHandPos.x;
          this.handPos[1] = -estimetedHandPos.y;
          break;
        }
      }
    }
    if (bodypose.keypoints.get("WRIST_R") != null) {
      wrist_r_pos = bodypose.keypoints.get("WRIST_R");
    }
    if (bodypose.keypoints.get("NOSE") != null) {
      nose_pos = bodypose.keypoints.get("NOSE");
    }
  } else {
    if (bodypose.keypoints.get("WRIST_R") != null) {
      wrist_r_pos = bodypose.keypoints.get("WRIST_R"); 
      wrist_l_pos = bodypose.keypoints.get("WRIST_L");
      this.previousHandPos[0] =  this.handPos[0];
      this.previousHandPos[1] =  this.handPos[1];

      if (wrist_r_pos[0] != Float.POSITIVE_INFINITY && wrist_r_pos[1] != Float.POSITIVE_INFINITY) {
        this.handPos[0] = map(wrist_r_pos[0], -0.3, 1.25, 1, 0)*width;
        this.handPos[1] = map(wrist_r_pos[1], -0.6, 0.07, 0, 1)*height;

        //Verifica em qual face está para mudar escolher os eixos apropriados. 
        //Mudar para função, estava dando conflita da maneira que fiz.
        switch(this.face) {
        case 1: 
          this.handPos[0] = map(wrist_r_pos[0], -0.3, 1.25, 1, 0)*width;
          this.handPos[1] = map(wrist_r_pos[1], -0.6, 0.07, 0, 1)*height;
          break;
        case 2: 
          this.handPos[0] = -map(wrist_r_pos[1], -0.6, 0.07, 0, 1)*width;//-this.Z;
          this.handPos[1] = map(wrist_r_pos[0], -0.3, 1.25, 1, 0)*height;//this.handPos[1];
          break;
        case 3: 
          this.handPos[0] = map(wrist_r_pos[0], -0.3, 1.25, 1, 0)*width;
          this.handPos[1] = -map(wrist_r_pos[1], -0.6, 0.07, 0, 1)*height;//this.Z;
          break;
        case 4: 
          this.handPos[0] = -map(wrist_r_pos[0], -0.3, 1.25, 1, 0)*width;//this.Z;
          this.handPos[1] = map(wrist_r_pos[1], -0.6, 0.07, 0, 1)*height;
          break;
        case 5: 
          this.handPos[0] = -map(wrist_r_pos[0], -0.3, 1.25, 1, 0)*width;//this.handPos[0];
          this.handPos[1] = -map(wrist_r_pos[1], -0.6, 0.07, 0, 1)*height;//-this.Z;
          break;
        case 6: 
          this.handPos[0] = map(wrist_r_pos[0], -0.3, 1.25, 1, 0)*width;
          this.handPos[1] = -map(wrist_r_pos[1], -0.6, 0.07, 0, 1)*height;
          break;
        }
      }
    }
  }
  verifyQuadrants();
  this.traj.update(new PVector(this.handPos[0], this.handPos[1]), new PVector(this.previousHandPos[0], this.previousHandPos[1]), this.quadrant, this.drawMode);
}

PVector estimateHandPosition() {
  PVector estimate = new PVector(0, 0);
  if (enableInterpolation) {
    estimate = slerp(new PVector(this.previousHandPos[0], this.previousHandPos[1]), new PVector((map(wrist_l_pos[0], 0, 100, 1, 0)*width), (map(wrist_l_pos[1], 0, 100, 0, 1)*height)), 0.5);
    if (estimate.x != 0 && estimate.y != 0 && enableSlerp) {
      return estimate;
    } else {
      return new PVector(lerp(this.previousHandPos[0], (map(wrist_l_pos[0], 0, 100, 1, 0)*width), 0.5), lerp(this.previousHandPos[1], (map(wrist_l_pos[1], 0, 100, 0, 1)*height), 0.5));
    }
  } else {
    return new PVector((map(wrist_l_pos[0], 0, 100, 1, 0)*width), (map(wrist_l_pos[1], 0, 100, 0, 1)*height));
  }
}

void executeGestureCommand(String command) {
  switch (command) {
  case "ONE":
    this.drawMode = 1;//linha
    break;
  case "PEACE":
    this.drawMode = 2;//esferas
    break;
  case "THREE":
    this.drawMode = 3;//quadrados
    break;
  case "OK":
    this.cubeRotation = "DOWN";
    break;
  case "FIST":
    this.cubeRotation = "LEFT";
    break;
  }
  this.editingMode = false;
  drawBackground();
  plotAll();
}


//Função para desenhar background, 
void drawBackground() {

  color back = color(100, 0, 100);
  if (MOTION_BLUR) {
    // Background with motion blur
    noStroke();
    fill(back, 45);
    rect(0, 0, width, height);
  } else {
    // Normal background
    noStroke();
    background(back);
  }
}

public void verifyQuadrants() {

  switch(this.face) {
    case(1):
    //face1.loop();

    if (this.handPos[0]<0.5*width && this.handPos[1]<0.5*height) {
      this.quadrant = 1;
    }//primeiro quadrante
    if (this.handPos[0]>0.5*width && this.handPos[1]<0.5*height) {
      this.quadrant = 2;
    }//segundo quadrante
    if (this.handPos[0]>0.5*width && this.handPos[1]>0.5*height) {
      this.quadrant = 3;
    }//terceiro quadrante
    if (this.handPos[0]<0.5*width && this.handPos[1]>0.5*height) {
      this.quadrant = 4;
    }//quarto quadrante
    break;
    case(2):
    if (this.handPos[1]<0.5*height) {
      this.quadrant = 2;
    }
    if (this.handPos[1]>0.5*height) {
      this.quadrant = 3;
    }
    break;
    case(3):
    if (this.handPos[0]<0.5*width) {
      this.quadrant = 1;
    }
    if (this.handPos[0]>0.5*width) {
      this.quadrant = 2;
    }
    break;
    case(4):
    if (this.handPos[1]<0.5*height) {
      this.quadrant = 1;
    }
    if (this.handPos[1]>0.5*height) {
      this.quadrant = 4;
    }
    break;
    case(5):
    if (this.handPos[0]<0.5*width) {
      this.quadrant = 4;
    }
    if (this.handPos[0]>0.5*width) {
      this. quadrant = 3;
    }
    break;
    case(6):
    if (this.handPos[0]<0.5*width && this.handPos[1]<0.5*height) {
      this.quadrant = 1;
    }//primeiro quadrante
    if (this.handPos[0]>0.5*width && this.handPos[1]<0.5*height) {
      this.quadrant = 2;
    }//segundo quadrante
    if (this.handPos[0]>0.5*width && this.handPos[1]>0.5*height) {
      this.quadrant = 3;
    }//terceiro quadrante
    if (this.handPos[0]<0.5*width && this.handPos[1]>0.5*height) {
      this.quadrant = 4;
    }//quarto quadrante
    break;
  }
}

//Função de inicialização das cores de cada quadrante
public void setQuadrants() {
  while (this.colors.size()<4) {
    do {
      this.myCurrentRandomNumber = (int) random(1, 5);
      //repeat this until the number is not in the list
    } while (this.colors.contains(new Integer(this.myCurrentRandomNumber)));
    //here there is a unique random number, do what you will
    //add the number to the list so it wont be picked again
    this.colors.add(new Integer(this.myCurrentRandomNumber));
  }
}

//Função para definir as cores de traço da face 
public int setColors(int quadrante) {
  int cor = 0;
  this.blueValue = int(random(170, 250));//210;//
  this.redValue = int(random(0, 20));//10;//
  this.greenValue = int(random(80, 120));//100;//
  this.yellowValue = int(random(40, 70));//40;// 

  if (quadrante == 1) {
    cor = this.colors.get(0);
  }//primeiro quadrante
  if (quadrante == 2) {
    cor = this.colors.get(1);
  }//segundo quadrante
  if (quadrante == 3) {
    cor = this.colors.get(2);
  }//terceiro quadrante
  if (quadrante == 4) {
    cor = this.colors.get(3);
  }//quarto quadrante


  switch(cor) {
  case 1: 
    cor = this.blueValue;
    break;
  case 2: 
    cor = this.redValue;
    break;
  case 3: 
    cor = this.greenValue;
    break;
  case 4: 
    cor = this.yellowValue;
    break;
  } 
  return cor;
}


//Função para transladar as coordenadas da face atual
public void setReferences(int face) {
  switch(face) {
  case 2:
    translate(width, 0);
    break;
  case 3: 
    translate(0, height);
    break;
  case 4: 
    translate(width, 0);
    break;
  case 5:
    translate(width, height);
    break;
  case 6: 
    translate(0, height);
    break;
  }
}

//Função para plotar todas as trajetórias daquela tela
private void plotAll() {
  for (int i = 0; i < this.trajectories.size(); i++) { 

    if (this.trajectories.get(i).face == this.face) {

      setReferences(this.trajectories.get(i).face);
      //setCoordenates(this.trajectories.get(i).face);

      this.trajectories.get(i).plot();
    }
  }
}

//Função para mudar de tela
private void changeFace() {
  drawBackground();
  setReferences(this.face);
  trajectories.add(traj);
  traj = new Trajectory(new PVector(0, 0), new PVector(0, 0), 0, 0, this.face);
  plotAll();
}

//Função para apagar trajetória da tela
private void eraserTrajectory() {
  for (int i = (this.trajectories.size())-1; i >= 0; i--) { 
    if (this.trajectories.get(i).face == this.face) {
      this.trajectories.remove(i);
    }
  }
}

private void playFaceSound(int face) {
  switch (face) {
    case(1):
    if (!face1.isPlaying()) {
      face1.loop();
    }
    break;
    case(2):
    if (!face2.isPlaying()) {
      face2.loop();
    }
    break;
    case(3):
    if (!face3.isPlaying()) {
      face3.loop();
    }
    break;
    case(4):
    if (!face4.isPlaying()) {
      face4.loop();
    }
    break;
    case(5):
    if (!face5.isPlaying()) {
      face5.loop();
    }
    case(6):
    if (!face6.isPlaying()) {
      face6.loop();
    }
    break;
  }
}

//Função para rotacionar o cubo entre as faces

void rotateCube(String direction) {

  if (direction != "") {
    face1.stop();
    face2.stop();
    face3.stop();
    face4.stop();
    face5.stop();
    face6.stop();
    switch(direction) {
    case "LEFT":

      rotLEFT.play();
      switch(this.face) {
      case 1:
      case 3:
      case 5:
        this.face = 2;
        break;
      case 2:
        this.face = 6;
        break;
      case 4:
        this.face = 1;
        break;
      case 6:
        this.face = 4;
        break;
      }
      changeFace();
      break;

    case "DOWN":

      rotDOWN.play();
      switch(this.face) {
      case 1:
      case 2:
      case 4:
        this.face = 3;
        break;
      case 3:
        this.face = 6;
        break;
      case 5:
        this.face = 1;
        break;
      case 6:
        this.face = 5;
        break;
      }
      changeFace();
      break;
    }
    this.cubeRotation = "";
  }
}

/**
 * Spherical linear interpolation/extrapolation for PVectors.
 * @param v1 PVector 1.
 * @param v2 PVector 2.
 * @param step percentage of path from v1 to v2.
 * @return PVector between v1 and v2 (if 0<step<1).
 */
PVector slerp(PVector v1, PVector v2, float step) {
  float theta = PVector.angleBetween(v1, v2);
  if (sin(theta)==0) {
    return v1;
  }
  float v1Multiplier = sin((1-step)*theta)/sin(theta);
  float v2Multiplier = sin(step*theta)/sin(theta);
  return PVector.add(PVector.mult(v1, v1Multiplier), PVector.mult(v2, v2Multiplier));
}

void soundSetup() {

  this.face1 = new SoundFile(this, "face1-"+this.soundMode+".wav");
  this.face2 = new SoundFile(this, "face2-"+this.soundMode+".wav");
  this.face3 = new SoundFile(this, "face3-"+this.soundMode+".wav");
  this.face4 = new SoundFile(this, "face4-"+this.soundMode+".wav");
  this.face5 = new SoundFile(this, "face5-"+this.soundMode+".wav");
  this.face6 = new SoundFile(this, "face6-"+this.soundMode+".wav");
  this.rotUP = new SoundFile(this, "rota1-"+this.soundMode+".wav");
  this.rotDOWN = new SoundFile(this, "rota2-"+this.soundMode+".wav");
  this.rotLEFT = new SoundFile(this, "rota3-"+this.soundMode+".wav");
  this.rotRIGHT = new SoundFile(this, "rota4-"+this.soundMode+".wav");
}

void keyPressed() {
  //For change line effect
  if (key == 'q') this.drawMode = 1; // linha
  if (key == 'w') this.drawMode = 2; // esferas
  if (key == 'e') this.drawMode = 3; // quadrados
  if (key == 's') {
    drawBackground();
    if (enableSlerp) {
      enableSlerp=false;
    } else {
      enableSlerp=true;
    }
  } 
  if (key == 'x') {
    drawBackground();
    if (enableInterpolation) {
      enableInterpolation=false;
    } else {
      enableInterpolation=true;
    }
  }
  if (keyCode == LEFT) {
    this.cubeRotation = "LEFT";
  }
  if (keyCode == DOWN) {
    this.cubeRotation = "DOWN";
  }
}

void mouseReleased() {

  wasDrawing = false;

  face1.stop();
  face2.stop();
  face3.stop();
  face4.stop();
  face5.stop();
  face6.stop();
}

void mousePressed() {
  updateMouseData(this.face);
}
