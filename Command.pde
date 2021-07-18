public abstract class Command
{
    private Object actor;
    private Method method;
    protected Object[] args;

    public Command(Object actor, Method method)
    {
        this.actor = actor;
        this.method = method;
    }

    public void run()
    {
        try
        {
            if(args == null)
            {
                method.invoke(actor);
            }
            else
            {
                method.invoke(actor, args);
            }
        }
        catch (Exception e)
        {
            println("Erro de reflexão ao executar comando");
            e.printStackTrace();
        }
    }

    public abstract void changeArgs(Object obj);
}

public class TriggerCommand extends Command
{
    public TriggerCommand(Object actor, Method method)
    {
      super(actor, method);
      args = null;
        
    }

    public void changeArgs(Object obj)
    {
    }
}

public class PointerCommand extends Command
{
    public PointerCommand(Object actor, Method method)
    {
        super(actor, method);
        
        args = new Object[1];
        args[0] = new PVector();
    }

    public void changeArgs(PVector position)
    {
        args[0] = position;
    }
    
    public void changeArgs(Object object)
    {
      PVector p = (PVector) object;
      changeArgs(p);
    }
}

public class AxisCommand extends Command
{
    public AxisCommand(Object actor, Method method)
    {
        super(actor, method);
        
        args = new Object[1];
        args[0] = 0.0;
    }

    public void changeArgs(float value)
    {
        args[0] = value;
    }
    
    public void changeArgs(Object object)
    {
      float d = (float)object;
      changeArgs(d);
    }
}

public interface InputIdentifier
{

}

public abstract class InputManager
{
    private HashMap<InputIdentifier, ArrayList<Command>> commandMap = new HashMap<InputIdentifier, ArrayList<Command>>();

    public void addCommand(InputIdentifier identifier, Command command)
    {
        ArrayList<Command> list = commandMap.get(identifier);
         
        if(list == null)
        {
          list = new ArrayList<Command>();
        }
        
        list.add(command);
        commandMap.put(identifier, list);
    }

    public void removeCommand(InputIdentifier identifier)
    {
        commandMap.remove(identifier);
    }

    public void clearCommands()
    {
        commandMap.clear();
    }

    public abstract boolean haveInput(InputIdentifier identifier);

    public abstract void run();

    protected void runCommand(InputIdentifier identifier)
    {
        ArrayList<Command> list = commandMap.get(identifier);
        
        if(list == null)
        {
          return;
        }
        
        for(Command command : list)
        {
          if (command != null)
          {
              command.run();
          }
        }
    }

    protected void changeArgs(InputIdentifier identifier, Object arg)
    {
        ArrayList<Command> list = commandMap.get(identifier);
         
        if(list == null)
        {
          return;
        }
        
        for(Command command : list)
        {
          if (command != null)
          {
              command.changeArgs(arg);
          }
        }
    }
}

public enum MouseInputID implements InputIdentifier
{
    LEFT_BUTTON, RIGHT_BUTTON, POINTER,
    LEFT_BUTTON_RELEASE, RIGHT_BUTTON_RELEASE;
    
};

public class MouseInputManager extends InputManager
{
    public void run()
    {
        if(mousePressed && mouseButton == LEFT)
        {
            runCommand(MouseInputID.LEFT_BUTTON);
        }
        if(mousePressed && mouseButton == RIGHT)
        {
            runCommand(MouseInputID.RIGHT_BUTTON);
        }

        PVector position = new PVector(mouseX, mouseY);
        changeArgs(MouseInputID.POINTER, position);
        runCommand(MouseInputID.POINTER);

    }

    public boolean haveInput(InputIdentifier identifier)
    {
        boolean result = false;

        for(MouseInputID mouseInputID : MouseInputID.values())
        {
            if(identifier.equals(mouseInputID))
            {
                result = true;
                break;
            }
        }
        return result;
    }
}

