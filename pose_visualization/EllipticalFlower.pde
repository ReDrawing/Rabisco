class EllipticalFlower extends Particle
{
  private static final int defaultLifespan = 10;
  private static final float defaultMass = 1;
  private static final int points = 20;
  private static final int weight = 1;
  
  private final int colorScheme[][] = {{21,132,103}, {25,113,99}, {6,84,70}, {234,123,152}, {0,128,128}};
  
  EllipticalFlower(PVector position)
  {
    super(position, new PVector(0,0),  defaultLifespan,  defaultMass);
  }
  
  public void display()
  {
    ellipseMode(CORNER);
    
    
    pushMatrix();
    
    
    translate(position.x, position.y);
    
    for(int i = 0; i< points; i++)
    {
      int index = int(random(0,5));
      
      stroke(colorScheme[index][0],colorScheme[index][1],colorScheme[index][2]);
      
      float lineAngle = random(0, 2*PI);
      rotate(lineAngle);
      noFill();
      strokeWeight(weight);
      
      for(int j = 0; j<random(1,90); j++)
      {
        ellipse(points-i, points-i, j*i*.11, j*i*.3);
      }
    }
    
    popMatrix();
    ellipseMode(CENTER);
  }
}

class EllipticalFlowerCreator implements ParticlePrototype
{
  public Particle createParticle(PVector position)
  {
    return new EllipticalFlower(position);
  }
}
