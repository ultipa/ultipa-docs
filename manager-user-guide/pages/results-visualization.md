# Results Visualization

The **Results Pane** displays the results of the executed query.

<center><img src="https://img.ultipa.cn/img/2025-04-14-10-26-07-results-pane.jpg"></center>

## Interactive Overlays

Interactive overlays on the **Results Pane** include:

- The top displays the **query history** and **returned alias tabs**. You can click a query history to switch back to its results.

<center><img width="70%" src="https://img.ultipa.cn/img/2025-04-14-10-31-55-returned-aliases.jpg"></center>

- The left side offers a set of tools to interact with the graph:

<table>
  <thead>
    <tr>
      <th style="width:9%;text-align: center;">Icon</th>
      <th style="width:15%;">Name</th>
      <th>Functionality</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><center><img width="50%" style="margin:0;" src="https://img.ultipa.cn/img/2025-04-14-10-48-12-List.jpg"></center></td>
      <td><b>List</b></td>
      <td>Displays query results in a List view. This is the default view for results of types <code>NODE</code>, <code>EDGE</code>, <code>TABLE</code>, and <code>ATTR</code>.</td>
   </tr>
   <tr>
     <td><center><img width="50%" style="margin:0;" src="https://img.ultipa.cn/img/2025-04-14-11-01-47-2D.jpg"></center></td>
     <td><b>2D</b></td>
     <td>Displays query results in a 2D Graph view, which is the default view for results of type <code>PATH</code>. You can use the <b>Layouts</b> tool to switch to other layouts.</td>
   </tr>
   <tr>
     <td><center><img width="50%" style="margin:0;" src="https://img.ultipa.cn/img/2025-04-14-11-07-13-Layouts.jpg"></center></td>
     <td><b>Layouts</b></td>
     <td>Sets the layout of the 2D Graph view, including Force-direct, Tree, Dagre, ELK, and Circular. <a href="#Layouts">Learn more about layouts</a></td>
   </tr>
   <tr>
     <td><center><img width="50%" style="margin:0;" src="https://img.ultipa.cn/img/2025-04-14-15-23-21-3D.jpg"></center></td>
     <td><b>3D</b></td>
     <td>Displays query results in a 3D Graph view, which is the default view for results of type <code>PATH</code> when the number of nodes exceeds 200. The 3D view adds depth and spatial positioning to nodes and edges, reducing overlaps compared to the 2D view.</td>
   </tr>
   <tr>
     <td><center><img width="50%" style="margin:0;" src="https://img.ultipa.cn/img/2025-04-14-15-58-01-Map.jpg"></center></td>
     <td><b>Map</b></td>
     <td>Displays query results in a Map view. This is available only when <code>NODE</code> or <code>PATH</code> results include nodes with properties of the <code>point</code> type.</td>
   </tr>
   <tr>
     <td><center><img width="50%" style="margin:0;" src="https://img.ultipa.cn/img/2025-04-14-15-57-17-Style.jpg"></center></td>
     <td><b>Style</b></td>
     <td>Customizes the style of nodes and edges in the graph. <a href="#Style">Learn more about style</a></td>
   </tr>
   <tr>
     <td><center><img width="50%" src="https://img.ultipa.cn/img/2025-04-14-16-05-25-Search.jpg"></center></td>
     <td><b>Search</b></td>
     <td>Performs a fuzzy search for nodes whose specified property values are approximately equal to the given string. The matching algorithm uses a threshold of 0.3, where 0.0 requires a perfect match and 1.0 matches anything.</td>
   </tr>
   <tr>
     <td><center><img width="50%" style="margin:0;" src="https://img.ultipa.cn/img/2025-04-14-16-20-48-Filter.jpg"></center></td>
     <td><b>Filter</b></td>
     <td>Finds nodes and edges in the query results with the specified rules.</td>
   </tr>
   <tr>
     <td><center><img width="50%" style="margin:0;" src="https://img.ultipa.cn/img/2025-04-14-16-48-07-Export.jpg"></center></td>
     <td><b>Export</b></td>
     <td>Exports the query result as JSON, PNG, or XLSX.</td>
   </tr>
   <tr>
     <td><center><img width="50%" style="margin:0;" src="https://img.ultipa.cn/img/2025-04-14-16-52-28-Split-screen.jpg"></center></td>
     <td><b>Split Screen</b></td>
     <td>Splits the <b>Results Pane</b> into two panes.</td>
   </tr>
   <tr>
     <td><center><img width="50%" style="margin:0;" src="https://img.ultipa.cn/img/2025-04-14-16-56-26-Query-stats.jpg"></center></td>
     <td><b>Query Stats</b></td>
     <td>Displays the query's execution time (in milliseconds) and the number of records returned.</td>
   </tr>
  </tbody>
</table>

- The bottom-left corner has an **Open timeline** option to visualize how the data evolves over time. <a href="#Timeline">Learn more about timeline</a>

<center><img width="30%" src="https://img.ultipa.cn/img/2025-04-14-18-16-14-open-timeline.jpg"></center>

## Layouts

The layout of a graph visualization refers to how nodes are positioned, and edges are routed within the graph. Each layout has distinct characteristics that can help convey different aspects of the data. Ultipa Manager provides the following layouts for visualizing graphs in the 2D view:

