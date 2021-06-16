class WaterDrop extends Particle
{
  private static final float mass = 0.0005;
  private static final float initialLifespan = 2;
  private static final int waterR = 212, waterG = 241, waterB = 249;
  
  
  public WaterDrop(PVector position)
  {
    super(position, new PVector(0,0), WaterDrop.initialLifespan, WaterDrop.mass);
    
  }
  
  public void display()
  { 
    stroke(waterR-100, waterG-100, waterB-100,  255);
    fill(waterR, waterG, waterB, 200);
    ellipse(getPosition().x, getPosition().y, 5, 5);
    
    fill(waterR, waterG, waterB, 128);
    stroke(waterR, waterG, waterB, 255);  
    strokeWeight(4);
    line(getPosition().x, getPosition().y, prevPosition.get(2).x, prevPosition.get(2).y);
  }
}

class WaterDropCreator implements ParticlePrototype
{
  public Particle createParticle(PVector position)
  {
     return new WaterDrop(position);
  }
  
}
