# Release Notes

This page provides the release notes for Ultipa Manager. These notes detail major features, bug fixes, performance improvements, and other changes introduced in each version.

## beta_5.1.39-s5.0 (2025-04-03)

- GQL is now supported.
- Added more layout options and support for multi-selection of nodes and edges, box selection, and lasso tools.
- HDC is now supported.
- Widget is revamped with the React framework; sharing widget now uses a connection token.
- New Admin Management: Manage users, groups, connections, and global configurations; supports session sharing and MFA (Multi-Factor Authentication).
- Achieved compatibility with Ultipa Server v5.0.
- Fixed known issues.

## beta_4.5.12-s4.4 (2025-02-28)

- Widget now supports PowerBI embedding.
- Forms in Widget now supports dragging.

## beta.4.4.66-s5.0 (2024-10-11)

- Updated the HDC module.
- Fixed the issue where the version doesn't show.
- Fixed known bugs.

## beta.4.4.65-s5.0 (2024-09-25)

- Optimized the animation when switching graphsets.
- Modified the graphset list.
- Modified the left menu style.
- Fixed known bugs.

## beta.4.4.64-s5.0 (2024-09-04)

- Introduced new language: French.
- Updated the algorithm installation feature in the HDC module.
- Fixed known bugs.

## beta.4.4.63-s5.0 (2024-08-13)

- Updated the typing fields.
- Optimized the timeline layout.
- Fixed issues related to schema counting.
- Fixed known bugs.

## beta.4.4.62-s5.0 (2024-07-17)

- Introduced features to support the 5.0+ server.

## v4.4.90-s4.4 (2024-07-01)

- Added support for ldap authentication.
- Optimized the export of `decimal` type properties.
- Fixed known bugs.

## v4.4.85-s4.4 (2024-06-21)

- Added Loader Scheduler to trigger the Loader based on various timing rules.
- Optimized Loader features for improved performance.
- Fixed an issue where an extensive Widget list prevented the UQL Editor from opening.
- Fixed known bugs.

## v4.4.78-s4.4 (2024-05-14)

- The issue of other loaders being executed alongside a specific loader has been resolved.
- The display issue with the progress bar when the filename in load tasks contains special characters has been fixed.
- Optimizations have been made to the UQL Editor.
- Fixed known bugs.

## v4.4.65-s4.4 (2024-04-23)

- Fixed the import issue when the delimitor of the CSV file is `;` or `|`.
- Fixed known bugs.

## v4.4.63-s4.4 (2024-04-03)

- Implemented a server-side clean-up mechanism for import logs generated in Loader.
- Introduced edge filtering in the timeline visualization.
- Optimized the UQL Execution History for improved usability.
- Optimized the sharing feature for widgets.
- Streamlined the preview and import feature for Loader.
- Added Daemon configuration for instances to control the server nodes' start or stop operations.
- Fixed known bugs.

## v4.4.54-s4.4 (2024-03-11)

- Loader now supports more data sources, including MySQL, SQL Server, PostgreSQL, JSON, JSONL, Kafka, Neo4j and BigQuery.
- Added support for configuring time format.
- Fixed known bugs.

## v4.4.42-s4.4 (2024-02-15)

- Updated the highlight and hint feature for UQL Editor.
- Fixed the issue where the Result Pane could not be split during loading.
- Fixed known bugs.

## v4.4.35-s4.4 (2024-01-12)

