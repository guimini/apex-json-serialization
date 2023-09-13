public with sharing class JSONDeserializerEngine {
  private static final System.Type MAP_TYPE = Map<String, Object>.class;
  private static final System.Type LIST_TYPE = List<Object>.class;
  private static final Pattern MAP_TYPE_VALIDATOR_PATTERN = Pattern.compile(
    'Map<(?!String)([^,]*)'
  );
  private static final Pattern SET_TYPE_VALIDATOR_PATTERN = Pattern.compile(
    'Set<'
  );

  public static Object deserialize(System.Type type, JSONParser parser) {
    return deserializeValue(type, parser);
  }

  private static Object deserializeValue(System.Type type, JSONParser parser) {
    JSONToken token = parser.getCurrentToken();
    switch on token {
      when START_ARRAY {
        return deserializeList(type, parser);
      }
      when START_OBJECT {
        if (JSONDeserializer.Deserializable.class.isAssignableFrom(type)) {
          return deserializeDeserializable(type, parser);
        }
        if (SObject.class.isAssignableFrom(type)) {
          return parser.readValueAs(type);
        }
        if (MAP_TYPE.isAssignableFrom(type)) {
          return deserializeMap(type, parser);
        }
        if (Object.class !== type) {
          return parser.readValueAs(type);
        }
        return deserializeObject(parser);
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

  /********* Specific type handlers ***********/

  private static Map<String, System.Type> getDeserializableFields(
    JSONDeserializer.Deserializable instance
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

  private static JSONDeserializer.Deserializable deserializeDeserializable(
    System.Type type,
    JSONParser parser
  ) {
    JSONToken token = parser.getCurrentToken();
    if (token != JSONToken.START_OBJECT) {
      throw new UnexpectedException(
        'Expected a object start here, got ' + token
      );
    }
    System.Type actualType = getDeserializableType(type, parser);
    JSONDeserializer.Deserializable instance = (JSONDeserializer.Deserializable) actualType.newInstance();
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
          deserializeValue(deserializableFields.get(fieldName), parser)
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

  private static Object deserializeObject(JSONParser parser) {
    return new Map<String, Object>{ 'key' => 'value' };
  }

  private static Map<String, Object> deserializeMap(
    System.Type type,
    JSONParser parser
  ) {
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
      instance.put(key, deserializeValue(valueType, parser));
      token = parser.nextToken();
      continue;
    }

    return instance;
  }

  private static List<Object> deserializeList(
    System.Type type,
    JSONParser parser
  ) {
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
      instance.add(deserializeValue(valueType, parser));
      token = parser.nextToken();
      continue;
    }

    return instance;
  }

  private static System.Type getDeserializableType(
    System.Type type,
    JSONParser parser
  ) {
    if (!JSONDeserializer.Polymorph.class.isAssignableFrom(type)) {
      return type;
    }
    System.Type discriminatorType = System.Type.forName(
      type.toString() + '.Discriminator'
    );
    if (
      discriminatorType == null ||
      !JSONDeserializer.Discriminator.class.isAssignableFrom(discriminatorType)
    ) {
      throw new IllegalArgumentException(
        'Polymorph Deserializable [' +
          type +
          '] must expose a `public class YourType.Discriminator implements JSONDeserializer`'
      );
    }

    JSONParser discriminationParser = parser.clone();
    JSONToken discriminationToken = discriminationParser.getCurrentToken();

    Object untypped = deserializeObject(discriminationParser);

    return ((JSONDeserializer.Discriminator) discriminatorType.newInstance())
      .discriminate((Map<String, Object>) untypped);
  }
}
