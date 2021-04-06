import hypermedia.net.*;
import java.util.Set;

JSONObject json;
UDP udp;

double[] orientationQuat;
double[] orientationAngle;


void setup() {
  size(500,500, P3D);
  udp = new UDP( this, 6000 ); // Trocar pela porta que você usar
  udp.listen( true ); 
  
  orientationQuat = new double[4];
  orientationAngle = new double[3];
}

void draw()
{
  println(orientationAngle[0], orientationAngle[1], orientationAngle[2]);
  
  clear();
  
  translate(250,250,0);
  rotateX((float)orientationAngle[0]);
  rotateZ((float)orientationAngle[1]);
  rotateY((float)orientationAngle[2]);
  
  box(100);
  
}

void receive( byte[] data, String ip, int port )
{
  data = subset(data, 0, data.length);
  String message = new String( data );
  json = parseJSONObject(message);
  
  JSONArray quatArray = json.getJSONArray("_orientation");
  
  orientationQuat[0] = quatArray.getDouble(0);
  orientationQuat[1] = quatArray.getDouble(1);
  orientationQuat[2] = quatArray.getDouble(2);
  orientationQuat[3] = quatArray.getDouble(3);

  orientationAngle = computeAngle();
}

double[] computeAngle()
{
        double q0 = orientationQuat[3];
        double q1 = orientationQuat[0];
        double q2 = orientationQuat[1];
        double q3 = orientationQuat[2];
        
        double[] angle = new double[3];

        angle[0] = Math.atan2(2*((q0*q1)+(q2*q3)) , 1-2*(Math.pow(q1,2)+Math.pow(q2,2)  )  );
        angle[1] = Math.asin(2*((q0*q2) - (q3*q1)) );
        angle[2] = Math.atan2(2*((q0*q3)+(q1*q2)) , 1-2*(Math.pow(q2,2)+Math.pow(q3,2)  )  );
        
        return angle;
}
