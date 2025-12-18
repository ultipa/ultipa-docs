# Widget

You can expand the functionalities of Ultipa Manger through the **Widget** module. Developers can implement advanced custom applications and solutions as widgets. Users familiar with UQL can also benefit by creating widgets that execute specific UQLs as shortcut. 

The widgets published can be conveniently accessed by users within Ultipa Manager and embedded into any other webpages.

## Code Editor

The widget code editor has three sections: **Template** (HTML), **Style** (CSS), and **Script** (JavaScript). 

> The current version of Widget does not facilitate the use of multiple HTML, CSS, and JavaScript files. It is specifically designed for smaller-scale creations.

### Template

The Template section uses the Handlebars template. Codes written in this section are incorporated into the `<body>` tag in the final HTML output. In the current version, access to the other elements in the `<html>` tag, such as `<head>`, is not provided.

> There is no need to include the DOCTYPE, html, head, or body tags in this section; all these tags are built into the editor by design.

Handlebars uses double curly braces `{{ }}` to denote expressions that will be replaced with actual values during rendering.

<p tit="Template"></p>

```js
<h1>{{text}}</h1>
<!-- Value of the variable 'text' is set in the script -->
```

### Style

The Style section employs Less as the CSS preprocessor. Codes written in this section are included at the end within the `<head>` tag in the final HTML output.

<p tit="Style"></p>

```js
body {
  font-family: system-ui;
  background: #eff3f4;
  color: #00B0F0;
  text-align: center;
}
```

### Script

In the Script section, initial steps should be:

1. Import the template and style.
2. Define and instantiate a child class of `ModuleInterface` with proper script logic.

#### 1. Render with Custom Layout

<p run-tag="false" tit="Script" fold="true"></p>

```js
import "./index.less"
import template from "./index.hbs"
const { ModuleInterface } = require('@/core/module.interface')

class ManagerModule extends ModuleInterface {
    constructor(name, template) {
        super(name, template)
    }

    init() {
        console.log("Initialized init",this.__name)
    }

    async execute() {
        // Set the value of the variable 'text' contained in the template
        this._render({ text: "My first widget!" })	
    }
}

window._managerModule = new ManagerModule("helloUltipa", template)
```

Results Preview:

<center><img src="https://img.ultipa.cn/img/2024-01-03-16-30-02-test.jpg"></center>

#### 2. Render with Default Layout

In most cases, when aiming to send an UQL and receive the server response, it's essential to utilize an instance of the `Client` class and render the query results using the default Ultipa layout.

<p run-tag="false" tit="Script" fold="true"></p>

```js
import "./index.less"
import template from "./index.hbs"
const { ModuleInterface } = require('@/core/module.interface')
const { Client } = require('@/core/utils')

class ManagerModule extends ModuleInterface {
    constructor(name, template) {
        super(name, template)
    }

    init() {
        console.log("Initialized init",this.__name)
        this.client = new Client()
    }

    async execute() {
        const resp = await this.client.uql('n().e().n() as p return p{*} limit 10')
        this._renderUltipaData(resp)
    }
}

window._managerModule = new ManagerModule("helloUltipa", template)
```

Results Preview:

<center><img src="https://img.ultipa.cn/img/2024-01-03-16-44-11-test.jpg"></center>

<span style="color: #999;">*Note: This example retrieves 10 paths from the currently selected graph and applies the currently selected style for that graph. Therefore, the outcome may vary for you.*</span>

> If you intend to render data not retrieved from Ultipa Graph with the default layout, ensure that the data structure complies with the server response before passing it into `_renderUltipaData()`.

#### 3. Import Third-Party Libraries and Frameworks

The following is a list of dependencies loaded with the JavaScript editor:

<p run-tag="false" tit="Script" fold="true"></p>

```js
dependencies:{
    "3d-force-graph": "^1.73.0",
    "@cosmograph/cosmos": "^1.4.1",
    "@googlemaps/polyline-codec": "^1.0.28",
    "@turf/turf": "^6.5.0",
    "@ultipa/fetch2": "^0.0.7",
    "ag-grid-community": "^30.2.1",
    "axios": "^1.6.1",
    "echarts": "^5.4.3",
    "handlebars": "^4.7.8",
    "highcharts": "^11.2.0",
    "highlight.js": "^11.9.0",
    "json-formatter-js": "^2.3.4",
    "jstoxml": "^3.2.10",
    "leaflet": "^1.9.4",
    "lodash": "^4.17.21",
    "moment": "^2.29.4",
    "vis-data": "^7.1.9",
    "vis-network": "^9.1.9",
    "vkbeautify": "^0.99.3"
}
```

