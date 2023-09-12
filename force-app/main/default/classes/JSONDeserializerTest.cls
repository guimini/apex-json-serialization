@isTest
public with sharing class JSONDeserializerTest {
  private class SimpleClass {
    public String firstname;
  }

  private class DeserializableClass implements JSONDeserializer.Deserializable {
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

  private class DeserializableAllTypesClass implements JSONDeserializer.Deserializable {
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

  private class DeserializableChain implements JSONDeserializer.Deserializable {
    public String name;
    public DeserializableChain next;
    public DeserializableChain() {
    }
    public DeserializableChain(String name, DeserializableChain next) {
      this.name = name;
      this.next = next;
    }
    public void setDeserializedField(String key, Object value) {
      switch on key {
        when 'name' {
          this.name = (String) value;
        }
        when 'next' {
          this.next = (DeserializableChain) value;
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
        'name' => String.class,
        'next' => DeserializableChain.class
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
      new DeserializableChain(
        '2',
        new DeserializableChain('3', new DeserializableChain('4', null))
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
      deserializedChain = deserializedChain.next;
    }
    Assert.isNull(deserializedChain, 'more element than expected');
  }
}
