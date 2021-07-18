public abstract class Entity
{
  protected PVector position;
  protected float[] orientation;
  protected boolean hidden;

  public Entity(PVector position, float[] orientation)
  {
    this.position = position;
    this.orientation = orientation;
    this.hidden = false;
  }

  public Entity(PVector position)
  {
    this.position = position;

    this.orientation = new float[3];
    this.orientation[0] = 0;
    this.orientation[1] = 0;
    this.orientation[2] = 0;

    this.hidden = false;
  }


  public void hide()
  {
    this.hidden = true;
  }

  public void show()
  {
    this.hidden = false;
  }

  public abstract void run(PGraphics canvas);
}

// RABISCO -------------------------------------------------------

public enum StokeType
{
  LINE_STROKE, CIRCLE_STROKE, SQUARE_STROKE;
}

public class Face extends Entity
{
  private StokeType stokeType;
  private PVector pointerPosition, prevPointerPosition;
  private float quadrant1, quadrant2, quadrant3, quadrant4;
  private boolean pointerChanged;

  public Face(PVector position)
  {
    super(position);
    this.stokeType = StokeType.LINE_STROKE;
    pointerChanged = false;
  }

  public void setColor(float quadrant1, float quadrant2, float quadrant3, float quadrant4)
  {
    this.quadrant1 = quadrant1;
    this.quadrant2 = quadrant2;
    this.quadrant3 = quadrant3;
    this.quadrant4 = quadrant4;
  }

  public void setPointer(PVector position)
  {

    this.prevPointerPosition = this.pointerPosition;
    this.pointerPosition = position.copy();

    pointerChanged = true;
  }

  public void run(PGraphics canvas)
  {
    if (this.hidden || this.pointerPosition == null || this.prevPointerPosition == null || !pointerChanged)
    {
      return;
    }


    float firstSpeed = pointerPosition.dist(prevPointerPosition);
    float lineWidth = map(firstSpeed, 5, 50, 2, 20);
    lineWidth = constrain(lineWidth, 0, 100);
    
    

    canvas.noStroke();
    canvas.fill(0, 100);
    canvas.strokeCap(ROUND);
    canvas.strokeWeight(lineWidth);

    canvas.colorMode(HSB, 360, 100, 100);

    float quadrantColor;

    if (this.pointerPosition.x > canvas.width)
    {
      if (this.pointerPosition.y > canvas.height)
      {
        quadrantColor = this.quadrant4;
      } else 
      {
        quadrantColor = this.quadrant1;
      }
    } else 
    {
      if (this.pointerPosition.y > canvas.height)
      {
        quadrantColor = this.quadrant3;
      } else
      {
        quadrantColor = this.quadrant2;
      }
    }

    canvas.stroke(quadrantColor, int(random(80, 100)), 100);

    PVector prevPosition = this.prevPointerPosition.copy().add(position), 
      currPosition = this.pointerPosition.copy().add(position);

    switch(stokeType)
    {
    case LINE_STROKE:
      canvas.line(prevPosition.x, prevPosition.y, currPosition.x, currPosition.y);
      break;
    case CIRCLE_STROKE:
      canvas.point(currPosition.x, currPosition.y);
      break;
    case SQUARE_STROKE:
      canvas.rect(currPosition.x, currPosition.y, random(80), random(80));
      break;
    }
  }
}

public class Cube extends Entity
{
  private Face[] faces;
  PGraphics facesCanva[];
  private int currentFace;
  private int faceSize;

  public Cube(PVector position, boolean threeDimensional, int faceSize)
  {
    super(position);

    float radius = 0;
    if (threeDimensional)
    {
      radius = 100;
    }

    this.faces = new Face[6];
    this.faces[0] = new Face(position.copy().add(radius, 0, 0));
    this.faces[1] = new Face(position.copy().add(0, radius, 0));
    this.faces[2] = new Face(position.copy().add(0, 0, radius));
    this.faces[3] = new Face(position.copy().add(-radius, 0, 0));
    this.faces[4] = new Face(position.copy().add(0, -radius, 0));
    this.faces[5] = new Face(position.copy().add(0, 0, -radius));

    this.currentFace = 0;

    //@todo alterar depois
    for (Face face : faces)
    {
      face.setColor(100, 100, 100, 100);
    }

    this.faceSize = faceSize;

    facesCanva = new PGraphics[6];
    for (int i = 0; i < 6; i++)
    {
      facesCanva[i] = createGraphics(faceSize, faceSize);
    }
  }

  /**
   @todo alterar para modificar a orientação
   */
  public void rotateLeft()
  {
    switch(currentFace)
    {
    case 0:
      currentFace = 1;
      break;
    case 1:
      currentFace = 3;
      break;
    case 2:
      currentFace = 0;
      break;
    case 3:
      currentFace = 4;
      break;
    case 4:
      currentFace = 0;
      break;
    case 5:
      currentFace = 3;
      break;
    }
    
  }

  /**
   @todo alterar para modificar a orientação
   */
  public void rotateRight()
  {
    switch(currentFace)
    {
    case 0:
      currentFace = 2;
      break;
    case 1:
      currentFace = 2;
      break;
    case 2:
      currentFace = 3;
      break;
    case 3:
      currentFace = 5;
      break;
    case 4:
      currentFace = 2;
      break;
    case 5:
      currentFace = 0;
      break;
    }
  }

  public void setPointer(PVector pointerPosition)
  {
    this.faces[currentFace].setPointer(pointerPosition);
  }

  public void run(PGraphics canvas)
  {
    if (this.hidden)
    {
      return;
    }

    for(int i = 0; i<6; i++)
    {
      facesCanva[i].beginDraw();
      faces[i].run(facesCanva[i]);
      facesCanva[i].endDraw();
    }

    canvas.image(facesCanva[currentFace], 0, 0);
  }
}

public class GestureIcon extends Entity
{
  private float percentage;
  PImage iconImage;

  public GestureIcon(PVector position, String file)
  {
    super(position);

    this.percentage = 0.0;

    iconImage = loadImage(file);
    iconImage.resize(150, 150);
  }

  public void setLoading(float percentage)
  {
    this.percentage = percentage;  
  }

  /**
   @todo @TODO conferir se os ângulos e posições estão corretos
   */
  public void run(PGraphics canvas)
  {
    if (this.hidden || this.percentage == 0.0)
    {
      return;
    }


    canvas.noStroke();


    canvas.fill(235, 100, 100);
    //canvas.arc(this.position.x+75, this.position.y+75, this.position.x, this.position.y, PI + PI/2, PI + PI/2 + this.percentage*2*PI);
    arc(width-95, 95, 160, 160, PI + PI/2, PI + PI/2 + this.percentage*2*PI, PIE);
    
    canvas.fill(0, 0, 100);
    ellipse(width-95, 95, 150, 150);
    //ellipse(this.position.x+25, this.position.y+25, -this.position.x+25, -this.position.y+25);
    
    canvas.image(iconImage, this.position.x, this.position.y);
  }
}
