global with sharing class JSONDeserializer {
  @testVisible
  private JSONDeserializer() {
    throw new TypeException('JSONDeserializer is not meant to be instanciated');
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
   * Using this interface, you must expose a
   * `public class YourTypeDiscriminator implements JSONDeserializer.Discriminator`
   */
  public interface Polymorph {
  }

  public interface Discriminator {
    System.Type discriminate(Map<String, Object> untyppedMap);
  }
}