- Removed the use of backticks (\`) for wrapping schema and property names that do not contain special characters.
- Updated various UI text elements.
- Fixed known bugs.

## v4.4.23-s4.4 (2023-12-21)

- Optimized the information window of collapsed edges.
- Optimized large file export.
- Fixed known bugs.

## v4.4.20-s4.4 (2023-11-16)

- Fixed the issue in the Loader where the selected data type was lost when switching between nodes and edges.
- Removed the graphsets preview feature on each instance card.
- Fixed known bugs.

## v4.4.16-s4.4 (2023-10-27)

- Added the Widget module, replacing the Shortcut module; added support for writing CSS and HTML, and importing third-party packages.
- Added an execution window for Widget.
- Optimized the Loader model, including validation prompts and file deletion.
- Adjusted the style of the left navigation bar.
- Optimized the UQL results panel, including the executed statements list and the toolbar layout.
- Added support for the decimal and set data types.
- Added support for the toGraph structure.
- Fixed known bugs.

## v4.3.2.48 (2023-10-24)

- Added the Loader module in replace of the Files module.
- Supports uploading and importing one CSV file per loader.
- Supports importing data to all graphsets in the instance (not only the current graphset).
- Supports executing single loader.
- Supports executing multiple loaders in serial or parallel mode.
- Moved the data export function to graphset operational list.

## v4.3.72 (2023-09-01)

- Added support for the blob data type.
- Enabled the utilization of SDK methods such as `asNodes`, `asEdges`, `asPaths`, `asAttrs`, `asTable`, etc. when editing Shortcuts.
- Fixed some bugs.

## v4.3.62 (2023-08-17)

- Enhanced the Shortcut module, enabling debugger support in web browsers and log verification.
- Introduced configurations for force-directed and circular layouts.
- Included Tree and Circular layouts in the canvas menu within the 2D view.
- Implemented automatic transition to single-line mode in the UQL Editor when the code is reduced to one line or empty.
- Addressed various other bugs and issues.

## v4.3.52 (2023-07-28)

- Implemented Watermark functionality within the Settings.
- Added Manager Privileges for users in the Auths module.
- Enhanced the Style Management with Color Picker and Property selection when choosing colors.
- Added the Map layout for returned results containing data of the point type.
- Added the Timeline layout for returned results containing data of the datetime or timestamp type.
- Implemented detailed information display for nodes and edges when hovering the mouse over them.
- Integrated Echarts into the Shortcut module.
- Integrated Highcharts into the Shortcut module.
- Redesigned the panel layout and content of the Algos module.

## v4.3.38 (2023-06-16)

- Added variable types into the form in shortcut.
- Added the sharing function to the shortcut.
- Added animation effects to menus and buttons.
- Addressed various known bugs and issues.

## v4.3.28 (2023-05-06)

- Launched a new Plugin module to extend functionality.
- Implemented rules for importing and exporting styles.
- Included *\_uuid* in the dropdown menu of the label when configuring node and edge style.
- Enhanced algorithm execution by adding the `exec task` prefix based on the cluster information.
- Fixed other known bugs.

## v4.3.21 (2023-04-17)

- Enhanced compatibility with Ultipa server v4.3, now supporting null values, list types, and point types.
- Implemented distinct display for null objects and null strings.
- Enabled editing components of the list type.
Optimized the data export process for improved efficiency.
- Added support for copying the table header in the results.
- Enabled the deletion of edges in Schema Overview.
- Enhanced 2D styles and layouts for better visualization.
- Resolved the issue related to switching between split screens when executing selected UQL statements.

## v4.2.50 (2023-04-11)

- Enhanced the color gradient algorithm.
- Optimized the spacing of Tree layouts.
- Improved 2D styles for better visualization.
- Enhanced the functionality of the UQL Editor.
- Improved the display of PATH lists.
- Resolved system glitches occurring when displaying a large number (over 760) of node and edge tables in the result list.
- Added 100 templates to the UQL Editor for increased usability.
- Implemented sorting functionality for the Shortcut list.
- Added support for selecting icon color and font color in 2D view styles.
- Fixed errors related to algorithm return values.
- Addressed various known bugs for improved stability.

## v4.2.39 (2023-03-08)

- Enhanced the functionality of the 2D view style panel for improved customization.
- Implemented drag-and-drop sorting for the data source list to simplify organization.
- Added support for pausing, canceling, and resuming the uploading of CSV files for better control.
- Resolved an issue where UQL records could not be deleted from the UQL History window after searching and locating specific records.
- Fixed a bug where, in split-screen mode, when executing a selected UQL query, the screen displays "Loading" all the time even though the results are returned already.
- Addressed the issue where executing `show().node_schema()` and `show().edge_schema()` return a list of all schemas.
- Corrected the icon of viewing schema.

## v4.2.33 (2023-02-20)

- Fixed the issue where exported data is empty when the property name begins with an underscore.
- Optimized the flickering problem in the 3D view.
- Fixed the issue where UQL executions in new graphets don't carry the timezone.
- Corrected the authentication interface parameters.

## v4.2.30 (2023-02-13)

- Allows inclusion of special characters in the names of schemas, properties, and aliases, and applies other changes in the naming rule according to the Ultipa server.
- Supports adjustment of the height of the UQL Editor.
- Supports saving UQLs to the server for each server user.
- Adjustments have been made to the user password updating process.
- Fixed the issue of the application getting stuck when bulk uploading algorithms.
- Fixed the problem of not displaying returned aliases.
- Fixed the issue of viewing historical UQLs using the keyboard arrow keys.
- Fixed some other bugs.
