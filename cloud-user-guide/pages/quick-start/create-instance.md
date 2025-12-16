# Create Instance

## Prerequisites

Ensure that you have an Ultipa Account to log in to Ultipa Cloud.

If not, go to <a href="https://www.ultipa.com" target="_blank"> www.ultipa.com</a> or <a href="https://cloud.ultipa.com" target="_blank"> cloud.ultipa.com</a> to sign up.

## Deploy A Cloud Database

### Create an Instance

Log in to <a href="https://cloud.ultipa.com" target="_blank"> Ultipa Cloud</a>.

On **Ultipa Graph** tab, click **+Create** or **Create Now** on the right to start deploying an Ultipa graph database instance.

<center><img src="https://img.ultipa.cn/img/2024-07-12-16-16-13-create-an-instance.png"></center><br>


### Select Database Type

Ultipa Cloud offers three types of database, including Shared, Standard and Enterprise. Select according to your needs and click **Create**.

The sample case goes with **Shared** one.

<center><img src="https://img.ultipa.cn/img/2024-07-11-15-07-48-database-types.png"></center><br> 

Comparison of different database types is shown below:
|  <div table-width=25>Functionality</div>| Shared | Standard | Enterprise |
|--------- |----------|----------|----------|
|Specification| For learning and exploring the cool features by Ultipa Graph with minimal cost. | For application development and testing. Minimal configuration required.|For production applications with sophisticated workload requirements. Advanced configuration controls.|
|vCPU | 2 | 192 | Unlimited |
|Memory| 8G | 2T | Unlimited|
|Storage| 40G | 4T |Unlimited|
|Superfast Graph Algos<sup>(1)</sup>| Support |Support| Support|
|Advanced Graph Algos<sup>(1)</sup>| N/A | N/A |Support|
|Convenient CLI toolkit| Support |Support| Support|
|2D/3D Manager|Support |Support| Support|
|HTAP (OLTP \& OLAP)<sup>(2)</sup>| N/A | N/A |Support|
|Dynamically Resizable| N/A |Support| Support|
|Support Service|Forum Support: Official Q\&A platform and Discord community. Click <a href="https://指向help" target="_blank"> help</a> for details. | Friendly Online Support |7\*24 Technical Support|
|Price<sup>(3)</sup>| Pay-as-you-go, starting from $0.61/hr | Pay-as-you-go, starting from $1.14/hr | Contact the team for pricing|
  
<sup>(1)</sup> Superfast Graph Algos include the most frequently used graph algorithms with improved design from Ultipa, and Advanced Graph Algos cover all graph algorithms supported by Ultipa Graph.

<sup>(2)</sup> HTAP (OLTP \& OLAP) is an enterprise-exclusive provision, and supports HTAP high availability cluster deployment and computing performance.

<sup>(3)</sup> Ultipa Cloud service is measured and billed on a per-second basis, so the actual payment can be much lower than the price here. 

### Confirm Database Type

In this step, you can change the database type between Shared and Standard, and set Region and Instance Size according to your needs. 

> <b>Note</b>: Region and Instance Size are fixed for Shared type but modifiable for Standard type.

Click **Next: Settings** after confirmation.

<center><img src="https://img.ultipa.cn/img/2024-07-12-16-23-44-instance-type.png"></center><br> 

## Complete Basic Settings

### Instance Name

Give your instance a tag (up to 128 bytes) to find and manage it later.

### Version

Select the version of Ulitpa Graph according to your needs. Recommend keeping the default latest version.

### Network Settings

|  <div table-width=25>Parameter</div>| Description|
|--------- |----------|
| Listening Port | Fixed for **Shared** type. Restart the instance to change the port for **Standard** type. |
| Inbound Allowed IPs| Click **Add IP** to include the IP into the allowlist for later access. |

### Server Configuration

|  <div table-width=25>Parameter</div>| Description |
|--------- |----------|
| Memory Threshold | The maximum allowable memory usage. It can help protect system from out-of-memory (OOM). Recommend keeping the default 80%. |
| Log Level | Level of logs to be output. Recommend keeping the default Level 3. |
| Node ID Cache | The size of *'_id (customized ID) → _uuid (DB engine ID) mapping'*, used to speed up inserting operations. More IDs need more memory. | 

### Instance Advanced Configuration

Enabling **Short UUID** can help reduce large memory usage. The maximum node and edge number in a single graph will be limited to 4 billions.

Click **Next: Account**.

<center><img src="https://img.ultipa.cn/img/2024-07-12-16-32-49-Settings.png"></center><br>

## Set Account

Set the password for Ultipa Graph's root user. Then click **Next: Review and Start**.

<center><img src="https://img.ultipa.cn/img/2024-07-12-16-34-51-Account-setting.png"></center><br>

## Review and Start

Review all the configuration of your instance. For modification, click the pencil icon.

When the configuration is reviewed and confirmed, click **Start** to initialize your instance.

<center><img src="https://img.ultipa.cn/img/2024-07-12-16-35-55-Review.png"></center><br>

### Set Payment Method

If the payment method is not set before, a pop-up window will appear after you click **Start**. 

Enter relevant information of your credit card and click **Submit**. 

<center><img src="https://img.ultipa.cn/img/2024-07-12-16-38-10-payment-method.jpg"></center><br>

> <b>Note</b>:You may also susbcribe to our service via AWS Marketplace. For details, see <a href="https://www.ultipa.com/docs/cloud-user-guide/subscribe-via-aws-marketplace/" target="_blank">**Subscribe via AWS Marketplace**</a>.
