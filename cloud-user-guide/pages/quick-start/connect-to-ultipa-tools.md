# Connect to Ultipa Tools

You can connect your instances to Ultipa Tools such as Ultipa Manager or Ultipa CLI to exert the full capacity of Ultipa Graph.

## Prerequisites

The status of the target instance is **Active**.

If your instance is **Stopped**, start it from **Action > Start**.

## Connect to Ultipa CLI

On **Ultipa Graph** tab, find the target instance, and click **Connect > Ultipa CLI**.

<center><img src="https://img.ultipa.cn/img/2024-08-01-15-17-34-connect-to-cli.png"></center><br>

Enter the username "root" and your password and then connection to Ultipa CLI is completed.

<center><img src="https://img.ultipa.cn/img/2024-08-01-15-22-19-cli-connected.jpg"></center><br>

> For details about Ultipa CLI, see <a href="/docs/tools/cli" target="_blank">**Ultipa CLI**</a>.

## Connect to Ultipa Manager

On **Ultipa Graph** tab, find the target instance, and click **Connect > Ultipa Manager**.

<center><img src="https://img.ultipa.cn/img/2024-08-01-15-26-36-connect-to-manager.png"></center><br>

Log in to Ulitpa Manager with your Ultipa Cloud account. The first time connecting to Ultipa Manager for an instance, a window appears to add this instance to Ultipa Manager.

Fill in the form and click **Confirm**.

|  <div table-width=25>Parameter</div>| Description|
|--------- |----------|
| Hosts | Host address of the instance is automatically populated; you don’t need to change. |
| Username | Enter "root"; the root user was created for the database when setting up the instance. |
| Password | Enter the password of the root user. |
| Name | A custom name for this instance to display in Ultipa Manager. You may use the same name as the instance. |

<center><img src="https://img.ultipa.cn/img/2024-08-01-15-28-20-Manager.png"></center><br>

The green bar indicates that the instance is successfully connected to Ultipa Manager.

<center><img src="https://img.ultipa.cn/img/2024-08-01-15-34-00-open-instance.png"></center><br>

>  In case of changing the listening port after a successful connection to Ultipa Manager, you need to delete the existing connection that uses the previous listening port and create a new connection using the new listening port.

Click **Open** to start your work in Ultipa Manager.

<center><img src="https://img.ultipa.cn/img/2024-08-01-15-37-01-welcome-to-manager.png"></center><br>

> For details about Ultipa Manager, see <a href="/docs/manager-user-guide/introduction" target="_blank">**Ultipa Manager**</a>.
