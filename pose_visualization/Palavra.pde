class WordType implements ParticlePrototype
{
  private String texto;
  private float lifespan;
  private float mass;
  private color cor;
  private int size;
  private PFont font;
  
  public WordType(String texto, color cor, int size, float lifespan, float mass)
  {
    this.texto = texto;
    this.lifespan = lifespan;
    this.mass = mass;
    this.cor = cor;
    this.size = size;
  }
  
  public void setFont(PFont font)
  {
    this.font = font;
  }
  
  public void display(PVector position)
  {
    if(font != null)
    {
      textFont(font);
    }
    
    textAlign(CENTER);
    fill(cor);
    textSize(size);
    text(texto, position.x, position.y);
  }
  
  
  public Word createParticle(PVector position)
  {
    return new Word(this, position, lifespan, mass);
  }
}

class Word extends Particle implements FieldSensitive
{
  private WordType tipo;
  
  
  public Word(WordType tipo, PVector position, float lifespan, float mass)
  {
    super(position, new PVector(0,0), lifespan, mass);
    
    this.tipo = tipo;
  }
  
  public void display()
  {
    tipo.display(position);
  }
  
  public void senseField(PVector field)
  {
    //field.mult(mass);
    insertForce(field);
  }
  
}
