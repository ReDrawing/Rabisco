class SmallLightning extends Particle implements FieldSensitive
{
   private static final float defaultLifespan = 10;
  
    protected color cor;
    
    SmallLightning(PVector position)
    {
      super(position, new PVector(0,0), SmallLightning.defaultLifespan, 0.01);  
      
      //cor = color(203, 245, 253); //Azul
      //cor = color(226, 108, 255); //Roxo
      cor = color(250, 205, 110);  
  }
  
  
  public void display()
  {
    PVector prevPos = prevPosition.getLast();
    stroke(cor, 100);
    strokeWeight(3);
    line(this.position.x, this.position.y, prevPos.x, prevPos.y);
    
    
    
   // ellipse(position.x, position.y, 100, 100);
  }
  
  public void senseField(PVector field)
  {
    insertForce(field);
  }
}