public enum BodyInputID implements InputIdentifier
{
    HEAD, NOSE, 
    EYE_R, EYE_L, EYE_L_INNER, EYE_R_INNER, EYE_L_OUTER, EYE_R_OUTER,
    EAR_R, EAR_L,
    MOUTH_R, MOUTH_L,
    NECK, SHOULDER_R, SHOULDER_L, SPINE_SHOULDER, SPINE_MID, SPINE_BASE,
    ELBOW_R, ELBOW_L,
    WRIST_R, WRIST_L, HAND_R, HAND_L,
    HAND_THUMB_L, HAND_THUMB_R,
    HIP_R, HIP_L, KNEE_R, KNEE_L, ANKLE_R, ANKLE_L, FOOT_L, FOOT_R,
    THUMB_CMC_L, THUMB_MCP_L, THUMB_IP_L, THUMB_TIP_L, INDEX_FINGER_MCP_L, INDEX_FINGER_PIP_L, INDEX_FINGER_DIP_L, INDEX_FINGER_TIP_L, MIDDLE_FINGER_MCP_L, MIDDLE_FINGER_PIP_L, MIDDLE_FINGER_DIP_L, MIDDLE_FINGER_TIP_L, RING_FINGER_MCP_L, RING_FINGER_PIP_L, RING_FINGER_DIP_L, RING_FINGER_TIP_L, PINKY_MCP_L, PINKY_PIP_L, PINKY_DIP_L, PINKY_TIP_L,
    THUMB_CMC_R, THUMB_MCP_R, THUMB_IP_R, THUMB_TIP_R, INDEX_FINGER_MCP_R, INDEX_FINGER_PIP_R, INDEX_FINGER_DIP_R, INDEX_FINGER_TIP_R, MIDDLE_FINGER_MCP_R, MIDDLE_FINGER_PIP_R, MIDDLE_FINGER_DIP_R, MIDDLE_FINGER_TIP_R, RING_FINGER_MCP_R, RING_FINGER_PIP_R, RING_FINGER_DIP_R, RING_FINGER_TIP_R, PINKY_MCP_R, PINKY_PIP_R, PINKY_DIP_R, PINKY_TIP_R,
    FOOT_R_INDEX, FOOT_L_INDEX;
};

public enum GestureInputID implements InputIdentifier
{
    FIVE, FIST, PEACE, ONE, TWO, THREE, FOUR, OK, UNKOWN,
    FIVE_LOADING, FIST_LOADING, PEACE_LOADING, ONE_LOADING, TWO_LOADING, FOUR_LOADING,
    OK_LOADING, UNKOWN_LOADING;
    
    public static GestureInputID valueof(String text)
    {

      for(GestureInputID id : GestureInputID.values())
      {
        if(id.toString().equals(text))
        {
          return (Rabisco.GestureInputID) id;
        }
      }
  
      return GestureInputID.UNKOWN;
    }
};

public class BodyInputManager extends InputManager
{
    private MessageManager msgManager;
    private boolean enableInterpolation;
    private BodyPose previousPose, currentPose;
    private GestureInputID currentGesture;
    private float gesture_timer, previous_gesture_time;
    private float width, height;
    private boolean enableSlerp;

    private static final float GESTURE_TIME = 10000.0;

    public BodyInputManager(MessageManager msgManager, float width, float height)
    {
        this.msgManager = msgManager;

        this.width = width;
        this.height = height;

        gesture_timer = 0.0;
        enableSlerp = false;
    }

    public void run()
    {
        if(msgManager.hasMessage(BodyPose.class))
        {
            BodyPose bodypose = msgManager.getData(BodyPose.class);
            handleBodyPose(bodypose);    
        }

        if(msgManager.hasMessage(Gesture.class))
        {
            Gesture gesture = msgManager.getData(Gesture.class);
            handleGesture(gesture);
        }

    }

    private void handleBodyPose(BodyPose bodyPose)
    {
        estimateKeypointsPosition(bodyPose);

        for(String name : bodyPose.keypoints_names)
        {
            float[] kp = this.currentPose.keypoints.get(name);

            if(kp != null)
            {
                PVector position = new PVector(kp[0], kp[1]);
                changeArgs(BodyInputID.valueOf(name), position);
                runCommand(BodyInputID.valueOf(name));
                
            }
        }

    }