To load some of them:

<p run-tag="false" tit="Script"></p>

```js
import * as echarts from 'echarts'
import axios from 'axios'
```

If the library or framework needed is not included in the list, load the external JavaScript file asynchronously during initialization:

<p run-tag="false" tit="Script"></p>

```js
...
class ManagerModule extends ModuleInterface {
    ...
	
    async loadJS(url) {
        let response = await axios(url)
        eval(response.data)
    }

    async init() {
        await this.loadJS("https://code.jquery.com/jquery-3.6.0.min.js")
        this._render()

        ...
    }
    
    ...
}
```

## Form Configurations

### Construct the Form

You can integrate variables requiring user input into the form and pass the variable's value to the script.

For each variable, you need to configure the following:

| <div table-width="20">Item</div> | Description | Specification |
| -- | -- | -- |
| Variable | Name of the variable | Must be consistent with what is specified in the script |
| Label | User-friendly label for the input | / |
| Placeholder | Placeholder for the input | / |
| Type | Type of the variable | Certain types offer further configurations |

Here are the data types associated with each (variable) type:

| Type | Data Type |
|-|-|
| String		| string	|
| Number		| number	|
| Node_Input	| string (node ID)	|
| Radio			| string	|
| CheckBox		| []string	|
| Select		| string or []string	|
| Schema		| string	|
| Property		| string	|
| Date Time		| string	|
| UQL			| string	|

### Call a Form Item in Script

You can pass `formData` into the `execute()` function and retrieve the value of a variable using `formData?.<variable_name>`:

<p run-tag="false" tit="Script"></p>

```js
...
class ManagerModule extends ModuleInterface {
    ...

    async execute(formData) {
        // The variable name in this example is 'limitNo' with the type Number; set the default as 1
        const resp = await this.client.uql(`find().nodes() as n return n{*} limit ${
          formData?.limitNo || 1
        }`)
        this._renderUltipaData(resp)
    }
    
    ...
}
```

## Compile, Test, and Publish

### Compile

Click the **Compile** button before testing or publishing the widget. Compile is needed for any code modification.

### Test

Click the **Test** to run the widget. Edit any user-input variables by clicking the gear icon next to the button.

Review the results in the **Results Preview** pane.  If the script contains any UQL, please note that the widget is executed on the currently selected graph. 

Additionally, when it's rendered with the default layout, the **Results Preview** pane only supports the default style. To apply custom styles, please first publish the widget, then nagivate to the widget by clicking the widget icon next to the **UQL Editor** and run it.  

### Publish

Click the **Publish** button to publish the widget. Published widgets are accessible by clicking the Widget icon available in some modules.

Re-publish if any change is made to the widget.

<center><img src="https://img.ultipa.cn/img/2024-01-03-18-02-18-widgets.jpg"></center>

## Settings

<center><img src="https://img.ultipa.cn/img/2024-03-04-10-39-49-widget-config.jpg"/></center>

Click the icon next to the widget name on the widget settings. From there, you can rename the widget, edit description, and set the thumbnail (the recommended size is 180px\*180px). 

You can also enable the **\<iframe\>** option, providing an `<iframe>` element to be used in another HTML file to display the widget on that webpage before the set expiration date. The `<iframe>` element has a `src` attribute that specifies the URL of the webpage to be embedded, and it includes the following parameters:

| <div table-width=25>Parameter</div> | Description | <div table-width=15>Specification</div> |
| -- | -- | -- |
| shortCutId | ID of the shortcut | / |
| params | All variables and their values set in the Test form | / |
| theme | Display theme | `light`, `dark` |
| colorStyleSelected | ID of the currently selected <a href="/docs/manager-user-guide/result-pane#Style">style</a> | / | 
| shareToken | Cookie generated for using the widget in another webpage | / |

The `<iframe>` element is regenerated when you uncheck and re-check the **\<iframe\>** option or change the expiration date.

## Import/Export Widget

You can export any widget as a ZIP file from the widget card. Click the **Import** button on the Widget main page to import a widget.

<center><img src="https://img.ultipa.cn/img/2024-01-03-18-09-29-import-export.jpg"/></center>