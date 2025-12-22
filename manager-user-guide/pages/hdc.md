# HDC

Click **HDC** in the left sidebar to manage HDC graphs and algorithms in the database.

<center><img src="https://img.ultipa.cn/img/2025-04-15-10-43-46-hdc.jpg"></center>

To use this module, <a target="_blank" href="/docs/graph-database/powerhouse-v5">HDC (High-Density Computing) servers</a> must be deployed for the databases. You can switch between HDC servers using the dropdown menu at the top. Each HDC server maintains its own set of graphs and algorithms independently.

## HDC Graphs

An HDC graph resides in the memory of the HDC server and contains all or part of the data loaded from a graph. You can manage HDC graphs for the selected server in the **Graph** tab.

### Create HDC Graph

Click the **Add HDC Graph** button to add an HDC graph with the following options:

- **HDC Graph Name:** The name of the HDC graph. Names must be unique among HDC graphs hosted on the same server.
- **Choose Graph Source:** Select the original graph from which nodes and edges will be loaded.
- **Update Strategy:** Specifies the data synchronization mode.
  - `static`: Changes made to the original graph will not be reflected in the HDC graph.
  - `dynamic`: Insertions, updates, and deletions in the original graph will be synchronized to the HDC graph.
- **As Default:** Set this HDC graph as the default for the selected original graph.
- **Customize Schema:** Choose which node and edge schemas to include and specify the properties to load.

<center><img src="https://img.ultipa.cn/img/2025-04-15-10-55-07-add-hdc-graph.jpg"></center>

### View HDC Graph

Click an HDC graph in the list to view the schemas and properties of the nodes and edges it contains.

### Delete HDC Graph

Click the **Delete** icon on an HDC graph card to remove it from the selected HDC server.

## HDC Algorithms

Ultipa provides a suite of <a target="_blank" href="/docs/graph-analytics-algorithms">algorithms</a> that can be installed on HDC servers. These algorithms are hot-pluggable, allowing you to add or remove them seamlessly without interrupting ongoing database operations. Once installed, they can be executed on HDC graphs.

You can manage HDC algorithms for the selected server in the **Algo** tab:

<center><img src="https://img.ultipa.cn/img/2025-04-15-11-28-46-algo.jpg" ></center>

### Install Algorithm

Click the **Install** button to install HDC algorithms. Each algorithm requires an installation file (`.so`) and a configuration file (`.yml`) for proper setup. To obtain algorithms, please contact us at <a href="mailto:support@ultipa.com">support@ultipa.com</a>.

### Run Algorithm

Click an algorithm in the list to view its details, including introduction, parameters, writeback options, and executable GQL and UQL examples. Click on an example to automatically populate the **Editor** with the corresponding query. Be sure to replace `<hdcGraphName>` in the query with your target HDC graph before executing it.

<center><img src="https://img.ultipa.cn/img/2025-04-15-11-34-17-run-algo.jpg" ></center>

### Uninstall Algorithm

Click the **Delete** icon on an HDC algorithm card to remove it from the selected HDC server.
