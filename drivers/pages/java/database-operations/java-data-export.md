# Data Export

This section introduces methods for exporting nodes and edges from graphs. 

## export()

Exports nodes or edges from the graph.

**Parameters**

- `exportRequest: ExportRequest`: Configurations for the export request, including attributes `dbType` (defaults to `DBNODE`), `schema`, `selectProperties` and `graph`.
- `listener: ExportListener`: The listener that gets executed when data is exported.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- None.

```java
// Exports 'account' nodes in the graph 'miniCircle'

Ultipa.ExportRequest exportRequest = Ultipa.ExportRequest.newBuilder()
		.setDbType(Ultipa.DBType.DBNODE)
  		.setSchema("account")
  		.setGraph("miniCircle")
  		.addSelectProperties("_id")
  		.addSelectProperties("name")
  		.addSelectProperties("year")
  		.build();

driver.export(exportRequest, new ExportListener() {
    FileWriter csvWriter;
    String schemaName = exportRequest.getSchema();
    String suffix = exportRequest.getDbType() == Ultipa.DBType.DBNODE ? "_node.csv" : "_edge.csv";
    String fileName = schemaName + suffix;

    {
        try {
      		csvWriter = new FileWriter(fileName);
      		csvWriter.append("_id,name,year\n"); // header row
        } catch (IOException e) {
      	    throw new RuntimeException("Failed to create CSV file", e);
        }
    }

    public void onReady() {
    	System.out.println("Start downloading");
    }

    public void onError(Throwable t) {
    	System.out.println("Error occurred while downloading: " + t.getMessage());
    }

    public void onComplete() {
    	System.out.println("Download complete");
    	try {
      		if (csvWriter != null) csvWriter.close();
    	} catch (IOException e) {
      		e.printStackTrace();
    	}
  	}

    public void next(ExportData result) {
    	List<Node> nodes = result.getNodes();
    	for (Node node : nodes) {
      		try {
        		List<String> values = Arrays.asList(
          		String.valueOf(node.getID()),
          		String.valueOf(node.get("name")),
          		String.valueOf(node.get("year"))
        	).stream().map(val -> "\"" + val + "\"").collect(Collectors.toList()); // wrap values in quotes

        	csvWriter.append(String.join(",", values)).append("\n");
			} catch (IOException e) {
        		System.err.println("Failed to write a row to CSV: " + e.getMessage());
      		}
    	}
    }
});
```

<p tit="Output"></p> 

```
Download complete
```

The file `account_nodes.csv` is exported to the root directory of your project.

## Full Example

<p tit="Main.java"></p>

```java
package com.ultipa.www.sdk.api;

import com.ultipa.Ultipa;
import com.ultipa.sdk.UltipaDriver;
import com.ultipa.sdk.connect.conf.UltipaConfig;
import com.ultipa.sdk.operate.command.listener.ExportListener;
import com.ultipa.sdk.operate.entity.*;
import com.ultipa.sdk.operate.response.ExportData;
import org.assertj.core.util.Lists;

import java.util.Arrays;
import java.util.List;
import java.io.FileWriter;
import java.io.IOException;
import java.util.stream.Collectors;

public class Main {
    public static void main(String[] args) {
        UltipaConfig ultipaConfig = UltipaConfig.config()
                // URI example: .hosts(Lists.newArrayList("d3026ac361964633986849ec43b84877s.eu-south-1.cloud.ultipa.com:8443"))
                .hosts(Lists.newArrayList("192.168.1.85:60061","192.168.1.88:60061","192.168.1.87:60061"))
                .username("<username>")
                .password("<password>");

        UltipaDriver driver = null;

        try {
            driver = new UltipaDriver(ultipaConfig);

            // Exports 'account' nodes in the graph 'miniCircle'

            Ultipa.ExportRequest exportRequest = Ultipa.ExportRequest.newBuilder()
                    .setDbType(Ultipa.DBType.DBNODE)
                    .setSchema("account")
                    .setGraph("miniCircle")
                    .addSelectProperties("_id")
                    .addSelectProperties("name")
                    .addSelectProperties("year")
                    .build();

            driver.export(exportRequest, new ExportListener() {
                FileWriter csvWriter;
                String schemaName = exportRequest.getSchema();
                String suffix = exportRequest.getDbType() == Ultipa.DBType.DBNODE ? "_node.csv" : "_edge.csv";
                String fileName = schemaName + suffix;

                {
                    try {
                        csvWriter = new FileWriter(fileName);
                        csvWriter.append("_id,name,year\n"); // header row
                    } catch (IOException e) {
                        throw new RuntimeException("Failed to create CSV file", e);
                    }
                }

                public void onReady() {
                    System.out.println("Start downloading");
                }

                public void onError(Throwable t) {
                    System.out.println("Error occurred while downloading: " + t.getMessage());
                }

                public void onComplete() {
                    System.out.println("Download complete");
                    try {
                        if (csvWriter != null) csvWriter.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }

                public void next(ExportData result) {
                    List<Node> nodes = result.getNodes();
                    for (Node node : nodes) {
                        try {
                            List<String> values = Arrays.asList(
                                    String.valueOf(node.getID()),
                                    String.valueOf(node.get("name")),
                                    String.valueOf(node.get("year"))
                            ).stream().map(val -> "\"" + val + "\"").collect(Collectors.toList()); // wrap values in quotes

                            csvWriter.append(String.join(",", values)).append("\n");
                        } catch (IOException e) {
                            System.err.println("Failed to write a row to CSV: " + e.getMessage());
                        }
                    }
                }
            });
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        } finally {
            if (driver != null) {
                driver.close();
            }
        }
    }
}
```
