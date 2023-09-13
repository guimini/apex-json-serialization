public with sharing class JSONDeserializer {
  private System.JSONParser parser;
  private static final System.Type MAP_TYPE = Map<String, Object>.class;
  private static final System.Type LIST_TYPE = List<Object>.class;
  private static final Pattern MAP_TYPE_VALIDATOR_PATTERN = Pattern.compile(
    'Map<(?!String)([^,]*)'
  );
  private static final Pattern SET_TYPE_VALIDATOR_PATTERN = Pattern.compile(
    'Set<'
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
      m = SET_TYPE_VALIDATOR_PATTERN.matcher(type.toString());
      if (m.find()) {
        throw new IllegalArgumentException(
          'Unsupported Set field. Since we have no way to cast to form Set<ANY>, you need to define field as List and implement a custom logic in setDeserializedField()'
        );
      }
    }
    return fields;
  }

  private Map<String, Object> deserializeMap(System.Type type) {
    JSONToken token = parser.getCurrentToken();
    String valueTypeName = type.toString()
      .replaceFirst('Map<String,', '')
      .replace('>', '');
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

  private List<Object> deserializeList(System.Type type) {
    JSONToken token = parser.getCurrentToken();
    String valueTypeName = type.toString()
      .replaceFirst('(Set|List)<', '')
      .replace('>', '');
    System.Type valueType = System.Type.forName(valueTypeName);
    System.Type listType = System.Type.forName('List<' + valueTypeName + '>');

    List<Object> instance = (List<Object>) listType.newInstance();

    if (token != JSONToken.START_ARRAY) {
      throw new UnexpectedException(
        'Expected a object start here, got ' + token
      );
    }
    token = parser.nextToken();
    while (token != JSONToken.END_ARRAY) {
      instance.add(deserializeField(valueType));
      token = parser.nextToken();
      continue;
    }

    return instance;
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
        return deserializeList(type);
      }
      when START_OBJECT {
        if (MAP_TYPE.isAssignableFrom(type)) {
          return deserializeMap(type);
        }
        return deserialize(type);
      }
      // TODO, find out if that ever happens
      // when NOT_AVAILABLE, VALUE_EMBEDDED_OBJECT {
      //   throw new IllegalArgumentException(
      //     'Deserializing [' + token + '] is not supported yet'
      //   );
      // }
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
