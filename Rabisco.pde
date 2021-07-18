import hypermedia.net.*;
import br.campinas.redrawing.MessageManager;
import br.campinas.redrawing.data.BodyPose;
import br.campinas.redrawing.data.BodyVel;
import br.campinas.redrawing.data.Gesture;
import processing.sound.*;
import java.lang.reflect.*;

public enum RabiscoState
{
  DRAW, EDIT;
}

public class RabiscoMain
{
  private Cube cubo;
  private InputManager inputManager;
  
  private GestureIcon fistIcon;

  public RabiscoMain(InputManager inputManager)
  {
    this.inputManager = inputManager;
    this.cubo = new Cube(new PVector(), false, width);
    
    fistIcon = new GestureIcon(new PVector(width-170, 20), "fist.png");

    configDraw();
  }

  public void configDraw()
  {
    Method pointerMethod = null;

    Method rLeftMethod = null;
    Method fistLoadingMethod = null;


    
    try
    {
      pointerMethod = cubo.getClass().getMethod("setPointer", PVector.class);
      rLeftMethod = cubo.getClass().getMethod("rotateLeft");
      fistLoadingMethod = fistIcon.getClass().getMethod("setLoading", Float.TYPE);
    }
    catch(Exception e)
    {
      println("ERRO");
    }
    
    PointerCommand pointerCommand = new PointerCommand(cubo, pointerMethod);
    TriggerCommand fiveCommand = new TriggerCommand(cubo, rLeftMethod);
    AxisCommand fiveLoading = new AxisCommand(fistIcon, fistLoadingMethod);

    if (inputManager.haveInput(BodyInputID.WRIST_L))
    {
      inputManager.addCommand(BodyInputID.WRIST_L, pointerCommand);
    } else if (inputManager.haveInput(MouseInputID.POINTER))
    {
      inputManager.addCommand(MouseInputID.POINTER, pointerCommand);
    }
    
    if(inputManager.haveInput(GestureInputID.FIVE))
    {
      inputManager.addCommand(GestureInputID.FIVE, fiveCommand);
      inputManager.addCommand(GestureInputID.FIVE_LOADING, fiveLoading);
    }
  }

  public void run()
  {
    background(255,255,255);
    cubo.run(g);
    fistIcon.run(g);
  }
}


MessageManager msgManager;
UDP udp;
BodyInputManager bodyInputManager;
RabiscoMain rabisco;

void setup()
{
  msgManager = new MessageManager(5, true);

  udp = new UDP(this, 6000);
  udp.listen(true); 

  bodyInputManager = new BodyInputManager(msgManager, width, height);

  rabisco = new RabiscoMain(bodyInputManager);

  fullScreen();
}

void draw()
{
  clear();
  bodyInputManager.run();
  rabisco.run();
}

void receive(byte[] data, String ip, int port)
{
  data = subset(data, 0, data.length);
  String message = new String( data );
  

  msgManager.insertMessage(message);
} 
