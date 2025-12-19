# Comments

##  Single-Line Comments

In UQL, single-line comments are written using two forward slashes `//`. Everything following `//` on the same line is treated as a comment and ignored during query execution.

```uql
n({@User.name == "rowlock"}).re({@Follows}).n({@User} as n) // Retrieves users followed by rowlock
return n.name
```

## Multi-Line Comments

Multi-line comments begin with a forward slash and asterisk (`/*`) and end with an asterisk and forward slash (`*/`), allowing for comments that span multiple lines.


```uql
/* This query retrieves users followed by rowlock,
and returns all their names */
n({@User.name == "rowlock"}).re({@Follows}).n({@User} as n)
return n.name
```
