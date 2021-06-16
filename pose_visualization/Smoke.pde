class Smoke extends Particle implements FieldSensitive
{
  public static final float defaultLifespan = 10000;
  public static final float defaultAlpha = 5;
  
  protected color cor;
  protected float alpha;
  
  
  Smoke(PVector position)
  {
    super(position, new PVector(0,0), Smoke.defaultLifespan, 0.0001);  
    
    cor = 0;
    alpha = defaultAlpha;
  }
  
  Smoke(PVector position, float lifeSpan)
  {
    super(position, new PVector(0,0), lifeSpan, 0.0001);  
    
    cor = 0;
    alpha = defaultAlpha;
  }
  
  Smoke(PVector position, float lifeSpan, float alpha)
  {
    super(position, new PVector(0,0), lifeSpan, 0.0001);  
    
    cor = 0;
    this.alpha = alpha;
  }
  
  public void display()
  {
    PVector prevPos = prevPosition.getLast();
    stroke(cor, alpha);
    strokeWeight(1);
    line(this.position.x, this.position.y, prevPos.x, prevPos.y);
    
   // ellipse(position.x, position.y, 100, 100);
  }
  
  public void senseField(PVector field)
  {
    insertForce(field);
  }
  
  public void setColor(color cor)
  {
    this.cor = cor;
  }
}

class SmokeCreator implements ParticlePrototype
{
  public color cor = 0;
  
  public Particle createParticle(PVector position)
  {
    Smoke p = new Smoke(position);
    p.setColor(cor);
    return p;
  }
}
