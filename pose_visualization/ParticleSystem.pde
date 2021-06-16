class ParticleSystem {
  private ArrayList<Particle> particles;

  ParticleSystem() {
    particles = new ArrayList<Particle>();
  }

  public void addParticle(Particle p) {
    particles.add(p);
  }

  public void run(float deltaT) {

    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run(deltaT);
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
   
  public int particleCount()
  {
    return this.particles.size();
  }
  
  public void insertForce(PVector force)
  {
    for(int i = 0; i<particles.size(); i++)
    {
      particles.get(i).insertForce(force);
    }
  }
  
  public void insertField(Field field)
  {
   for(int i = 0; i<particles.size(); i++)
    {
      try
      {
        field.applyField((FieldSensitive) particles.get(i));
      }
      catch(ClassCastException e) {
        println("ParticleSystem: APENAS CLASSES QUE IMPLEMENTAM FieldSensitive PODEM SENTIR CAMPOS");
      }
    }
  }
}
