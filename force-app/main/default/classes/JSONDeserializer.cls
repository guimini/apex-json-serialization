public with sharing class JSONDeserializer {
  private System.JSONParser parser;
  private static final System.Type MAP_TYPE = Map<String, Object>.class;
  private static final Pattern MAP_TYPE_VALIDATOR_PATTERN = Pattern.compile(
    'Map<(?!String)([^,]*)'
  );

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

  private Map<String, Object> deserializeMap(System.Type type) {
    JSONToken token = parser.getCurrentToken();
    String valueTypeName = type.toString()
      .replaceFirst('Map<String,', '')
      .replace('>', '');
    System.debug('valueTypeName=' + valueTypeName);
    System.debug('type=' + type.toString());
    System.Type valueType = System.Type.forName(valueTypeName);

    Map<String, Object> instance = (Map<String, Object>) type.newInstance();

    if (token != JSONToken.START_OBJECT) {
      throw new UnexpectedException(
        'Expected a object start here, got ' + token
      );
    }
    token = parser.nextToken();
    while (token != JSONToken.END_OBJECT) {
      // read a key, and see if we ca interpret it
      if (token != JSONToken.FIELD_NAME) {
        throw new UnexpectedException(
          'Expected a fieldname here, got ' + token
        );
      }
      String key = parser.getText();

      token = parser.nextToken();
      instance.put(key, deserializeField(valueType));
      token = parser.nextToken();
      continue;
    }

    return instance;
  }

  private Map<String, System.Type> getDeserializableFields(
    Deserializable instance
  ) {
    Map<String, System.Type> fields = instance.getDeserializableFields();
    for (System.Type type : fields.values()) {
      Matcher m = MAP_TYPE_VALIDATOR_PATTERN.matcher(type.toString());
      if (m.find()) {
        throw new IllegalArgumentException(
          'Unsupported Map Key Type [' +
            m.group(1) +
            ']. Only String indexed maps are supported'
        );
      }
    }
    return fields;
  }

  private Deserializable deserializeDeserializable(System.Type type) {
    JSONToken token = parser.getCurrentToken();
    if (token != JSONToken.START_OBJECT) {
      throw new UnexpectedException(
        'Expected a object start here, got ' + token
      );
    }
    Deserializable instance = (Deserializable) type.newInstance();
    Map<String, System.Type> deserializableFields = getDeserializableFields(
      instance
    );

    token = parser.nextToken();
    while (token != JSONToken.END_OBJECT) {
      // read a field name, and see if we can interpret it
      if (token != JSONToken.FIELD_NAME) {
        throw new UnexpectedException(
          'Expected a fieldname here, got ' + token
        );
      }
      String fieldName = parser.getText();
      if (deserializableFields.containsKey(fieldName)) {
        token = parser.nextToken();
        instance.setDeserializedField(
          fieldName,
          deserializeField(deserializableFields.get(fieldName))
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

  private Object deserializeField(System.Type type) {
    JSONToken token = parser.getCurrentToken();
    switch on token {
      when START_ARRAY {
        throw new IllegalArgumentException(
          'Deserializing arrays is not supported yet'
        );
      }
      when START_OBJECT {
        if (MAP_TYPE.isAssignableFrom(type)) {
          return deserializeMap(type);
        }
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
