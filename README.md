# JSONDeserializer

This repo offers a better alternative to `JSON.deserialize()` and `JSON.deserializeUntypped()`

## Key Features

- Deserializing arbitrary keys to specific members of your `Deserializable` class : bringing a more tedious yet functionally equivalent to GSON `@SerializedName("name")` https://www.javadoc.io/doc/com.google.code.gson/gson/2.6.2/com/google/gson/annotations/SerializedName.html

- Polymorphic Deserialization : Should you need to deserialize values that may need to be deserialized to a different class depending on the content of serialized object, you may provide a `Discriminator` with your `Polymorph` `Deserializable` class

- Support for `Object` typped members. Avoiding `System.JSONException: Apex Type unsupported in JSON: Object`, for there are times we simply do not know what to expect !

## Deploy right away

But have a look at the code first. Don't trust random code from the internet ;)

<a href="https://githubsfdeploy.herokuapp.com?owner=gaelmotte&repo=apex-json-serialization&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

Thanks @andyinthecloud

## What's next

- [ ] Json Serialization to arbitrary keys
- [ ] Package
- [ ] Publish to NPM

## Known Gotchas

- Deserialzing to `Blob` type may give surprising results. I was not able to handle that properly. Please avoid it. PR welcome :)
- If a member of class is `Deserializable`, then that class should implement `Deserializable`.
- Performance. I didn't run any perf test, but i wouldn't be surprised if it were dramatically slower than the standard counterpart. If you look big and complex json payloads, this may be an issue.
