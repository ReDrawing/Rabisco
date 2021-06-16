interface FieldSensitive
{
  public void senseField(PVector field);
  public PVector getPosition();
}

abstract class Field
{
  protected float xMax, yMax, xMin, yMin;
  
  Field(float xMin, float xMax, float yMin, float yMax)
  {
    this.xMax = xMax;
    this.xMin = xMin;
    this.yMax = yMax;
    this.yMin = yMin;
  }
  
  public void applyField(FieldSensitive f)
  {
    PVector position = f.getPosition();
    
    if(position.x <= xMax && position.x >= xMin)
    {
      if(position.y <= yMax && position.y >= yMin)
      {
        PVector fieldVector = getField(position);
        f.senseField(fieldVector);
      }
    }
  }
  
  abstract public void computeField();
  
  abstract protected PVector getField(PVector position);
}

class PerlinNoiseField extends Field
{
  private float inc;
  private float off;
  
  PerlinNoiseField(float xMin, float xMax, float yMin, float yMax)
  {
    super( xMin,  xMax,  yMin,  yMax);
    
    inc = 0.0003;
    off = 0.0;
  }

  public void computeField()
  { 
  }
  
  protected PVector getField(PVector position)
  {
    float angle = noise(position.x, position.y, off) * TWO_PI * 4;
    
    PVector field = PVector.fromAngle(angle);
    
    field.setMag(1);
    
    off += inc;
    
    return field;
  }

}

class RadialField extends Field
{
  PVector center;
  float intensity;
  
  RadialField(PVector center, float intensityCoeficient, float xMin, float xMax, float yMin, float yMax)
  {
    super( xMin,  xMax,  yMin,  yMax);
    
    intensity = intensityCoeficient;
    this.center = center;
  }
  
  public void computeField()
  { 
  }
  
  protected PVector getField(PVector position)
  {
    PVector localField = center.copy().sub(position);
    
    localField.setMag(1);
    
    localField.mult(intensity);
    
    return localField;
  }
}
