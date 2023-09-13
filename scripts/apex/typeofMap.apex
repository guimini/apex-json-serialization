System.Type MAP_TYPE = Map<Object, Object>.class;
System.Type LIST_TYPE = List<Object>.class;
System.Type SET_TYPE = Set<Object>.class;

System.debug(LIST_TYPE.isAssignableFrom(List<Integer>.class) ? 'yes' : 'no');
System.debug(LIST_TYPE.isAssignableFrom(Set<Integer>.class) ? 'yes' : 'no');

System.debug(JSON.serialize(Time.newInstance(1, 1, 1, 1)));

public class TestBlob {
  Blob b;
}

TestBlob b = new TestBlob();
b.b = Crypto.generateAesKey(128);

System.debug(JSON.serialize(b));

Blob.
// System.debug('3FOhqT2DJdBILSYKiV4dZg==' instanceof Blob ? 'yes' : 'no');
