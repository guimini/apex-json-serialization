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
          System.debug('AssignedintegerIndexed' + this.integerIndexed);
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
}
