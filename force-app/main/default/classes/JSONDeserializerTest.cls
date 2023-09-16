@isTest
public with sharing class JSONDeserializerTest {
  private class SimpleClass {
    public String firstname;
  }

  public class DeserializableClass implements JSONDeserializer.Deserializable {
    private String firstname;
    public void setDeserializedField(String key, Object value) {
      switch on key {
        when 'first_name' {
          this.firstname = (String) value;
        }
        when else {
          throw new IllegalArgumentException(
            'Key [' + key + '] is not supported'
          );
        }
      }
    }
    public Map<String, System.Type> getDeserializableFields() {
      return new Map<String, System.Type>{ 'first_name' => String.class };
    }
  }

  public class DeserializableAllTypesClass implements JSONDeserializer.Deserializable {
    private String firstname;
    private Integer age;
    private ID id;
    private Double salary;
    private Long whealth;
    private Date birthday;
    private Datetime nextAppointment;
    private Boolean active;

    public void setDeserializedField(String key, Object value) {
      switch on key {
        when 'firstname' {
          this.firstname = (String) value;
        }
        when 'age' {
          this.age = (Integer) value;
        }
        when 'id' {
          this.id = (ID) value;
        }
        when 'whealth' {
          this.whealth = (Long) value;
        }
        when 'salary' {
          this.salary = (Double) value;
        }
        when 'birthday' {
          this.birthday = (Date) value;
        }
        when 'nextAppointment' {
          this.nextAppointment = (Datetime) value;
        }
        when 'active' {
          this.active = (Boolean) value;
        }
        when else {
          throw new IllegalArgumentException(
            'Key [' + key + '] is not supported'
          );
        }
      }
    }
    public Map<String, System.Type> getDeserializableFields() {
      return new Map<String, System.Type>{
        'firstname' => String.class,
        'age' => Integer.class,
        'id' => ID.class,
        'whealth' => Long.class,
        'salary' => Double.class,
        'birthday' => Date.class,
        'nextAppointment' => Datetime.class,
        'active' => Boolean.class
      };
    }
  }

  public class DeserializableChain implements JSONDeserializer.Deserializable {
    private String name;
    public String value {
      get {
        return name;
      }
    }
    public Contact contact;
    public DeserializableChain next;
    public DeserializableChain() {
    }
    public DeserializableChain(
      String name,
      Contact contact,
      DeserializableChain next
    ) {
      this.name = name;
      this.contact = contact;
      this.next = next;
    }
    public void setDeserializedField(String key, Object value) {
      switch on key {
        when 'value' {
          this.name = (String) value;
        }
        when 'next' {
          this.next = (DeserializableChain) value;
        }
        when 'contact' {
          this.contact = (Contact) value;
        }
        when else {
          throw new IllegalArgumentException(
            'Key [' + key + '] is not supported'
          );
        }
      }
    }
    public Map<String, System.Type> getDeserializableFields() {
      return new Map<String, System.Type>{
        'value' => String.class,
        'next' => DeserializableChain.class,
        'contact' => Contact.class
      };
    }
  }

  public class NestedMapDeserializable implements JSONDeserializer.Deserializable {
    public Map<String, DeserializableChain> stringIndexed;

    public void setDeserializedField(String key, Object value) {
      switch on key {
        when 'stringIndexed' {
          this.stringIndexed = (Map<String, DeserializableChain>) value;
          System.debug('AssignedstringIndexed' + this.stringIndexed);
        }
        when else {
          throw new IllegalArgumentException(
            'Key [' + key + '] is not supported'
          );
        }
      }
    }
    public Map<String, System.Type> getDeserializableFields() {
      return new Map<String, System.Type>{
        'stringIndexed' => Map<String, DeserializableChain>.class
      };
    }
  }

  public class NestedIntegerMapDeserializable implements JSONDeserializer.Deserializable {
    public Map<Integer, DeserializableChain> integerIndexed;

    public void setDeserializedField(String key, Object value) {
      switch on key {
        when 'integerIndexed' {
          this.integerIndexed = (Map<Integer, DeserializableChain>) value;
        }
        when else {
          throw new IllegalArgumentException(
            'Key [' + key + '] is not supported'
          );
        }
      }
    }
    public Map<String, System.Type> getDeserializableFields() {
      return new Map<String, System.Type>{
        'integerIndexed' => Map<Integer, DeserializableChain>.class
      };
    }
  }

  public class NestedListAndSetDeserializable implements JSONDeserializer.Deserializable {
    public Set<DeserializableChain> sd;
    public List<DeserializableChain> ld;

    public void setDeserializedField(String key, Object value) {
      switch on key {
        when 'ld' {
          this.ld = (List<DeserializableChain>) value;
        }
        when 'sd' {
          this.sd = new Set<DeserializableChain>();
          for (DeserializableChain item : (List<DeserializableChain>) value) {
            this.sd.add(item);
          }
        }
        when else {
          throw new IllegalArgumentException(
            'Key [' + key + '] is not supported'
          );
        }
      }
    }
    public Map<String, System.Type> getDeserializableFields() {
      return new Map<String, System.Type>{
        'ld' => List<DeserializableChain>.class,
        'sd' => List<DeserializableChain>.class
      };
    }
  }

  public class NestedInvalidSetDeserializable implements JSONDeserializer.Deserializable {
    public Set<DeserializableChain> sd;

    public void setDeserializedField(String key, Object value) {
      switch on key {
        when 'sd' {
          System.Assert.fail();
        }
        when else {
          throw new IllegalArgumentException(
            'Key [' + key + '] is not supported'
          );
        }
      }
    }
    public Map<String, System.Type> getDeserializableFields() {
      return new Map<String, System.Type>{
        'sd' => Set<DeserializableChain>.class
      };
    }
  }

  public class NestedObjectProperty implements JSONDeserializer.Deserializable {
    public List<Object> lo;
    public Object o;

    public void setDeserializedField(String key, Object value) {
      switch on key {
        when 'lo' {
          this.lo = (List<Object>) value;
        }
        when 'o' {
          this.o = value;
        }
        when else {
          throw new IllegalArgumentException(
            'Key [' + key + '] is not supported'
          );
        }
      }
    }
    public Map<String, System.Type> getDeserializableFields() {
      return new Map<String, System.Type>{
        'lo' => List<Object>.class,
        'o' => Object.class
      };
    }
  }

  public class PolymorphWithoutDiscriminator implements JSONDeserializer.Deserializable, JSONDeserializer.Polymorph {
    public String field;

    public void setDeserializedField(String key, Object value) {
      switch on key {
        when 'field' {
          this.field = (String) value;
        }
        when else {
          throw new IllegalArgumentException(
            'Key [' + key + '] is not supported'
          );
        }
      }
    }
    public Map<String, System.Type> getDeserializableFields() {
      return new Map<String, System.Type>{ 'field' => String.class };
    }
  }

  public abstract class PolymorphDeserializableTest implements JSONDeserializer.Deserializable, JSONDeserializer.Polymorph {
    public String type;
    public String commonField;
    public Map<String, Object> ignoredField = new Map<String, Object>{
      'someKey' => 'ignoredValue'
    };

    public PolymorphDeserializableTest() {
    }
    public PolymorphDeserializableTest(String commonField) {
      this.commonField = commonField;
    }

    public virtual void setDeserializedField(String key, Object value) {
      switch on key {
        when 'commonField' {
          this.commonField = (String) value;
        }
        when else {
          throw new IllegalArgumentException(
            'Key [' + key + '] is not supported'
          );
        }
      }
    }
    public virtual Map<String, System.Type> getDeserializableFields() {
      return new Map<String, System.Type>{ 'commonField' => String.class };
    }
  }
  public class PolymorphDeserializableTestDiscriminator implements JSONDeserializer.Discriminator {
    public System.Type discriminate(Map<String, Object> untyppedMap) {
      if (untyppedMap.get('type') == 'a') {
        return AVariantPolymorph.class;
      }
      return BVariantPolymorph.class;
    }
  }

  public class AVariantPolymorph extends PolymorphDeserializableTest {
    public String type = 'a';
    public String aField;

    public AVariantPolymorph() {
    }
    public AVariantPolymorph(String commonField, String aField) {
      super(commonField);
      this.aField = aField;
    }

    public override void setDeserializedField(String key, Object value) {
      switch on key {
        when 'aField' {
          this.aField = (String) value;
        }
        when else {
          super.setDeserializedField(key, value);
        }
      }
    }
    public override Map<String, System.Type> getDeserializableFields() {
      Map<String, System.Type> fields = super.getDeserializableFields();
      fields.putAll(new Map<String, System.Type>{ 'aField' => String.class });
      return fields;
    }
  }
  public class BVariantPolymorph extends PolymorphDeserializableTest {
    public String type = 'b';
    public String bField;

    public BVariantPolymorph() {
    }
    public BVariantPolymorph(String commonField, String bField) {
      super(commonField);
      this.bField = bField;
    }

    public override void setDeserializedField(String key, Object value) {
      switch on key {
        when 'bField' {
          this.bField = (String) value;
        }
        when else {
          super.setDeserializedField(key, value);
        }
      }
    }
    public override Map<String, System.Type> getDeserializableFields() {
      Map<String, System.Type> fields = super.getDeserializableFields();
      fields.putAll(new Map<String, System.Type>{ 'bField' => String.class });
      return fields;
    }
  }

  public class ListPolymorphClass implements JSONDeserializer.Deserializable {
    public List<PolymorphDeserializableTest> ld;

    public void setDeserializedField(String key, Object value) {
      switch on key {
        when 'ld' {
          this.ld = (List<PolymorphDeserializableTest>) value;
        }
        when else {
          throw new IllegalArgumentException(
            'Key [' + key + '] is not supported'
          );
        }
      }
    }
    public Map<String, System.Type> getDeserializableFields() {
      return new Map<String, System.Type>{
        'ld' => List<PolymorphDeserializableTest>.class
      };
    }
  }

  @isTest
  public static void throwsWhenInstanciated() {
    Boolean threw = false;
    try {
      new JSONDeserializer();
    } catch (Exception e) {
      System.Assert.isTrue(
        e.getMessage().contains('is not meant to be instanciated')
      );
      threw = true;
    } finally {
      System.Assert.isTrue(threw);
    }
  }

  @isTest
  public static void handlesSimpleClass() {
    SimpleClass simple = (SimpleClass) JSONDeserializer.deserialize(
      '{"firstname":"John"}',
      SimpleClass.class
    );
    Assert.areEqual(
      'John',
      simple.firstname,
      'Failed to parse: ' + simple.firstname
    );
  }

  @isTest
  public static void handlesDeserializableSimpleClass() {
    DeserializableClass simple = (DeserializableClass) JSONDeserializer.deserialize(
      '{"first_name":"John"}',
      DeserializableClass.class
    );
    Assert.areEqual(
      'John',
      simple.firstname,
      'Failed to parse: ' + simple.firstname
    );
  }

  @isTest
  public static void handlesDeserializableClassWithAllPlainValues() {
    DeserializableAllTypesClass sample = new DeserializableAllTypesClass();
    sample.active = true;
    sample.age = 42;
    sample.birthday = Date.today();
    sample.firstname = 'John';
    sample.id = '00D7Y000000EVbc';
    sample.salary = 3000000;
    sample.nextAppointment = Datetime.now();
    sample.whealth = Long.valueOf('300000000000');
    String serializedSample = JSON.serialize(sample);
    System.debug(serializedSample);
    DeserializableAllTypesClass result = (DeserializableAllTypesClass) JSONDeserializer.deserialize(
      serializedSample,
      DeserializableAllTypesClass.class
    );
    Assert.areEqual(
      sample.active,
      result.active,
      'Failed to parse ' + Boolean.class
    );
    Assert.areEqual(sample.age, result.age, 'Failed to parse ' + Integer.class);
    Assert.areEqual(
      sample.birthday,
      result.birthday,
      'Failed to parse ' + Date.class
    );
    Assert.areEqual(sample.id, result.id, 'Failed to parse ' + ID.class);
    Assert.areEqual(
      sample.nextAppointment,
      result.nextAppointment,
      'Failed to parse ' + Datetime.class
    );
    Assert.areEqual(
      sample.whealth,
      result.whealth,
      'Failed to parse ' + Double.class
    );
  }

  @isTest
  public static void handlesIgnoredFields() {
    DeserializableClass simple = (DeserializableClass) JSONDeserializer.deserialize(
      '{"details":{"something":"else"},"tags":["anonymous","unknown"],"lastname":"Doe","first_name":"John"}',
      DeserializableClass.class
    );
    Assert.areEqual(
      'John',
      simple.firstname,
      'Failed to parse: ' + simple.firstname
    );
  }

  @isTest
  public static void handlesNestedDeserializables() {
    DeserializableChain chainRoot = new DeserializableChain(
      '1',
      new Contact(LastName = '1'),
      new DeserializableChain(
        '2',
        new Contact(LastName = '2'),
        new DeserializableChain(
          '3',
          new Contact(LastName = '3'),
          new DeserializableChain('4', new Contact(LastName = '4'), null)
        )
      )
    );

    DeserializableChain deserializedChain = (DeserializableChain) JSONDeserializer.deserialize(
      JSON.serialize(chainroot),
      DeserializableChain.class
    );
    for (Integer i = 1; i <= 4; i++) {
      Assert.areEqual(
        i,
        Integer.valueOf(deserializedChain.name),
        'failed parsing name'
      );
      Assert.areEqual(
        i,
        Integer.valueOf(deserializedChain.contact.LastName),
        'failed parsing contact'
      );
      deserializedChain = deserializedChain.next;
    }
    Assert.isNull(deserializedChain, 'more element than expected');
  }

  @isTest
  public static void handlesMapsOfDeserializables() {
    String serializedRoot = '{"stringIndexed":{"2":{"next":{"next":null,"value":"2","contact":null},"value":"2","contact":{"attributes":{"type":"Contact"},"LastName":"2"}},"1":{"next":{"next":null,"value":"1","contact":null},"value":"1","contact":{"attributes":{"type":"Contact"},"LastName":"1"}},"0":{"next":{"next":null,"value":"0","contact":null},"value":"0","contact":{"attributes":{"type":"Contact"},"LastName":"0"}}}}';
    System.debug(serializedRoot);

    NestedMapDeserializable deserializedRoot = (NestedMapDeserializable) JSONDeserializer.deserialize(
      serializedRoot,
      NestedMapDeserializable.class
    );

    for (Integer i = 0; i < 3; i++) {
      Assert.areEqual(
        i.format(),
        deserializedRoot.stringIndexed.get(i.format()).name,
        'failed parsing StringIndexed map'
      );
    }
  }

  @isTest
  public static void rejectsUnsupportedMapKeys() {
    String serializedRoot = '{"integerIndexed":{"2":{"next":{"next":null,"value":"2","contact":null},"value":"2","contact":{"attributes":{"type":"Contact"},"LastName":"2"}},"1":{"next":{"next":null,"value":"1","contact":null},"value":"1","contact":{"attributes":{"type":"Contact"},"LastName":"1"}},"0":{"next":{"next":null,"value":"0","contact":null},"value":"0","contact":{"attributes":{"type":"Contact"},"LastName":"0"}}}}';
    System.debug(serializedRoot);

    Boolean threw = false;
    try {
      NestedIntegerMapDeserializable deserializedRoot = (NestedIntegerMapDeserializable) JSONDeserializer.deserialize(
        serializedRoot,
        NestedIntegerMapDeserializable.class
      );
    } catch (IllegalArgumentException e) {
      System.Assert.isTrue(e.getMessage().contains('Integer'));
      threw = true;
    } finally {
      System.Assert.isTrue(threw);
    }
  }

  @isTest
  public static void handlesListAndSetWithCustomHandlerOfDeserializables() {
    NestedListAndSetDeserializable root = new NestedListAndSetDeserializable();
    root.sd = new Set<DeserializableChain>{
      new DeserializableChain(
        '1',
        null,
        new DeserializableChain('2', null, null)
      )
    };
    root.ld = new List<DeserializableChain>{
      new DeserializableChain(
        '1',
        null,
        new DeserializableChain('2', null, null)
      )
    };

    String serializedRoot = JSON.serialize(root);
    System.debug(serializedRoot);

    NestedListAndSetDeserializable deserializedRoot = (NestedListAndSetDeserializable) JSONDeserializer.deserialize(
      serializedRoot,
      NestedListAndSetDeserializable.class
    );
    System.Assert.areEqual(1, deserializedRoot.sd.size());
    System.Assert.areEqual('2', deserializedRoot.ld[0].next.name);
  }

  @isTest
  public static void rejectsUnsupporteSet() {
    NestedInvalidSetDeserializable root = new NestedInvalidSetDeserializable();
    root.sd = new Set<DeserializableChain>{
      new DeserializableChain(
        '1',
        null,
        new DeserializableChain('2', null, null)
      )
    };

    String serializedRoot = JSON.serialize(root);
    System.debug(serializedRoot);

    Boolean threw = false;
    try {
      NestedInvalidSetDeserializable deserializedRoot = (NestedInvalidSetDeserializable) JSONDeserializer.deserialize(
        serializedRoot,
        NestedInvalidSetDeserializable.class
      );
    } catch (IllegalArgumentException e) {
      System.Assert.isTrue(e.getMessage().contains('Set<ANY>'));
      threw = true;
    } finally {
      System.Assert.isTrue(threw);
    }
  }

  @isTest
  public static void handlesPolymorphDeserializables() {
    ListPolymorphClass root = new ListPolymorphClass();
    root.ld = new List<PolymorphDeserializableTest>{
      new AVariantPolymorph('1', '1'),
      new BVariantPolymorph('2', '2')
    };

    String serializedRoot = JSON.serialize(root);
    System.debug(serializedRoot);

    ListPolymorphClass deserializedRoot = (ListPolymorphClass) JSONDeserializer.deserialize(
      serializedRoot,
      ListPolymorphClass.class
    );
    AVariantPolymorph a = (AVariantPolymorph) deserializedRoot.ld.get(0);
    BVariantPolymorph b = (BVariantPolymorph) deserializedRoot.ld.get(1);

    System.Assert.areEqual(a.commonField, a.aField);
    System.Assert.areEqual(b.commonField, b.bField);
  }

  @isTest
  public static void rejectsPolymorphNotProvidingDiscriminator() {
    Boolean threw = false;
    try {
      PolymorphWithoutDiscriminator deserializedRoot = (PolymorphWithoutDiscriminator) JSONDeserializer.deserialize(
        '{"field":"value"}',
        PolymorphWithoutDiscriminator.class
      );
    } catch (IllegalArgumentException e) {
      System.Assert.isTrue(
        e.getMessage()
          .contains(
            '`public class YourTypeDiscriminator implements JSONDeserializerDiscriminator`'
          )
      );
      threw = true;
    } finally {
      System.Assert.isTrue(threw);
    }
  }

  @isTest
  public static void handlesObject() {
    NestedObjectProperty root = new NestedObjectProperty();
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/langCon_apex_primitives.htm
    root.lo = new List<Object>{
      true,
      Date.newInstance(2000, 1, 1),
      Datetime.newInstance(2000, 1, 1),
      1.1,
      2889867496796748674967967496748699782898674967967496748699782898674967967496748699774967482898674967967496748699782898674967967496748699782898674967967496748699782898674967967496748699782898674967967496748699786997828986749679674967486997828986749679674967486997828986749679674967486997.718282898674967967496748699782898674967967496748699781828986749679674967486997669604d,
      (ID) '00300000003T2PGAA0',
      1,
      2147483623547483648L,
      'a',
      Time.newInstance(1, 1, 1, 1),
      null
    };
    root.o = new Map<String, Object>{ 'key' => 'value' };
    String seriliazedRoot = JSON.serialize(root);
    System.debug(seriliazedRoot);

    NestedObjectProperty deserializedRoot = (NestedObjectProperty) JSONDeserializer.deserialize(
      seriliazedRoot,
      NestedObjectProperty.class
    );

    System.Assert.areEqual(root.o, deserializedRoot.o);
    for (Integer i = 0; i < root.lo.size(); i++) {
      String s = root.lo.get(i) + '=' + deserializedRoot.lo.get(i);
      System.debug(s);
      System.Assert.areEqual(root.lo.get(i), deserializedRoot.lo.get(i));
    }
  }

  /**
   * This test is only for code coverage since i never was able to find an actual case where this happens
   */
  @isTest
  public static void rejectsInvalidPrimitiveValue() {
    Boolean threw = false;
    try {
      JSONParserProxy parser = new JSONParserProxy('{"key":"value"}');
      parser.nextToken(); // Token is now `START_OBJECT`
      JSONDeserializerEngine.deserializeAnyPrimitive(parser);
    } catch (Exception e) {
      System.Assert.isTrue(
        e.getMessage().contains('Unexpected token type : START_OBJECT')
      );
      threw = true;
    } finally {
      System.Assert.isTrue(threw);
    }
  }
}
