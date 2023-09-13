System.Type MAP_TYPE = Map<Object, Object>.class;
System.debug(
  MAP_TYPE.isAssignableFrom(Map<String, Integer>.class) ? 'yes' : 'no'
);
System.debug(
  MAP_TYPE.isAssignableFrom(Map<Integer, String>.class) ? 'yes' : 'no'
);
