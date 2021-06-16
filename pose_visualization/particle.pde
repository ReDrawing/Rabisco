import java.util.LinkedList;

abstract class Particle {
  protected PVector position;
  protected LinkedList<PVector> prevPosition;
  private PVector velocity;
  private PVector acceleration;
  protected float lifespan;
  private PVector force;
  protected float mass;
  private float velLimit;
  private boolean limitReg;
  private float xMax, yMax, xMin, yMin;


  public Particle(PVector position, PVector velocity, float lifespan, float mass) {
    this.velocity = velocity.copy();
    this.position = position.copy();
    
    prevPosition = new LinkedList<PVector>();
    
    for(int i = 0; i<5; i++)
    {
      prevPosition.add(position.copy());
    }
     
    this.lifespan = lifespan;
    this.mass = mass;
    
    this.force = new PVector(0,0);
    velLimit = 0;
    limitReg = false;
  }

  public void run(float deltaT) {
    update(deltaT);
    display();
  }
  
  public void insertForce(PVector force)
  {
    this.force.add(force);
  }

  // Method to update position
  private void update(float deltaT) 
  {
    this.acceleration = new PVector(0,0);
    
    
    acceleration.add(force.div(mass));
    
    prevPosition.removeLast();
    prevPosition.addFirst(position.copy());
    
    velocity.add(acceleration.mult(deltaT));
    
    if(velLimit != 0)
    {
      velocity.limit(velLimit);
    }
    
    position.add(velocity.mult(deltaT));
    
    if(limitReg)
    {
      if(position.x > xMax)
      {
        position.x = xMax;
        this.lifespan = -1;
      }
      else if (position.x < xMin)
      {
        position.x = xMin;
        this.lifespan = -1;
      }
      
      if(position.y > yMax)
      {
        position.y = yMax;
        this.lifespan = -1;
      }
      else if(position.y < yMin)
      {
        position.y = yMin;
        this.lifespan = -1;
      }
    }
    
    
    lifespan -= deltaT;
    
    this.force = new PVector(0,0);
  }

  public void limitVel(float velLimit)
  {
    this.velLimit = velLimit;
  }

  // Method to display
  protected abstract void display();

  // Is the particle still useful?
  public boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
  
  public PVector getPosition()
  {
    return this.position.copy();
  }
  
  public void limitRegion(float xMin, float xMax, float yMin, float yMax)
  {
    limitReg = true;
    
    this.xMax = xMax;
    this.xMin = xMin;
    this.yMax = yMax;
    this.yMin = yMin;
  }
}
