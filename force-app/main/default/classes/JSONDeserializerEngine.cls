public with sharing class JSONDeserializerEngine {
  private static final System.Type MAP_TYPE = Map<String, Object>.class;
  private static final System.Type LIST_TYPE = List<Object>.class;
  private static final Pattern MAP_TYPE_VALIDATOR_PATTERN = Pattern.compile(
    'Map<(?!String)([^,]*)'
  );
  private static final Pattern SET_TYPE_VALIDATOR_PATTERN = Pattern.compile(
    'Set<'
  );

  public static Object deserialize(String jsonString, System.Type type) {
    JSONParserProxy parser = new JSONParserProxy(jsonString);
    parser.nextToken(); // start reading
    return deserializeValue(type, parser);
  }

  private static Object deserializeValue(
    System.Type type,
    JSONParserProxy parser
  ) {
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
        if (Object.class != type) {
          return parser.readValueAs(type);
        }
        return deserializeAnyObject(parser);
      }
      // TODO, find out if that ever happens
      // when NOT_AVAILABLE, VALUE_EMBEDDED_OBJECT {
      //   throw new IllegalArgumentException(
      //     'Deserializing [' + token + '] is not supported yet'
      //   );
      // }
      when else {
        if (Object.class != type) {
          return parser.readValueAs(type);
        }
        return deserializeAnyPrimitive(parser);
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
    JSONParserProxy parser
  ) {
    JSONToken token = parser.getCurrentToken();
    System.Type actualType = getDeserializableType(type, parser);
    JSONDeserializer.Deserializable instance = (JSONDeserializer.Deserializable) actualType.newInstance();
    Map<String, System.Type> deserializableFields = getDeserializableFields(
      instance
    );

    token = parser.nextToken();
    while (token != JSONToken.END_OBJECT) {
      // read a field name, and see if we can interpret it
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

  private static Object deserializeAnyObject(JSONParserProxy parser) {
    return deserializeMap(Map<String, Object>.class, parser);
  }

  @testVisible
  private static Object deserializeAnyPrimitive(JSONParserProxy parser) {
    switch on parser.getCurrentToken() {
      when VALUE_FALSE, VALUE_TRUE {
        return parser.getBooleanValue();
      }
      when VALUE_NUMBER_FLOAT {
        // try {
        return parser.getDecimalValue(); // SEEMS TO NEVER THROW
        // } catch (Exception e) {
        //   return parser.getDoubleValue();
        // }
      }
      when VALUE_NUMBER_INT {
        try {
          return parser.getIntegerValue();
        } catch (Exception e) {
          return parser.getLongValue();
        }
      }
      when VALUE_STRING {
        String value = parser.getText();
        if (
          Pattern.matches(
            '^(\\d{4})-(\\d{2})-(\\d{2})T(\\d{2}):(\\d{2}):(\\d{2})\\.(\\d{3})?(Z|[+-]\\d{2}:?\\d{2})$',
            value
          )
        ) {
          return parser.getDatetimeValue();
        }
        if (Pattern.matches('^(\\d{4})-(\\d{2})-(\\d{2})$', value)) {
          return parser.getDateValue();
        }
        if (
          Pattern.matches(
            '^(\\d{2}):(\\d{2}):(\\d{2})\\.(\\d{3})?(Z|[+-]\\d{2}:?\\d{2})$',
            value
          )
        ) {
          return parser.getTimeValue();
        }

        if (value instanceof Id) {
          return parser.getIdValue();
        }

        return parser.getText();
      }
      when VALUE_NULL {
        return null;
      }
      when else {
        // i have never been able to find a case where this happens
        throw new IllegalArgumentException(
          'Unexpected token type : ' + parser.getCurrentToken()
        );
      }
    }
  }

  private static Map<String, Object> deserializeMap(
    System.Type type,
    JSONParserProxy parser
  ) {
    JSONToken token = parser.getCurrentToken();
    String valueTypeName = type.toString()
      .replaceFirst('Map<String,', '')
      .replace('>', '');
    System.Type valueType = System.Type.forName(valueTypeName);

    Map<String, Object> instance = (Map<String, Object>) type.newInstance();

    token = parser.nextToken();
    while (token != JSONToken.END_OBJECT) {
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
    JSONParserProxy parser
  ) {
    JSONToken token = parser.getCurrentToken();
    String valueTypeName = type.toString()
      .replaceFirst('(Set|List)<', '')
      .replace('>', '');
    System.Type valueType = System.Type.forName(valueTypeName);
    System.Type listType = System.Type.forName('List<' + valueTypeName + '>');

    List<Object> instance = (List<Object>) listType.newInstance();

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
    JSONParserProxy parser
  ) {
    if (!JSONDeserializer.Polymorph.class.isAssignableFrom(type)) {
      return type;
    }
    System.Type discriminatorType = System.Type.forName(
      type.toString() + 'Discriminator'
    );
    if (
      discriminatorType == null ||
      !JSONDeserializer.Discriminator.class.isAssignableFrom(discriminatorType)
    ) {
      throw new IllegalArgumentException(
        'Polymorph Deserializable [' +
          type +
          '] must expose a `public class YourTypeDiscriminator implements JSONDeserializerDiscriminator`'
      );
    }

    JSONParserProxy discriminationParser = new JSONParserProxy(parser);
    JSONToken discriminationToken = discriminationParser.getCurrentToken();

    Object untypped = deserializeAnyObject(discriminationParser);

    return ((JSONDeserializer.Discriminator) discriminatorType.newInstance())
      .discriminate((Map<String, Object>) untypped);
  }
}
