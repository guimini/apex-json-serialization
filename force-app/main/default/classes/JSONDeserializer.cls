global with sharing class JSONDeserializer {
  private JSONDeserializer() {
  }
  global static Object deserialize(String jsonString, System.Type type) {
    return JSONDeserializerEngine.deserialize(jsonString, type);
  }

  /**
   * must have a public default constructor
   */
  public interface Deserializable {
    void setDeserializedField(String key, Object value);
    Map<String, System.Type> getDeserializableFields();
  }

  /**
   * Using this interface, you must expose a `public class YourType.Discriminator implements JSONDeserializer.Discriminator`
   */
  public interface Polymorph {
  }

  public interface Discriminator {
    System.Type discriminate(Map<String, Object> untyppedMap);
  }
}
