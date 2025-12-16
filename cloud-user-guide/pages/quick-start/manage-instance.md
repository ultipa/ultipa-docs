# Manage Instance

On **Ultipa Graph** tab, you can click **Action** to view, stop, start, restart, configure, clone and terminate your instances. 

<center><img src="https://img.ultipa.cn/img/2024-08-01-15-47-03-Action.png"></center><br> 

## Instance Status and Operations

Instance under different status supports specific operations. 

|<div table-width = "15"> Status / Action\*</div> | <div table-width = "25">Description</div> | <div table-width = "8">Connect</div> |<div table-width = "8"> Start</div> | <div table-width = "8">Stop</div> | <div table-width = "10">Restart</div> | <div table-width = "10">Terminate</div> | <div table-width = "10">Configure</div> | <div table-width = "15">Overview \& Logs</div> |
| ----- | --- |-- |---- |---| --- | --- |---|---|
| Active | Instance is ready to connect to Ultipa tools. | √ | × | √ | √ | √ | √ | √ |
| Stopped | Instance is stopped. | × | √ | × | × | √ | √ | × |
| Error | Instance or system is not functioning. | × | × | × | × | √ | × | × |
| Initializing | Instance is being initialized. | × | × | × | × | × | × | × | × |
| Starting | Instance is starting. | × | × | × | × | × | × | × |
| Restarting | Instance is being restarted. | × | × | × | × | × |  × | × |
| Updating |Instance is being updated. | √ | × | × |  × | × | × | √ |
| Stopping | Instance is being stopped. | × | × | × | × | × | × | × |
| Backing Up | Instance data is being backed up. | × | × | × | × | × | × | √ |
| Recovering | An instance backup is being recovered. | × | × | × | × | × | × | × |
| Emptying | Instance data is being cleared. | × | × | × | × | × | × | × |

*\* For an instance status, actions marked with √ are operable while actions marked with × are not operable.*


## View

When the status of the instance is Active, click **Action > View** to view CPU usage, memory usage, disk usage and logs of the instance. 
<center><img src="https://img.ultipa.cn/img/2024-08-01-15-49-25-view-instances.jpg"></center><br> 

## Start 

When the status of the instance is Stopped, click **Action > Start** to start it. The starting process may take some time.

<center><img src="https://img.ultipa.cn/img/2024-08-01-15-52-06-start-the-instance.png"></center><br> 

## Stop

When the status of the instance is Active, click **Action > Stop** to stop it. The process may take some time.

<center><img src="https://img.ultipa.cn/img/2024-08-01-15-53-49-stop-the-instance.png"></center><br> 

> <b>Note</b>: When an instance is stopped, it is only charged for storage usage. 

## Restart

Click **Action > Restart** to restart the instance when needed. The process may take some time. 

<center><img src="https://img.ultipa.cn/img/2024-08-01-15-55-18-restart.png"></center><br> 

## Configure

Click **Action > Configure** to change the instance configuration.

<center><img src="https://img.ultipa.cn/img/2024-08-01-15-57-57-configure-instance.png"></center><br> 

### Reset Password

Scroll down to Account Setting, and click **Reset password** to change password for the **root** user.

<center><img src="https://img.ultipa.cn/img/2024-07-15-10-28-04-reset-password.png"></center><br> 

### Backup 

Scroll down to Account Setting, and click **Backup** to back up present data in an active instance. You can create multiple backup instances for an instance and add tags to differentiate them.

<center><img src="https://img.ultipa.cn/img/2024-07-15-10-32-35-backup-step-1.png"></center><br> 

<center><img src="https://img.ultipa.cn/img/2024-07-15-10-33-15-backup-step2.png"></center><br> 

### Recover

Scroll down to Account Setting, and click **Recover** to restore all data to a backup version. 

<center><img src="https://img.ultipa.cn/img/2024-07-15-10-44-44-recover.png"></center><br> 

> <b>Note</b>: After recovered to a backup version, the instance will be automatically restarted.

### Empty

Scroll down to Account Setting, and click **Empty** to clean all data in the instance. 

<center><img src="https://img.ultipa.cn/img/2024-07-15-15-59-40-empty.png"></center><br>

> <b>Note</b>: "Empty" does not clear backups. You can recover instance data to a selected backup version.

### Change Instance Size

You can change the instance size for an instance of **Standard** or **Enterprise** type. **Shared** instance is not supported.

Stop the instance first, and then click **Action > Configure > Change Instance Size**. 

On the pop-up window, select the new configuration you want, and then click **Update**.

<center><img src="https://img.ultipa.cn/img/2024-07-15-10-59-50-change-instance-size.png"></center><br>

> <b>Note</b>: After changing the instance size, the instance will be automatically restarted.

### Change Storage Size

You can change the storage size for an instance of **Standard** or **Enterprise** type. **Shared** instance is not supported.

<center><img src="https://img.ultipa.cn/img/2024-07-15-11-10-38-change-storage-size.png"></center><br>

## Clone

Click **Action > Clone** to quickly set up another instance using the configuration of the current instance. You can change the configuration by clicking the pencil icon. 

As each instance requires an independent root password, scroll down to **Account Setting** and set a new password for this new instance. After reviewing all the information, click **Start**.

<center><img src="https://img.ultipa.cn/img/2024-08-01-16-02-26-clone-instance---reconfig.jpg"></center><br>

> If you choose not to set the instance name manually by modifying **Configuration**, system will generate a name with the following naming convention: the first four characters from the existing instance's name, C (stands for "Clone"), and a random number for distinguishment. For example, the clone instance of "My 1st Instance" could be named as "My 1_C031562".


## Terminate

> <b>Warning</b>: To terminate an instance means to delete the instance and all data contained completely, which is irrevocable and unrecoverable. 

Click **Action > Terminate**, enter the instance name and click **Terminate**. 

<center><img src="https://img.ultipa.cn/img/2024-08-01-16-04-05-terminate.jpg"></center><br>

null