    private void estimateKeypointsPosition(BodyPose newPose) 
    {
        this.previousPose = this.currentPose;
        
        this.currentPose = new BodyPose();
        this.currentPose.time = newPose.time;
        this.currentPose.keypoints_names = newPose.keypoints_names;
        this.currentPose.user_id = newPose.user_id;
        this.currentPose.frame_id = newPose.frame_id;
        this.currentPose.pixel_space = newPose.pixel_space;
        this.currentPose.keypoints = new HashMap<String, float[]>();


        for(String name : newPose.keypoints_names)
        {
            float[] kp = newPose.keypoints.get(name);
            
            if(kp == null || Float.isInfinite(kp[0]))
            {
              continue;
            }
            
            PVector mapped = new PVector((map(kp[0], 0, 100, 1, 0)*width), (map(kp[1], 0, 100, 0, 1)*height));
            

            if(previousPose == null || !enableInterpolation)
            {
                if(kp != null)
                {
                    float[] mapped_float = {mapped.x, mapped.y, 1.0};
                    currentPose.keypoints.put(name, mapped_float);
                } 
            }
            else
            {
                PVector estimate = new PVector();
                if(kp != null)
                {    
                    
                    float[] kp_previous = this.previousPose.keypoints.get(name);
                    
                    if(enableSlerp)
                    {
                        estimate = slerp(new PVector(kp_previous[0], kp_previous[1]), mapped, 0.5);
                    }
                    else 
                    {
                        estimate.x = lerp(kp_previous[0], mapped.x, 0.5);
                        estimate.y = lerp(kp_previous[1], mapped.y, 0.5);
                    }
                }

                float[] estimate_float = {estimate.x, estimate.y, 1.0};

                currentPose.keypoints.put(name, estimate_float); 
            }
        }

    }

    private void handleGesture(Gesture gesture)
    {
      if(gesture == null)
      {
        return;
      }
      else if (gesture.gesture == null)
      {
        return;
      }
      
        if(currentGesture == null || !GestureInputID.valueof(gesture.gesture).equals(currentGesture))
        {
            if(!GestureInputID.valueof(gesture.gesture).equals(currentGesture) && currentGesture != null)
            {
                GestureInputID loadingID = GestureInputID.valueof(currentGesture.toString()+"_LOADING");
                changeArgs(loadingID, 0.0);
                runCommand(loadingID);
            }

            currentGesture = GestureInputID.valueOf(gesture.gesture);
            gesture_timer = 0.0;
        }
        else 
        {
            if(gesture_timer == 0.0)
            {
              previous_gesture_time = millis()-0.1;
            }
            
            gesture_timer += millis() - previous_gesture_time;
            previous_gesture_time = millis();
            
            GestureInputID loadingID = GestureInputID.valueof(currentGesture.toString()+"_LOADING");
            changeArgs(loadingID, gesture_timer/GESTURE_TIME);
            runCommand(loadingID);
        }

        if(gesture_timer>=GESTURE_TIME)
        {
            GestureInputID loadingID = GestureInputID.valueof(currentGesture.toString()+"_LOADING");
            changeArgs(loadingID, gesture_timer/GESTURE_TIME);
            runCommand(loadingID);
            
            runCommand(currentGesture);
            gesture_timer = 0.0;
        }
    }

    public boolean haveInput(InputIdentifier identifier)
    {
        boolean result = false;

        for(BodyInputID bodyInputID : BodyInputID.values())
        {
            if(identifier.equals(bodyInputID))
            {
                result = true;
                break;
            }
        }
        
        if(result == true)
        {
            return result;
        }

        for(GestureInputID gestureInputID : GestureInputID.values())
        {
            if(identifier.equals(gestureInputID))
            {
                result = true;
                break;
            }
        }
        return result;
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
