# Data Export

This section introduces methods for exporting nodes and edges from graphs. 

## Export()

Exports nodes or edges from the graph.

**Parameters**

- `exportRequest: *ultipa.ExportRequest`: Configurations for the export request, including fields `DbType`, `Schema`, `SelectProperties` and `Graph`.
- `cb: func(nodes []*structs.Node, edges []*structs.Edge)`: The callback function that gets executed when data is exported.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"sort"
	"strconv"
	"strings"

	ultipa "github.com/ultipa/ultipa-go-driver/v5/rpc"
	"github.com/ultipa/ultipa-go-driver/v5/sdk"
	"github.com/ultipa/ultipa-go-driver/v5/sdk/configuration"
	"github.com/ultipa/ultipa-go-driver/v5/sdk/structs"
)

func processNodes(filename string, nodes []*structs.Node) error {
	if nodes == nil {
		return nil
	}

	fileExists := fileExistsAndNotEmpty(filename)

	file, err := os.OpenFile(filename, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return fmt.Errorf("failed to create %s: %w", filename, err)
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	defer writer.Flush()

	allKeys := make(map[string]bool)
	for _, node := range nodes {
		for key := range node.Values.Data {
			allKeys[key] = true
		}
	}

	sortedKeys := make([]string, 0, len(allKeys))
	for key := range allKeys {
		sortedKeys = append(sortedKeys, key)
	}
	sort.Strings(sortedKeys)

	if !fileExists {
		if err := writer.Write(sortedKeys); err != nil {
			return err
		}
	}

	for _, node := range nodes {
		record := make([]string, len(sortedKeys))
		for i, key := range sortedKeys {
			if value, exists := node.Values.Data[key]; exists {
				record[i] = convertDataToString(value)
			} else {
				record[i] = ""
			}
		}
		if err := writer.Write(record); err != nil {
			return err
		}
	}
	return nil
}

func processEdges(filename string, edges []*structs.Edge) error {
	if edges == nil {
		return nil
	}

	fileExists := fileExistsAndNotEmpty(filename)

	file, err := os.OpenFile(filename, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return fmt.Errorf("failed to create %s: %w", filename, err)
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	defer writer.Flush()

	allKeys := make(map[string]bool)
	for _, edge := range edges {
		for key := range edge.Values.Data {
			allKeys[key] = true
		}
	}

	sortedKeys := make([]string, 0, len(allKeys))
	for key := range allKeys {
		sortedKeys = append(sortedKeys, key)
	}
	sort.Strings(sortedKeys)

	if !fileExists {
		if err := writer.Write(sortedKeys); err != nil {
			return err
		}
	}

	for _, edge := range edges {
		record := make([]string, len(sortedKeys))
		for i, key := range sortedKeys {
			if value, exists := edge.Values.Data[key]; exists {
				record[i] = convertDataToString(value)
			} else {
				record[i] = ""
			}
		}
		if err := writer.Write(record); err != nil {
			return err
		}
	}
	return nil
}

func fileExistsAndNotEmpty(filename string) bool {
	info, err := os.Stat(filename)
	if err != nil {
		return false
	}
	return !info.IsDir() && info.Size() > 0
}

func convertDataToString(value interface{}) string {
	switch v := value.(type) {
	case int, int8, int16, int32, int64:
		return fmt.Sprintf("%d", v)
	case uint, uint8, uint16, uint32, uint64:
		return fmt.Sprintf("%d", v)
	case float32:
		return strconv.FormatFloat(float64(v), 'f', -1, 32)
	case float64:
		return strconv.FormatFloat(v, 'f', -1, 64)
	case string:
		return v
	case bool:
		return strconv.FormatBool(v)
	case []interface{}:
		var builder strings.Builder
		for i, elem := range v {
			if i > 0 {
				builder.WriteString(",")
			}
			builder.WriteString(convertDataToString(elem))
		}
		return builder.String()
	case nil:
		return ""
	default:
		return fmt.Sprintf("%v", v)
	}
}

func main() {
	config := &configuration.UltipaConfig{
		// URI example:	Hosts: []string{"mqj4zouys.us-east-1.cloud.ultipa.com:60010"},
		Hosts:    []string{"192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"},
		Username: "<usernmae>",
		Password: "<password>",
	}

	driver, err := sdk.NewUltipaDriver(config)
	if err != nil {
		log.Fatalln("Failed to connect to Ultipa:", err)
	}

	// Exports 'account' nodes in the graph 'miniCircle'

	cb := func(nodes []*structs.Node, edges []*structs.Edge) error {
		fmt.Printf("Callback called: processing %d nodes and %d edges...\n", len(nodes), len(edges))
		var errs []error
		if err := processNodes("node.csv", nodes); err != nil {
			errs = append(errs, fmt.Errorf("node processing error: %w", err))
		}
		if err := processEdges("edge.csv", edges); err != nil {
			errs = append(errs, fmt.Errorf("edge processing error: %w", err))
		}

		if len(errs) > 0 {
			return fmt.Errorf("export completed with errors: %v", errs)
		}
		return nil
	}

	err = driver.Export(&ultipa.ExportRequest{
		DbType:           ultipa.DBType_DBNODE,
		Schema:           "account",
		SelectProperties: []string{"_id", "name", "year"},
		Graph:            "miniCircle",
	}, cb, nil)
	if err != nil {
		log.Fatalln("Export failed: %v", err)
	}
}
```

<p tit="Output"></p> 
 
```
Callback called: processing 37 nodes and 0 edges...
Callback called: processing 39 nodes and 0 edges...
Callback called: processing 35 nodes and 0 edges...
```

The file `nodes.csv` is exported to the same directory as the file you executed.