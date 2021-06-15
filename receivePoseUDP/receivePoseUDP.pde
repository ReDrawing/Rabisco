import hypermedia.net.*;
import java.util.Set;

JSONObject json;
UDP udp;

float[][] keypoints;
String[] keypointsName;

void setup() {
  size(1000,1000);
  udp = new UDP( this, 6000 ); // Trocar pela porta que você usar
  udp.listen( true ); 
  
  keypoints = new float[0][3];
  keypointsName = new String[0];
}


void draw() {
  clear();
  
  for(int i = 0; i<keypoints.length ; i++)
  {
    try
    {
      circle(keypoints[i][0], keypoints[i][1], 10); 
    
      //println(keypointsName[i], keypoints[i][0], keypoints[i][1]);
    
      text(keypointsName[i], keypoints[i][0], keypoints[i][1]);
    }
    catch (NullPointerException e) {}
    catch (ArrayIndexOutOfBoundsException e){}
  }
  
}

void receive( byte[] data, String ip, int port ) {
  data = subset(data, 0, data.length);
  String message = new String( data );
  json = parseJSONObject(message);
  
  String frame_id = json.getString("_frame_id");

  if(frame_id.contains("neck") == false)
  {
    return;
  }
  
  JSONObject keypointsDict = json.getJSONObject("_keypoints");
  
  
  Set<String> keypointDictNames = keypointsDict.keys();
  
  keypointsName = new String[keypointDictNames.size()];
  keypoints = new float[keypointDictNames.size()][3];
  
  int index = 0;
    
  for(String name : keypointDictNames)
  {
   if(keypointsDict.isNull(name))
   {
     continue;
   }
   
   JSONArray keypointArray = keypointsDict.getJSONArray(name);
   
   
   keypoints[index][0] = keypointArray.getInt(0)+500;
   keypoints[index][1] = keypointArray.getInt(1)+500;
   keypoints[index][2] = keypointArray.getInt(2);
   
   keypointsName[index] = name;
    
   
   index += 1;
  } 
 
}
