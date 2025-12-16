# UQL Editor

The **UQL Editor** can be accessed at the top of the right panel in almost all functional modules in Ultipa Manager.

Here is an overview of the features:

<center><img src="https://img.ultipa.cn/img/2024-01-09-11-18-09-UQL-Editor-v3.jpg" ></center>

## User & Graphset

The names of the current database user and graphset are displayed. You can click on the graphset name to view all the graphsets within the instance and switch to another one as needed.

## UQL Editing Area

You can write UQL in the editing area. The UQL Editor provides hints for commands, keywords, parameters, as well as the schemas and properties in the current graphset. Different elements of the UQL are displayed in different colors to improve readability and understanding.

> When interacting with the Ultipa Manager interface, certain actions, such as clicking the <i>View</i> icon of a schema, will result in the corresponding UQL being sent to the UQL Editor. In some cases, you need to execute the UQL manually to complete the action. 

### Keyboard Shortcuts

| Function | Single Line | Multi-line |
| -- | -- | -- |
| Run UQL | Enter |  Ctrl + Enter |
| Line Break | Shift + Enter | Enter |
| History UQL | Up/Down | Ctrl + Up/Down |
| Close Hint | Tab | Tab | 

## Run

Click the <b>Run</b> icon located on the right side of the editor to execute the entire UQL code written in the editing area.

Additionally, UQL Editor provides the flexibility to choose a portion of the code and execute it by clicking the <b>Run</b> icon that appears in front of the selection area:

<center><img width="500" src="https://img.ultipa.cn/img/2023-08-28-10-56-48-run.jpg" ></center>

## Favorite

Click the <b>Favorite</b> icon to add or remove the UQL codes from the editing area to your <b>Favorite UQLs</b>, which you can access in the <a href="#Records">Records</a> section.

## Records

Click the <b>Records</b> icon to open the <b>UQL Records</b> window. This window includes lists of <b>History</b> and <b>Favorite UQLs</b>, with each list saving a maximum of 100 UQL records.

<center><img src="https://img.ultipa.cn/img/2024-01-09-11-22-06-records.jpg" ></center>

When clicking on any record in this window, the corresponding UQL will be immediately sent to the UQL editing area, overwriting any existing content. To delete a record, simply click the <b>×</b> icon located on the right side of each UQL entry.

## Open Widget

Click the **Widget** icon to open the list of published widgets.

In the list of **Widgets**, you can pin commonly used widgets to the **Pinned** list for quick access.

<center><img src="https://img.ultipa.cn/img/2024-01-09-11-29-15-widget.jpg" ></center>

> Manage all widgets with the <a href="https://www.ultipa.com/docs/manager-user-guide/widget">Widget</a> module.
