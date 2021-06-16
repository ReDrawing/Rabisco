//Based on https://openprocessing.org/sketch/715035
class BlossomFlower extends Particle
{
  private static final float lifespan = 30;
  private static final float mass = 0.005;
  
  private float t, r, c, petalCount, circleCount, maxRad, minRad, frac, rot;
  
  BlossomFlower(PVector position)
  {
    super(position, new PVector(0,0), lifespan, mass);
    
    t = abs(sin(frameCount*0.005));
    r = 150*t + 50;
    c = 4;
    petalCount = 5;
    circleCount = 100;
    maxRad = 68;
    minRad = 0.45*t + 0.1;
    frac = 0.6;
    rot = PI*(1-t);
    
  }
  
  public void display()
  {
    t = abs(sin(frameCount*0.005));
    r = 150*t + 50;
    c = 4;
    petalCount = 7;
    circleCount = 100;
    maxRad = 68;
    minRad = 0.45*t + 0.1;
    frac = 0.6;
    rot = PI*(1-t);
    
    
    float rad = 0;
    noStroke();
  
    pushMatrix();
    translate(position.x, position.y); 
    scale(0.5);
    for (int j = 0; j< petalCount; j++)       
      for (float i = c; i <= circleCount; i = i + 1) {
        float tt = i/circleCount;
        float x  = r*tt*cos( tt*rot + (2*PI*j)/petalCount-PI/2);
        float y  = r*tt*sin( tt*rot + (2*PI*j)/petalCount-PI/2);
  
        if (i < frac*circleCount) 
          rad = map(i, 0, frac*circleCount, minRad, maxRad);
        else 
        rad = map(i, frac*circleCount, circleCount, maxRad, minRad);
        fill(lerpColor(color(255*t, 255, 0, 10), color(50*t + 205, 127*(1-t), 0, 100), i/circleCount));      
        ellipse(x, y, 2*rad, 2*rad);
      }
    popMatrix();
  }
}

class BlossomFlowerCreator implements ParticlePrototype
{
  public Particle createParticle(PVector position)
  {
    return new BlossomFlower(position);
  }
}