**Force-directed:** This layout simulates physical forces—nodes repel each other while edges pull connected nodes together—until a balanced state is reached. It reveals community structures in the graph. However, its iterative nature makes it computationally intensive, especially for large graphs.

**Tree:** This layout is designed for tree structures, organizing nodes in a hierarchical, branching pattern. It supports non-layered arrangements, making it ideal for displaying clear parent-child relationships. While efficient and easy to read, it is limited to acyclic graphs without shared children.

**Dagre:** This layout is tailored for Directed Acyclic Graphs (DAGs) and arranges nodes in layered ranks to emphasize flow direction. It minimizes edge crossings to improve readability, making it well-suited for workflows, dependency graphs, and other structured, directional data.

**Eclipse Layout Kernel (ELK):** This is a flexible layout engine that supports multiple strategies, including layered (like Dagre), orthogonal, force-directed, and tree-based layouts. It is well-suited for large, complex graphs where layout customization, advanced edge routing, and fine-tuned control are required.

**Circular:** This layout arranges all nodes evenly along the circumference of a circle, with edges drawn as straight lines between them. It provides a symmetrical view that highlights central or highly connected nodes but can become visually cluttered as graph size and edge density increase.

## Style

In the Graph view, you can apply styles to nodes and edges, customizing their color, size, shape, and text labels for better clarity and emphasis.

> Styles created by different users in the same database are shared.

> If no custom style is applied, a default style is used, which assigns distinct colors to nodes and edges based on their respective schemas.

### Apply a Style

You can apply a style by selecting its checkbox:

<center><img width="60%" src="https://img.ultipa.cn/img/2025-04-14-15-40-11-apply-a-style.jpg"></center>

### Create a Style

Click **Style > Create** to define a new style. You may optionally name the style and add node and edge styles.

For each node or edge style, you can specify the applicable schemas and properties. Then,

- **Basic Style** allows you to configure shape, size, color, and label for nodes or edges.
- **Advanced Style** enables dynamic styling by setting color or size ranges based on the values of a numeric property.

> If you choose *Image* or *Circular Image* as the node shape, make sure the image URLs are stored in the specified node property.

If multiple node or edge styles are added, those listed lower in the order take precedence over those above. You can adjust the order by dragging and dropping the corresponding style cards.

### Import/Export Styles

Click **Style > Export** to export all styles as a .txt file. You can import this file into another database to transfer or back up style configurations.

## Canvas Operations

The canvas that displays the query results supports various operations for interacting with the graph:

### Hover Over Nodes and Edges

Hover over a node or an edge to view its schema and properties:

<center><img width="70%" src="https://img.ultipa.cn/img/2025-04-14-17-06-10-hover-on-node.gif"></center>

### Select a Node

Select (left-click) a node to access options for spreading from it:

- Click **Select Neighbors** to choose one or more direct neighbors to include in the spread.
- Click an option under **Spread by** to spread from the node through specific edge schema and direction to certain node schema.

<center><img src="https://img.ultipa.cn/img/2025-04-14-17-28-55-select-node.gif"></center>

### Right-Click a Node

Right-click a node to open a menu with the following options:

- **Edit:** Edit the node.
- **Delete:** Delete the node along with all its connected edges.
- **Hide:** Hide the node along with all its connected edges.
- **Lock/Unlock:** Lock or unlock the position of the node in the canvas.
- **Add Edge:** Add a new edge from this node.
- **Search More:** Spread from the node with the specified depth, direction, and other conditions.

<center><img width="70%" src="https://img.ultipa.cn/img/2025-04-14-17-12-32-right-click-on-node.gif"></center>

### Select an Edge

Select (left-click) an edge to access the following options:

- **Edit:** Edit the edge.
- **Delete:** Delete the edge.

<center><img width="70%" src="https://img.ultipa.cn/img/2025-04-14-17-50-58-select-edge.gif"></center>

### Canvas Menu

Right-click empty area on the canvas to open the canvas menu with the following options:

- **Add Node:** Add a new node.
- **Lock/Unlock All:** Lock or unlock the positions of all nodes in the canvas.
- **Collapse/Expand Edges:** Collapse or expand the multiple edges exist between any two nodes.
- **Collapse/Expand Nodes:** Hold the `Ctrl` key to select multiple nodes in the canvas and collapse them into a single representation. Click **Expand Nodes** to restore the original individual nodes.
- **Search More:** Spread from selected nodes in the canvas with specified depth, direction, and other conditions.

<center><img width="70%" src="https://img.ultipa.cn/img/2025-04-14-17-54-46-canvas-menu.gif"></center>

## Timeline

When `NODE` or `PATH` results include nodes or edges with properties of the `timestamp` or `datetime` type, the **Open timeline** button becomes available at the bottom-left of the canvas in the Graph view. This feature allows you to visualize how your data evolves over time.

The timeline range is determined by the minimum and maximum values of the properties selected under **Settings > Select time properties**. By default, the full range is selected, but you can adjust it by dragging the two handles. The selected slice filters the canvas to show only data whose properties fall within that range. Click **Play** to automatically move the slice across the timeline; the playback speed is controlled by the **Settings > Playback Duration**.

<center><img src="https://img.ultipa.cn/img/2025-04-14-18-24-11-timeline-settings.jpg"/></center>

Meanwhile, you have the option to display or hide nodes and edges with **No time property** and **Empty time property** under **Settings**.
