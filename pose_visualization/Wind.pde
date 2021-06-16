class Wind
{
  private PVector windForce;
  float accel;
  float velocity;
  float module;
  float maxModule;
  boolean negative;
  
  
  Wind(float maxModule)
  {
    windForce = new PVector(0,0);
    
    this.maxModule = maxModule;
    module = 0;
    velocity = 0;
    negative = false;
  }
  
  private void update(float deltaT)
  {
    if(negative)
    {
      accel = random(-2,0);
    }
    else
    {
      accel = random(0,2);
    }
    
    
    velocity += accel*deltaT;
    module += velocity*deltaT;
    
    if(module > maxModule)
    {
      module = maxModule;
      negative = true;
      velocity = 0;
    }
    else if(module < -maxModule)
    {
      module = -maxModule;
      negative = false;
      velocity = 0;
    }
    
    windForce = new PVector(module,0);
    
  }
  
  public PVector getWindForce(float deltaT)
  {
    update(deltaT);
    
    return windForce;
  }
}
