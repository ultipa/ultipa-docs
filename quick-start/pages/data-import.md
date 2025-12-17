# Data Import

> This page shows how to use Ultipa Manager and Ultipa Transporter-Importer to import data files into a GraphSet.

Graph data used in this article comply to the graph model as introduced in [Prepare Graph](/docs/quick-start/prepare-graph)

## Data File

Prepare a CSV file for each schema in the graph model, which are [CUSTOMER.csv](https://img.ultipa.cn/resources/CUSTOMER.csv), [MERCHANT.csv](https://img.ultipa.cn/resources/MERCHANT.csv) and [TRANSACTION.csv](https://img.ultipa.cn/resources/TRANSACTION.csv). (click to download)

<center><img src="https://img.ultipa.cn/img/2023-05-11-10-57-52-node-file-model.png"></center>

- Columns led by headers `cust_no` in node file CUSTOMER.csv and `merchant_no` in node file MERCHANT.csv are system property `_id` of node
- The rest of columns are custom properties

<center><img src="https://img.ultipa.cn/img/2023-05-11-11-05-45-edge-file-model.png"></center>

- Columns led by headers `cust_no` and `merchant_no` in edge file TRANSACTION.csv are system properties `_from` and `_to` of edge
- The rest of columns are custom properties

## Import via Manager

- Import nodes before importing edges

### Step Breakdown (for node)

Take importing node file CUSTOMER.csv as an example, the operation includes 5 steps:

1. Create Loader

<center><img src="https://img.ultipa.cn/img/2024-02-19-15-55-22-add-loader.gif"></center>
<center><i>Chart1: Create a loader to import data into graphset retail_test</i></center>

2. Create Task

<center><img src="https://img.ultipa.cn/img/2024-02-19-16-09-14-add-task.gif"></center>
<center><i>Chart2: Create a task of CSV type to import node file CUSTOMER.csv</i></center>


3. Configure Settings

<center><img src="https://img.ultipa.cn/img/2024-02-19-17-00-18-task-settings.gif"></center>
<center><i>Chart3: Configure basic settings for the task</i></center>

Details of configuration items in **Settings** can be found in documentation of [Loader](/docs/manager-user-guide/loader).

4. Configure File

<center><img src="https://img.ultipa.cn/img/2024-02-19-17-15-25-task-file.gif"></center>
<center><i>Chart4: Upload CSV file, configure file format and map data fields with properties</i></center>

Tips when mappting data fields with properties:
- A red triangle <font color=red>△</font> for a **Property** indicates the header does not match with any property under the selected schema, in which case the respective property will be automatically created if the data of this header are to be imported (square box at the left most end checked)
- Configuration item 'Headless' should be checked if the CSV file is headless, in which case the first row of data indicated by the **Property** should be modified into property names as they each represent

Details of configuration items in **Files** can be found in documentation of [Loader](/docs/manager-user-guide/loader).

> Data files in this example use comma ',' as column delimiter and contain headers; header `cust_no` is system property `_id`.

5. Import

<center><img src="https://img.ultipa.cn/img/2024-02-19-17-28-42-task-import.gif"></center>
<center><i>Chart5: Import current task</i></center>

> Repeat from step-2 to step-5 to import node file MERCHANT.csv. Make sure in step-3 select <i>merchant</i> as schema and in step-4 select `_id` as Type of `merchant_no`.

### Complete Demo (for edge)

Repeat from step-2 to step-5 to import edge file TRASACTION.csv. Make sure in step-3 switch to 'Edge', in step-3 select <i>transfer</i> as schema and in step-4 select `_from` and `_to` as Type of `cust_no` and `merchant_no`.

<center><img src="https://img.ultipa.cn/img/2024-02-19-18-33-00-edge-import.gif"></center>
<center><i>Chart6: A complete demonstration of importing edge file TRASACTION.csv</i></center>

### Verification

<center><img src="https://img.ultipa.cn/img/2024-02-20-09-55-34-post-check.gif"></center>
<center><i>Chart7: a complete graph model with correct number of nodes and edges after a successful import</i></center>

## Import via Transporter

Comparing with Manager, the import operation via Transporter-Importer supports recognition of property types from file headers, such as:
<center><img src="https://img.ultipa.cn/img/2023-05-12-09-22-03-file-header-type.png"></center>

The import operation via Transporter-Importer includes 2 steps:

1. Prepare YML file

Declare information about Ultipa server and data files in a YML file. Below is part of the YML file:

<p run-tag="false" graph="" tit= "YML" type="yaml"></p>

```yml
nodeConfig:
  - schema: "customer"
    file: "./CUSTOMER2.csv"
  - schema: "merchant"
    file: "./MERCHANT2.csv"

edgeConfig:
  - schema: "transfer"
    file: "./TRANSACTION2.csv"
```

- Download the file package [YML_CSV](https://img.ultipa.cn/resources/YML_CSV.zip) that contains the complete YML file and the data files with updated headers
- Extract this package and keep all the files in one folder
- Make sure you update the server information in the YML file with the one you deployed

See annotations about parameters in the YML file, or read more about the YML file in [Import Config](/docs/transporter/import-ultipa-config).

2. Run Ultipa Importer in a command line tool

Place the Importer tool 'ultipa-importer' in the same folder with the extracted YML file and data files, run a command line tool under the same folder and execute command below:

<p run-tag="false" graph="" tit= "Terminal" ></p>

```bash
./ultipa-importer --config ./import_retail.yml
```

<img src="https://img.ultipa.cn/img/2023-02-27-18-19-06-transporter-import-rev.gif">

> Start a command line tool compatible with your system, e.g., right-click the blank space in the folder and click 'Open in Terminal' in an Ubantu system, or shift-right-click and 'Show More' and 'Open in Powershell' in a Windows system.

> If message is received as `bash: ./ultipa-importer: Permission denied` when running the above command, it suggests that relevant execution privileges are not granted; run `chmod +x ultipa-importer` to grant privileges required and run the command again.
