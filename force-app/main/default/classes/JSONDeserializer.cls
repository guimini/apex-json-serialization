public with sharing class JSONDeserializer {
  private System.JSONParser parser;

  private JSONDeserializer(String jsonString) {
    this.parser = JSON.createParser(jsonString);
    parser.nextToken(); //start reading
  }

  private Object deserialize(System.Type type) {
    if (Deserializable.class.isAssignableFrom(type)) {
      return deserializeDeserializable(type);
    }
    return parser.readValueAs(type);
  }

  private Deserializable deserializeDeserializable(System.Type type) {
    JSONToken token = parser.getCurrentToken();
    Deserializable instance = (Deserializable) type.newInstance();
    Map<String, System.Type> deserializableFields = instance.getDeserializableFields();
    if (token != JSONToken.START_OBJECT) {
      throw new UnexpectedException(
        'Expected a object start here, got ' + token
      );
    }
    token = parser.nextToken();
    while (token != JSONToken.END_OBJECT) {
      // read a field name, and see if we ca interpret it
      if (token != JSONToken.FIELD_NAME) {
        throw new UnexpectedException(
          'Expected a fieldname here, got ' + token
        );
      }
      String fieldName = parser.getText();
      if (deserializableFields.containsKey(fieldName)) {
        System.debug('Deserializing : ' + fieldName);
        token = parser.nextToken();
        instance.setDeserializedField(
          fieldName,
          deserializeField(instance, deserializableFields.get(fieldName))
        );
        token = parser.nextToken();
        continue;
      }
      // ignored field;
      token = parser.nextToken();
      if (token == JSONToken.START_ARRAY || token == JSONToken.START_OBJECT) {
        parser.skipChildren();
      }
      token = parser.nextToken();
    }
    return instance;
  }

  private Object deserializeField(Deserializable instance, System.Type type) {
    JSONToken token = parser.getCurrentToken();
    switch on token {
      when START_ARRAY {
        throw new IllegalArgumentException(
          'Deserializing arrays is not supported yet'
        );
      }
      when START_OBJECT {
        return deserialize(type);
      }
      when NOT_AVAILABLE, VALUE_EMBEDDED_OBJECT {
        throw new IllegalArgumentException(
          'Deserializing [' + token + '] is not supported yet'
        );
      }
      when else {
        Object value = parser.readValueAs(type);
        return value;
      }
    }
  }

  public static Object deserialize(String jsonString, System.Type type) {
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

  public interface Polymorph {
    Discriminator getDiscriminator();
  }

  public interface Discriminator {
    System.Type discriminate(Object raw);
  }
}
