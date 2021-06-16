import java.lang.reflect.*;

class Spawner
{
  private int maxParticle;
  private float probability, //Probabilidade de criar uma particula por segundo
                xMax, yMax, xMin, yMin;
  
  ParticleSystem system;
  
  ArrayList<ParticlePrototype> prototypes;
  
  public Spawner(ParticleSystem receiverSystem, int maxParticle, float probability, float xMin, float xMax, float yMin, float yMax)
  {
    this.system = receiverSystem;
    this.maxParticle = maxParticle;
    this.probability = probability;
    
    this.xMax = xMax;
    this.xMin = xMin;
    this.yMax = yMax;
    this.yMin = yMin; 
    
    prototypes = new ArrayList<ParticlePrototype>();
  }
  
  public void addPrototype(ParticlePrototype prototype)
  {
    prototypes.add(prototype);
  }
  
  public void run(float deltaT)
  {
    if(system.particleCount() >= maxParticle)
    {
      return;
    }
    
    float instantProbability = deltaT*probability; //Probabilidade de criar 1 partícula no instante que passou
    
    
    //Particulas que certamente serão geradas (%>100%)
    int nParticula = int(instantProbability);
    instantProbability -= nParticula;
    
    if(random(1) < instantProbability)  
    {
      nParticula += 1;
    }
    
    for(int i = 0; i<nParticula; i++)
    {
      float x = random(xMin, xMax);
      float y = random(yMin, yMax);
      PVector position = new PVector(x, y);
      
      int index = int(random(0, prototypes.size()));
      
      Particle p = prototypes.get(index).createParticle(position);
      
      system.addParticle(p);
    }
    
  }
}

class Spawner2D
{
  private float[][] probability_map;
  private int max_particle;
  private ArrayList<ParticlePrototype> prototypes;
  private ParticleSystem system;
  
  public Spawner2D(ParticleSystem receiverSystem, float[][] probability_map, int max_particle)
  {
    this.system = receiverSystem;
    this.probability_map = probability_map;
    this.max_particle = max_particle;
    
    prototypes = new ArrayList<ParticlePrototype>();
  }
  
  public void addPrototype(ParticlePrototype prototype)
  {
    prototypes.add(prototype);
  }
  
  
  
  public void run(float deltaT)
  {
    while(system.particleCount() < max_particle)
    {
      int i = int(random(0, probability_map.length));
      int j = int(random(0, probability_map[i].length));
      
      float chance = random(0,100)/100;
      
      if(chance <=probability_map[i][j])
        {
    
          PVector position = new PVector(i, j);
          
          int index = int(random(0, prototypes.size()));
          Particle p = prototypes.get(index).createParticle(position);
          
          if(p != null)
          {
            
            system.addParticle(p);
          }
        }
    }
    
    
    
  }
}


interface ParticlePrototype
{
  public Particle createParticle(PVector position);
}

//Não funciona - Reflexão não funciona direito no Processing
class ParticleCreator implements ParticlePrototype
{
  Class particle_class;
  
  
  public ParticleCreator(Class particle_class)
  {
    this.particle_class = particle_class;
  }
  
  public Particle createParticle(PVector position)
  {
    try //<>// //<>//
    {
    
      Constructor c = particle_class.getDeclaredConstructor(getClass(), PVector.class);
      println("FOI");
      Object particle = c.newInstance(position);
      println("FOI");
      return (Particle) particle;
    }
    catch(NoSuchMethodException e)
    {
      println("Construtor recebendo PVector não existe");
    }
    catch (Exception e)
    {
      //e.printStackTrace();
    }
    //println("ERRO");
    return null;
  }
}
