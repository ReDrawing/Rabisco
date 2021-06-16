class StaticParticle extends Particle implements FieldSensitive
{
  private static final float mass = 0.0005;
  private static final float initialLifespan = 10000000;
  
  
  public StaticParticle(PVector position)
  {
    super(position, new PVector(0,0), StaticParticle.initialLifespan, StaticParticle.mass);
    
  }
  
  public void display()
  { 
    stroke(255-100, 255-100, 255-100,  255);
    fill(255, 255, 255, 200);
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
