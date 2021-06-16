void drawGrid()
{
  //Eixos
  stroke(255,0,0);
  line(0,0,0,100,0,0);
  stroke(0,255,0);
  line(0,0,0,0,100,0);
  stroke(0,0,255);
  line(0,0,0,0,0,100);
  
  int n = 10;
  
  float x_lim = 1250;
  float z_lim = n*500;
  
  float y = 500;
  
  stroke(255,255,255);
  for(int i = 0; i<n; i++)
  {
    line(-x_lim,y,i*500,x_lim,y,i*500);
  }
  
  int n_x = int(2*x_lim/500);
  
  for(int i = 0; i<n_x; i++)
  {
    float x = -x_lim+(i*500);
    
    line(x,y,0,x,y,z_lim);
  }
}
