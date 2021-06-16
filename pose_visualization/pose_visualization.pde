/*
Basic test of the library
Run with "python -m redrawing.test_client".

Receives the test bodyPose, and draw it in the screen.

*/

import br.campinas.redrawing.MessageManager;
import br.campinas.redrawing.data.BodyPose;
import br.campinas.redrawing.data.Gesture;

import hypermedia.net.*; 
import peasy.*;

//Creates the message manager, setting the message queue size of 5 (per data type) and true for deleting old messages 
MessageManager msgManager = new MessageManager(5, true);

//Uses the UDP Processing library to receive messages
UDP udp;

PeasyCam cam;

Skeleton skeleton;
ParticleSystem system;

PGraphics skeleton_canvas; 

void setup()
{
  size(1000,1000,P3D);
  udp = new UDP(this, 6000); //Default ReDrawing port
  udp.listen(true);
  
  cam = new PeasyCam(this, 0,0,0, 500);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(5000);
  
  skeleton_canvas = createGraphics(500,500); 
  
  skeleton = new Skeleton(skeleton_canvas, false);
  system = new ParticleSystem();
  
  for(int i = 0; i<100; i++)
  {
    for(int j = 0; j<100; j++)
    {
      Particle p = new StaticParticle(new PVector((i*10)-500, j*10));
      system.addParticle(p);
    }
  }
  
}

void draw()
{
  clear();
  
  lights();
  
  skeleton_canvas.beginDraw();
  
  
  float deltaT = 1.0/frameRate;
  
  if(msgManager.hasMessage(BodyPose.class))
  {
    skeleton.reset();
    BodyPose bodypose = msgManager.getData(BodyPose.class);
    //float time = bodypose.time;
      
    for(String name : skeleton.names)
    {
      float[] kp = bodypose.keypoints.get(name);
        
      if(Float.isInfinite(kp[0]))
      {
        continue;
      }
      
      
      skeleton.setKeypoint(name, kp);
       
      if(name.compareToIgnoreCase("WRIST_R") == 0 || name.compareToIgnoreCase("WRIST_L") == 0)
      {
        //(PVector center, float intensityCoeficient, float xMin, float xMax, float yMin, float yMax)
        RadialField f = new RadialField(new PVector(kp[0],kp[1]), 1,  0, 1000, 0, 1000);
        system.insertField(f);
      }
      
    }
    
  }
  
  skeleton.show();
  //system.run(deltaT);
  

  drawGrid();
  
  skeleton_canvas.endDraw();
  //image(skeleton_canvas.get(0,0,1000,1000),-500,0);
  image(skeleton_canvas.copy(),-500,0,1000,1000);
}

//Receive the message and give it to the manager
void receive(byte[] data, String ip, int port)
{
  data = subset(data, 0, data.length);
  String message = new String( data );
  msgManager.insertMessage(message);
}
