class SeedParticle extends Particle implements FieldSensitive
{
  private static final float mass = 0.0005;
  private static final float initialLifespan = 10;
  private static final int seedR = 33, seedG = 255, seedB = 50;
  
  
  public SeedParticle(PVector position)
  {
    super(position, new PVector(0,0), SeedParticle.initialLifespan, SeedParticle.mass);
    
  }
  
  public void display()
  { 
    stroke(seedR-100, seedG-100, seedB-100,  255);
    fill(seedR, seedG, seedB, 200);
    ellipse(getPosition().x, getPosition().y, 3, 3);
    
    //fill(seedR, seedG, seedB, 128);
    //stroke(seedR, seedG, seedB, 255);  
    //strokeWeight(4);
    //line(getPosition().x, getPosition().y, prevPosition.get(2).x, prevPosition.get(2).y);
  }
  
  public void senseField(PVector field)
  {
    insertForce(field);
  }
}

class SeedParticleCreator implements ParticlePrototype
{
  public Particle createParticle(PVector position)
  {
     return new SeedParticle(position);
  }
  
}
