# Java

## Installation

## Supported Java Versions

The Ultipa Java SDK requires JDK8 or higher.


## Add Ultipa as a Dependency

If you have a **Maven** project, you can add the Ultipa Java SDK as a dependency in the `pom.xml` file:

<p tit= "pom.xml" ></p> 

```xml
<dependencies>
  ...
  <!-- https://mvnrepository.com/artifact/com.ultipa/ultipa-java-sdk -->
  <dependency>
    <groupId>com.ultipa</groupId>
    <artifactId>ultipa-java-sdk</artifactId>
    <version>4.x.x-s4.x</version>
  </dependency>
  ...
</dependencies>
```

If you are using **Gradle**, add the following to your `build.gradle` dependencies list:

<p tit= "build.gradle" ></p> 

```js
dependencies {
    implementation group: 'com.ultipa', name: 'ultipa-java-sdk', version: '4.x.x-s4.x'
}
