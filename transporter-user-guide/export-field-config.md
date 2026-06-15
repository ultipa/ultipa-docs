# Export Config | Data Field

## General Format

- Confgure schemas under `nodeConfig` and `edgeConfig`:

```yml
nodeConfig:

# Configure a node schema
  # Schema name
  - schema:
    # (Optional) Lists the customer properties to be exported
    properties:
      # A custom property
      - name:
      # More custom property
      - name:
      
# Configure more node schemas
  - schema:
    ...

edgeConfig:  

# Configure an edge schema
  - schema:
    ...

# Configure more edge schemas
  - schema:
    ...
```

## Example
```yml
...
nodeConfig:
  - schema: student
    # export all properties of this schema when not specifying `properties`
    
  - schema: course
    properties:
      - name: title
      - name: credit
      # System properties are auto-exported and do not need to be listed

edgeConfig:
  # Star * denotes all properties of all schemas
  - schema: "*"			
...
```

