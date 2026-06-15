# Manager

**Manager** is a web platform for managing and interacting with your database instances. It offers a highly visualized and intuitive interface for data management and migration, querying and analytics, visualization, etc.

## Manger vs. Manager (Lite)

Each database instance (i.e., a **Graph Powerhouse**) includes a built-in **Manager (Lite)**, which can connect only to the specific database instance it was created with and offers a limited set of features.

In contrast, a standalone **Manager** instance provides the full feature set and can be used to manage all your database instances.

## Create an Instance

To begin, sign in to <a target="_blank" href="https://cloud.ultipa.com">cloud.ultipa.com</a>. Navigate to the **Ultipa Graph > Manager** section, click **Create** and select the **Standard** plan.

You can now proceed with the following setup:

<center><img src="https://img.ultipa.cn/img/2025-09-09-11-47-06-manager-instance-size.png"></center>

1. Choose your **Cloud server provider** and a **Region** that best suits your needs, typically one geographically close to your users.

2. Adjust **Storage** under the **Instance size** that meets your requirements.

3. Click **Next: Settings** to continue. Provide a **Manager name** and select the product **Version**. We recommend choosing the latest version unless your project has specific requirements. You can always update to a newer version as they are released.

4. Under **Network settings**, you can adjust the **Listening port** and **Allowed inbound IPs** for your instance. To allow unrestricted access, select **0.0.0.0 (Anywhere)**. <br>⚠️ **Warning:** This setting makes your instance publicly accessible and is not recommended for production environments.

<center><img src="https://img.ultipa.cn/img/2025-09-09-16-04-20-manager-network-settings.png"></center>

5. Click **Start** to create your instance. If a payment method has not yet been added to your account, you will be prompted to set one up before the instance is created.

6. A pop-up window will appear prompting you to save the *root* password for the instance. Be sure to download and save it properly.

<center><img width="60%" src="https://img.ultipa.cn/img/2025-09-09-12-03-06-manager-root-password.png"></center>

Instance initialization will take a few minutes. Once the process is complete, you'll be able to <a href="#Connect-to-an-Instance">connect to your instance</a>.

<center><img src="https://img.ultipa.cn/img/2025-09-09-12-03-10-manager-instance.png"></center>

## Connect to an Instance

To connect to your **Manager** instance, please ensure its status is **Active**. If the instance is stopped, click **Action > Start**. If it's already running but unresponsive, you can click **Action > Restart** to reboot the instance.

For an active **Manager** instance, simply click **Connect**:

<center><img src="https://img.ultipa.cn/img/2025-09-09-12-08-40-manager-connect.png"></center>

### Log in to Manager

**Ultipa Manager** opens in a new browser tab. The first time you connect, you will be prompted to sign in. You can log in either as an admin or as a normal user:

- **Admin login:** Enter the username *root* and the root password you saved during the instance's creation. If you forgot it, you can <a href="#Reset-Root-Password">reset the root password</a>.
- **Normal user login:** Click **Create account** to register, then sign in with the new account.

<center><img src="https://img.ultipa.cn/img/2025-09-09-12-13-10-manager-sign-in.jpg"></center>

### Add Instances

Once you're logged in to Ultipa Manager, you'll land on the **Instances** page, where you can add connections to your databases.

Click **New Connection** and provide your instance's connection details:

- **Hosts:** The public address of the instance.
- **Username:** Enter a database username.
- **Password:** Enter the password of the database user.
- **Name:** Optional custom instance name.

Click **Confirm** to save the connection.

<center><img src="https://img.ultipa.cn/img/2025-09-09-15-11-44-manager-add-instance.jpg"></center>

Click **Open** to enter the database instance, for details on features available in **Manager** within an instance, see the <a target="_blank" href="/docs/manager-user-guide">Ultipa Manager User Manual</a>.

<center><img src="https://img.ultipa.cn/img/2025-09-09-15-52-38-manager-open-connection.png"></center>

## Control the Instance

You can control your instance using the **Stop**, **Restart**, and **Terminate** found under the **Action** menu:

<center><img width="40%" src="https://img.ultipa.cn/img/2025-09-09-15-55-44-manager-actions.png"></center>

### Restart

If your instance is running but becomes unresponsive, you can **Restart** it to restore its functionality.

### Stop

To save on costs when an instance is not in use, you can **Stop** it. While stopped, you will only be charged for storage.

### Terminate

To permanently delete your instance and all of its data, click **Terminate**.

⚠️ **Warning:** Terminating an instance is a final, irreversible action. All data and configurations will be completely and irrevocably deleted.

## Version Update

You can check and update the version of your **Manager** instance by clicking **Action > Configure**. Any available update for it will be displayed in this section.

<center><img src="https://img.ultipa.cn/img/2025-09-09-15-58-53-manager-update.png"></center>

## Reset Root Password

To reset the password for the *root* user of the Manager, click **Action > Configure** and scroll down to the **Account setting** section.

<center><img src="https://img.ultipa.cn/img/2025-09-04-14-22-47-reset-root-pw.png"></center>

## Change Instance Configuration

To adjust your **Network settings**, click **Action > Configure**.

<center><img src="https://img.ultipa.cn/img/2025-09-09-16-02-17-manager-network-settings.png"></center>
