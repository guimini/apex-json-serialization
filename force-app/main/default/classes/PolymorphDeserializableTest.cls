/**
 * This class it to be used in tests only !
 */
public abstract class PolymorphDeserializableTest implements JSONDeserializer.Deserializable, JSONDeserializer.Polymorph {
  public String type;
  public String commonField;

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

  public class Discriminator implements JSONDeserializer.Discriminator {
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
}
