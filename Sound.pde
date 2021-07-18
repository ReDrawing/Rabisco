public class SoundService
{
  private HashMap<String, SoundFile> soundFileMap;
  private HashMap<SoundID, SoundFile> soundIDMap;
  private PApplet pApplet;

  public SoundService(PApplet pApplet)
  {
    soundFileMap = new HashMap<String, SoundFile>();
    soundIDMap = new HashMap<SoundID, SoundFile>();
    this.pApplet = pApplet;
  }

  public void load(String file)
  {
    SoundFile soundFile = new SoundFile(pApplet, file);
    soundFileMap.put(file, soundFile);
  }

  public void defineID(SoundID id, String file)
  {
    SoundFile soundFile = soundFileMap.get(file);
    soundIDMap.put(id, soundFile);
  }

  public void play(SoundID id)
  {
    SoundFile soundFile = soundIDMap.get(id);
    soundFile.play();
  }

  public void play(String file)
  {
    SoundFile soundFile = soundFileMap.get(file);
    soundFile.play();
  }

  public void stop(SoundID id)
  {
    SoundFile soundFile = soundIDMap.get(id);
    soundFile.stop();
  }

  public void stop(String file)
  {
    SoundFile soundFile = soundFileMap.get(file);
    soundFile.stop();
  }

  public void loop(SoundID id)
  {
    SoundFile soundFile = soundIDMap.get(id);
    soundFile.loop();
  }

  public void loop(String file)
  {
    SoundFile soundFile = soundFileMap.get(file);
    soundFile.loop();
  }

  public void stopAll()
  {
    for (SoundFile soundFile : soundFileMap.values())
    {
      soundFile.stop();
    }
  }
}

public interface SoundID
{
}

// RABISCO -------------------------------------------------------

public enum RabiscoSoundID implements SoundID
{
  //FACE 1 TO 6
  FACE1, FACE2, FACE3, FACE4, FACE5, FACE6, ROT_UP, ROT_DOWN, ROT_LEFT, ROT_RIGHT;
}
