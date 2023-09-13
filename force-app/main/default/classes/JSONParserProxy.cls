/**
 * This is a workarround the fact that you cannot look ahead with standard parser.
 * A new one can be instanciated from another to start reading ahead.
 */
public with sharing class JSONParserProxy {
  enum OperationType {
    NEXT_TOKEN,
    NEXT_VALUE,
    READ_VALUE_AS,
    SKIP_CHILDREN
  }
  private class Operation {
    public OperationType type;
    public System.Type apexType;

    public Operation(OperationType type) {
      this(type, null);
    }
    public Operation(OperationType type, System.Type apexType) {
      this.type = type;
      this.apexType = apexType;
    }
  }

  private String jsonString;
  private List<Operation> operations;
  private JSONParser parser;

  public JSONParserProxy(String jsonString) {
    this.jsonString = jsonString;
    this.parser = JSON.createParser(jsonString);
    this.operations = new List<Operation>();
  }

  public JSONParserProxy(JSONParserProxy parent) {
    this(parent.jsonString);
    for (Operation operation : parent.operations) {
      switch on operation.type {
        when NEXT_TOKEN {
          this.parser.nextToken();
        }
        // when NEXT_VALUE {
        //   this.parser.nextValue();
        // }
        when READ_VALUE_AS {
          this.parser.readValueAs(operation.apexType);
        }
        when SKIP_CHILDREN {
          this.parser.nextToken();
        }
      }
    }
  }

  // public Void clearCurrentToken(){
  //     return parser.clearCurrentToken();
  // }
  //   public Blob getBlobValue() {
  //     return parser.getBlobValue();
  //   }
  public Boolean getBooleanValue() {
    return parser.getBooleanValue();
  }
  //   public String getCurrentName() {
  //     return parser.getCurrentName();
  //   }
  public System.JSONToken getCurrentToken() {
    return parser.getCurrentToken();
  }
  public Datetime getDatetimeValue() {
    return parser.getDateTimeValue();
  }
  public Date getDateValue() {
    return parser.getDateValue();
  }
  public Decimal getDecimalValue() {
    return parser.getDecimalValue();
  }
  //   public Double getDoubleValue() {
  //     return parser.getDoubleValue();
  //   }
  public ID getIdValue() {
    return parser.getIdValue();
  }
  public Integer getIntegerValue() {
    return parser.getIntegerValue();
  }
  // public System.JSONToken getLastClearedToken(){
  //     return parser.getLastClearedToken();
  // }
  public Long getLongValue() {
    return parser.getLongValue();
  }
  public String getText() {
    return parser.getText();
  }
  public Time getTimeValue() {
    return parser.getTimeValue();
  }
  //   public Boolean hasCurrentToken() {
  //     return parser.hasCurrentToken();
  //   }
  public System.JSONToken nextToken() {
    operations.add(new Operation(OperationType.NEXT_TOKEN));
    return parser.nextToken();
  }
  //   public System.JSONToken nextValue() {
  //     operations.add(new Operation(OperationType.NEXT_VALUE));
  //     return parser.nextValue();
  //   }
  public Object readValueAs(System.Type apexType) {
    operations.add(new Operation(OperationType.READ_VALUE_AS, apexType));
    return parser.readValueAs(apexType);
  }
  // public Object readValueAsStrict(System.Type apexType){
  //     return parser.readValueAsStrict(apexType);
  // }
  public void skipChildren() {
    operations.add(new Operation(OperationType.SKIP_CHILDREN));
    parser.skipChildren();
  }
}
