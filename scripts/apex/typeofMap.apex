System.Type MAP_TYPE = Map<Object, Object>.class;
System.Type LIST_TYPE = List<Object>.class;
System.Type SET_TYPE = Set<Object>.class;

System.debug(LIST_TYPE.isAssignableFrom(List<Integer>.class) ? 'yes' : 'no');
System.debug(LIST_TYPE.isAssignableFrom(Set<Integer>.class) ? 'yes' : 'no');
