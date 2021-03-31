import hypermedia.net.*;
import java.util.Arrays;

JSONObject json;
UDP udp;

int[][] keypoints;
String[] keypointsName;

void setup() {
  size(1000,1000);
  udp = new UDP( this, 6000 ); // Trocar pela porta que você usar
  udp.listen( true ); 
  
  keypoints = new int[29][3];
  keypointsName = new String[]{"HEAD"        ,
                              "NOSE"        ,
                              "EYE_R"       ,
                              "EYE_L"       ,
                              "EAR_R"       ,
                              "EAR_L"       ,
                              "NECK"        ,
                              "SHOULDER_R"  ,
                              "SHOULDER_L"  ,
                              "ELBOW_R"      ,
                              "ELBOW_L"      ,
                              "WRIST_R"      ,
                              "WRIST_L"      ,
                              "HAND_R"       ,
                              "HAND_L"       ,
                              "HAND_THUMB_L" ,
                              "HAND_THUMB_R" ,
                              "SPINE_SHOLDER",
                              "SPINE_MID"    ,
                              "SPINE_BASE"   ,
                              "HIP_R"        ,
                              "HIP_L"        ,
                              "KNEE_R"       ,
                              "KNEE_L"       ,
                              "ANKLE_R"      ,
                              "ANKLE_L"      ,
                              "FOOT_L"       ,
                              "FOOT_R"       };
}


void draw() {
  clear();
  
  for(int i = 0; i<29; i++)
  {
    /*print(keypointsName[i]);
    print(":  ");
    for(int j = 0; j<3; j++)
    {
      
      
      print(keypoints[i][j]);
      print(", ");
    }
    
    println();*/
    
    circle(keypoints[i][0], keypoints[i][1], 10); 
    try
    {
    text(keypointsName[i], keypoints[i][0], keypoints[i][1]);
    }
    catch(Exception e)
    {
    }
    
    
  }
  
}

void receive( byte[] data, String ip, int port ) {
  data = subset(data, 0, data.length);
  String message = new String( data );
  json = parseJSONObject(message);
  
  JSONArray keyArray = json.getJSONArray("_BodyPose__keypoints");
  //JSONObject keyNameArray = json.getJSONObject("_BodyPose__keypoint_dict");  
  
  for(int i = 0; i<28; i++)
  {
    JSONArray keypoint = keyArray.getJSONArray(i);
    
   keypoints[i][0] = keypoint.getInt(0);
   keypoints[i][1] = keypoint.getInt(1);
   keypoints[i][2] = keypoint.getInt(2);
   
   //keypointsName[i] = (String) keyNameArray.keys().toArray()[i];
  } 
 
}
