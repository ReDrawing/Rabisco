


public class ParticleSystem{
  
  private color endColor = color(100,100,100,HSB);
   private color startColor= color(100,100,100,HSB);
  private float saturation = 0;

  private ArrayList<Particle> particles = new ArrayList<Particle>();
  
  public void update(){
    Iterator<Particle> i = particles.iterator();

    while (i.hasNext()) {
      Particle p = i.next();
      
      // Remove any particles outside of the screen
      if (p.pos.x > width /*|| p.pos.x < 0*/) {
        i.remove();
        continue;
      } else if (p.pos.y > height /*|| p.pos.y < 0*/) {
        i.remove();
        continue;
      }
      
      // Apply gravity
      p.applyForce(PVector.random2D());
      
      // Move particle position
      p.move();
      
      // Remove dead particles
      if (p.isDead()) {
        i.remove();  
      } else {
        p.display();
      }
      
    }
  }
  public void addParticles(PVector position,int id) {
  //int cor = int(random(8));
  
  
  this.startColor = choseColor(id);
  
  //cor = int(random(8));
  this.endColor = choseColor(id+10);
  
  
  
      for (int i = 0; i < numberOfParticles; i++) {
      
        float amount = random(1);
        color col = lerpColor(this.startColor, this.endColor, amount);
        col = color(hue(col),this.saturation,100);
        //col = desaturate(col, this.saturation);
        this.particles.add(new Particle(new PVector(position.x,position.y), col));
        //println("HUE1",hue(col));
  //println("SAT1",saturation(col));
  //println("BRI1",brightness(col));
      }
    }
    
  public color choseColor(int id){
    
    color cor = color(0,0,0,HSB);
    switch(id){
    case 1:
      cor = blue1;
      break;
    case 11:
      cor = purple1;
      break;
   case 2:
      cor = orange;
      break;
   case 12:
      cor = red1;
      break;
   case 3:
      cor = yellow;
      break;
   case 13:
      cor = green;
      break;
   case 4:
      cor = blue2;
      break;
   case 14:
      cor = purple2;
      break;
   case 5:
      cor = blu1;
      break;
   case 15:
      cor = blu2;
      break;
   case 6:
      cor = red1;
      break;
   case 16:
      cor = red2;
      break;
  }
    return cor;
    
  }
  
  public color desaturate(color col, float factor) {
  float sat = saturation(col) * factor;
  return color(
    hue(col),
    sat,
    brightness(col)
  );
  }
  
  }
