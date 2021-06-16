class Skeleton
{
  private PVector positions[];
  private boolean keypoint_3d;
  private PGraphics canvas;
  private boolean color_lines;
  private boolean circle;
  
  
  //                                0       1         2      3          4          5             6         7         8        9         10       11       12        13           14        15      16
  private final String names[] = {"NOSE", "EYE_R","EYE_L", "NECK", "SHOULDER_R","SHOULDER_L","ELBOW_R","ELBOW_L","WRIST_R","WRIST_L", "HIP_R", "HIP_L", "KNEE_R", "ANKLE_R", "KNEE_L", "ANKLE_L", "SPINE_SHOULDER"};
  
  private final int[][] pairs = {{0,1}, {0,2}, {0,3}, {3,4}, {3,5}, {4,6}, {5,7}, {6,8}, {7,9}, {4,10}, {5,11}, {10,11}, {10,12}, {12,13}, {11,14}, {14,15}, {0,16}, {16,4}, {16,5}};
  private final int[] side    = {   -1,     1,     0,    -1,     1,    -1,    1,     -1,     1,     -1,      1,       0,      -1,     -1,        1,       1,     0,    -1,     1};
  //1 = left, -1 = right
  
  private final int[][] shapes = {{4,16,5,11,10}, {0,1,2}};
  
  private final int n_kp = 17;
  
  public Skeleton(PGraphics canvas, boolean keypoint_3d)
  {
    positions = new PVector[n_kp];
    this.canvas = canvas;
    this.keypoint_3d = keypoint_3d;
    
    this.color_lines = false;
    this.circle = false;
  }
  
  public void setColorLines(boolean color_lines)
  {
    this.color_lines = color_lines;
  }
  
  public void setCircle(boolean circle)
  {
    this.circle = circle;
  }
  
  public void reset()
  {
    positions = new PVector[n_kp];
  }
  
  public void setKeypoint(String name, float[] position)
  {
    for(int i = 0; i<n_kp; i++)
    {
      
      if(names[i].compareToIgnoreCase(name) == 0)
      {
        positions[i] = new PVector(position[0],position[1], position[2]);
      }
      
   
    }
  }
  
  private void complete_kp()
  {
    //Se não tem nem NECK nem SHOULDER_SPINE, mas tem os SHOULDERS, 
    //definir SHOULDER_SPINE como a média dos SHOULDERS
    if(positions[3] == null && positions[16] == null)
    {
      if(positions[4] != null && positions[5] != null)
      {
        PVector spine_shoulder = new PVector();
        spine_shoulder.add(positions[4]);
        spine_shoulder.add(positions[5]);
        
        spine_shoulder.div(2);
        
        positions[16] = spine_shoulder;
      }
      
    }
    
    //Se NECK, mas não SHOULDER_SPINE, definer SHOULDER_SPINE = NECK
    
    if(positions[3] != null && positions[16] == null)
    {
      positions[16] = positions[3];
    }
  }
  
  private PVector mean_kp()
  {
    PVector mean = new PVector();
    int n = 0;
    for(PVector position : positions)
    {
      if(position != null)
      {
        mean.add(position);
        n += 1;
      }
    }
    
    mean.div(n);
    
    return mean;
  }
  
  private void process_kp()
  {
    complete_kp();
    PVector mean = mean_kp();
    
    PVector translation = mean.sub(250,250,0);
    
    for(PVector position : positions)
    {
      if(position != null)
      {
        position.sub(translation);
      }
      
    }
  }
  
  public void show()
  {
    pushStyle();
    canvas.clear();
    
    process_kp();
    
    for(int i = 0; i<pairs.length; i++)
    {
      if(positions[pairs[i][0]] != null && positions[pairs[i][1]] != null)
      {
        if(color_lines)
        {
          if(side[i] == -1)
          {
            canvas.stroke(0,255,0);
          }
          else if (side[i] == 1)
          {
            canvas.stroke(255,0,0);
          }
          else
          {
            canvas.stroke(255,255,0);
          }
        }
        else
        {
          canvas.stroke(255,255,255);
        }
        
        canvas.strokeWeight(10);
        //line(positions[pairs[i][0]].x, positions[pairs[i][0]].y, positions[pairs[i][0]].z, positions[pairs[i][1]].x, positions[pairs[i][1]].y, positions[pairs[i][1]].z);
        canvas.line(positions[pairs[i][0]].x, positions[pairs[i][0]].y, positions[pairs[i][1]].x, positions[pairs[i][1]].y);
      }
    }
    
    canvas.fill(255,255,255);
    for(int[] shape : shapes)
    {
      boolean have_kp = true;
      
      for(int i : shape)
      {
        if(positions[i] == null)
        {
          have_kp = false;
          
          break;
        }
      }
      
      if(!have_kp)
      {
        continue;
      }
      
      PShape s = canvas.createShape();
      s.beginShape();
      for(int i : shape)
      {
        s.vertex(positions[i].x, positions[i].y); 
      }
      s.endShape(CLOSE);
      
      canvas.shape(s,0,0);
    }
    
    
    if(circle)
    {
      strokeWeight(1);
      for(int i = 0; i<positions.length; i++)
      {
        if(positions[i] != null)
        {
          canvas.pushMatrix();
          canvas.translate(positions[i].x, positions[i].y);
          color(255, 255, 255);
          canvas.fill(255,255,255);
          canvas.stroke(255,255,255);
          canvas.circle(0,0,10);
          canvas.popMatrix();
        }
      }
    }
    
    
    popStyle();
  }
  
}
