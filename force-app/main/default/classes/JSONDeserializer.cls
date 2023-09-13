global with sharing class JSONDeserializer {
  private System.JSONParser parser;

  private JSONDeserializer(String jsonString) {
    this.parser = JSON.createParser(jsonString);
  }

  private Object deserialize(System.Type type) {
    parser.nextToken(); //start reading
    return JSONDeserializerEngine.deserialize(type, this.parser);
  }

  global static Object deserialize(String jsonString, System.Type type) {
    JSONDeserializer deserializer = new JSONDeserializer(jsonString);
    return deserializer.deserialize(type);
  }

  /**
   * must have a public default constructor
   */
  public interface Deserializable {
    void setDeserializedField(String key, Object value);
    Map<String, System.Type> getDeserializableFields();
  }

  /**
   * Using this interface, you must expose a `public class YourType.Discriminator implements JSONDeserializer`
   */
  public interface Polymorph {
  }

  public interface Discriminator {
    System.Type discriminate(Map<String, Object> untyppedMap);
  }
}
