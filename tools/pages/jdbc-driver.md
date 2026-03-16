# JDBC Driver

## Overview

Ultipa JDBC Driver is a Type 4 pure Java driver that enables standard SQL access to Ultipa Graph Database. It allows BI tools (such as Tableau, DBeaver, and others) and Java applications to query Ultipa using SQL statements, which are automatically translated to GQL.

## Installation

### Maven

Add the following dependency to your `pom.xml`:

```xml
<dependencies>
  <dependency>
    <groupId>com.ultipa</groupId>
    <artifactId>ultipa-jdbc-driver</artifactId>
    <version>1.0.0</version>
  </dependency>
</dependencies>
```

### Standalone JAR

For BI tools, place the JAR file in the tool's driver directory.

## Connection URL

```
jdbc:ultipa://<host>:<port>/<graph>?user=<username>&password=<password>
```

Example:

```
jdbc:ultipa://10.0.0.1:60061/social?user=root&password=root
```

## Usage

### Java Application

```java
import java.sql.*;

String url = "jdbc:ultipa://10.0.0.1:60061/social?user=root&password=root";

try (Connection conn = DriverManager.getConnection(url);
     Statement stmt = conn.createStatement();
     ResultSet rs = stmt.executeQuery("SELECT name, age FROM Person WHERE age > 30")) {
    while (rs.next()) {
        System.out.println(rs.getString("name") + ": " + rs.getInt("age"));
    }
}
```

### BI Tool Configuration

When configuring Ultipa in a BI tool:

1. Add the JDBC driver JAR to the tool's driver directory.
2. Set the driver class to `com.ultipa.jdbc.UltipaDriver`.
3. Use the connection URL format above.

## SQL to GQL Translation

The driver automatically translates SQL SELECT statements into GQL queries:

| SQL | GQL |
| -- | -- |
| `SELECT name, age FROM Person WHERE age > 30` | `MATCH (n:Person) WHERE n.age > 30 RETURN n.name, n.age` |
| `SELECT * FROM Person ORDER BY age LIMIT 10` | `MATCH (n:Person) RETURN n ORDER BY n.age LIMIT 10` |
| `SELECT COUNT(*) FROM Person` | `MATCH (n:Person) RETURN count(n)` |

### Supported SQL Features

- `SELECT` with column selection
- `WHERE` with comparison operators, `AND`, `OR`, `NOT`
- `ORDER BY` with `ASC`/`DESC`
- `LIMIT` and `OFFSET`
- Aggregate functions: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`
- `GROUP BY` and `HAVING`

### GQL Passthrough

If a statement is already valid GQL, it is passed through directly without translation:

```java
ResultSet rs = stmt.executeQuery("MATCH (n:Person)-[:Knows]->(m:Person) RETURN n.name, m.name");
```

## SQL to GQL Standalone Module

The SQL-to-GQL translator is also available as a standalone Java library:

```java
import com.ultipa.sql2gql.SqlToGqlTranslator;
import com.ultipa.sql2gql.GqlResult;

SqlToGqlTranslator translator = new SqlToGqlTranslator();
GqlResult result = translator.translate("SELECT name, age FROM Person WHERE age > 30");

System.out.println(result.getGql());          // MATCH (n:Person) WHERE n.age > 30 RETURN n.name, n.age
System.out.println(result.isPassthrough());   // false
```

Or as a CLI tool:

```bash
java -jar ultipa-sql2gql.jar "SELECT name FROM Person"
```
