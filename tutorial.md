# Build and deploy a flexible modern dashboard in minutes
Technologies discussed here: **AWS**, **MySQL**, **web development**. 

# Step 1: AWS. Sign up for the cloud computing platform

This tutorial makes use of the following services in the AWS portfolio: **RDS**, **Lambda**, **S3**. AWS is a paid service and will ask you for billing information, but using these services as described in this tutorial is free. RDS, Lambda, and S3 can be used extensively enough under [free tier](https://aws.amazon.com/s/dm/optimization/server-side-test/free-tier/free_np/) to support a fully featured website.

# Step 2: RDS. Launch a database server

This tutorial makes use of **MySQL 5.7** and celebrates that release for its addition of [**JSON functions**](https://dev.mysql.com/doc/refman/5.7/en/json-functions.html) inside an otherwise relational database management system. We do not go into details on installing, running, and maintaining a MySQL server here, let’s quickly configure RDS to do all that.

## 2.1. Create a Parameter Group

Open this file: 

    rds/parameter_group_diff.csv

Once you’re signed up for AWS, go to the RDS dashboard and then Parameter Groups. RDS manages your database servers and associated entities, such as parameter groups. A parameter group sets [Server System Variables](https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html) for MySQL. Before launching a DB instance, let’s create a custom parameter group. If we do this now, before the server is running, we won’t have to modify and restart it later.

Creating a custom parameter group is an optional step. RDS has a default parameter group that works for most applications, but this tutorial breaks RDS expectations in these ways:

- aggregation of more than 1 KB of data into a single cell of a table
- creation of routines and triggers

Therefore we need to create a custom parameter group. On creation, select this parameter group family: **mysql5.7**. Once created, edit parameters to match the values in `parameter_group_diff.csv`.

## 2.2. Launch a DB instance

Open this file: 

    rds/instance_recommended_settings.csv

On the RDS dashboard, go to Instances and then launch a DB instance. Follow the recommendations in  `instance_recommended_settings.csv`. Remember to specify the parameter group you created in 2.1 for *DB Parameter Group* when you get to configuring *Advanced Settings*.

Keep track of your password for next step.

## 2.3. Get connection details for your DB instance

Open this file:

    rds/instance_connection_details.csv

Once your RDS instance gets the status *available*, see details for your instance. Fill out the values for the variables listed in `instance_connection_details.csv`. For the password, specify the password you used in step 2.2 when launching the instance.

# Step 3: EC2. Configure a firewall for your database server

Open this file:

    rds/instance_connection_details.csv

The database server you created in step 2 uses EC2 for its computing capacity. The associated EC2 instances are not available to your account for configuration, but some other associated entities (e.g. Security Groups) are available.

In this tutorial we are only concerned with inbound rules for a security group of your RDS instance. You saved its ID in `instance_connection_details.csv` in step 2.3. Go to the EC2 dashboard, then to *Security Groups*, then find your security group, then edit its *Inbound Rules*.

You need two *Inbound Rules* on your *Security Group*:

- *Protocol*: TCP. *Port*: 3306 (the port you specified in step 2.2). *Source*: My IP. EC2 dashboard will get your IP address and use it for the inbound rule. This is so your network can connect to the database. This is the only reason we made the database accessible over the Internet. Go back to this page if your IP address changes, and change the inbound rule so you can still connect to your database server.
- Same *Protocol* and *Port*. *Source*: Custom. Paste the Security Group ID of this Security Group (e.g. sg-12345678). This is so your backend server can connect to your database server. We will create a **Lambda** function inside the same security group, so we need to allow connections from it to itself.
# Step 4: MySQL. Define your schema

So far we created and started a database server (step 2) and configured it to allow your connection (step 3). Now we connect to it and create all MySQL objects we need.

## 4.1. Establish a connection to your DB server

Open this file:

    rds/instance_connection_details.csv

Install a client that can send queries to your MySQL server. We’ve worked with [MySQL client](https://dev.mysql.com/doc/refman/5.7/en/mysql.html) for command-line access and [Sequel Pro](https://sequelpro.com/) for access with graphical user interface on Mac OS X. Either CLI or GUI access is fine for this tutorial, and you can use the above or an alternative tool to establish your database connection. Any tool will need a username, password, and a host.

## 4.2. Migrate the schema

Open this file:

    rds/mysql/cat.sh

Once you are connected to your MySQL server, run the queries in the files listed in `cat.sh`. Order matters (e.g. you can’t create a table without first creating a database, you can’t create table B with a foreign key constraint relating to table A without first creating table A, etc). 

`cat.sh` outputs a list of queries you need to run to get your database ready to process INSERT and SELECT commands from your backend. You can store the output of `cat.sh` in `migration.sql` by running on Linux:

    sh cat.sh > migration.sql

Now that you’ve created your database `prime`, you can specify `database` in connection details you use to connect to your database server, so the connection automatically runs the following command on successful connection:

    USE `prime`;

MySQL server relies on this command to determine which database to use when executing queries that assume schema. To get [a list of available databases](https://dev.mysql.com/doc/refman/5.7/en/schemata-table.html), run:

    SHOW DATABASES;
# Step 5: Lambda. Launch your backend… server?

This tutorial makes use of **AWS** **Lambda** and celebrates its ability to respond to requests without provisioning and maintaining servers. We will configure a *Lambda function*, get an *Invoke URL* for submitting requests, and deploy a *Function Package* that integrates with our database to send a response. With a request-response API we will be have a basis for developing a webpage that submits a request and presents the response in a visually appealing way.

## 5.0. Create an IAM role for your Lambda function

IAM roles tell your AWS resources which other AWS resources they are allowed to work with. For our Lambda function, we want it to be a part of the same Security Group as our RDS instance. A Security Group is a member of a VPC, Virtual Private Cloud. In addition to AWS Lambda Basic Execution Role, we need it to have access to Amazon VPC. For this tutorial, we will go with full access, and bring the permissions down to a particular VPC and Security Group later.

Go to the IAM dashboard, and create a Role. Attach the following Managed Policies to your Role:
* AWSLambdaBasicExecutionRole
* AmazonVPCFullAccess

## 5.1. Create a function package

Open this file:

    lambda/code/deploy.sh

Make sure `node` and `npm` are installed on your machine. `deploy.sh` installs node modules [mysql](https://www.npmjs.com/package/mysql) and [ua-parser-js](https://www.npmjs.com/package/ua-parser-js).

File `queries.js` uses the mysql module to connect to a database and defines a list of queries it can run against the database. Each query invocation sends back the query result, by first transforming the data to a more convenient format.

File `eventParsers.js` queries the [Lambda event](http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-create-api-as-simple-proxy-for-lambda.html) for useful information (e.g. query parameter values, the user’s browser). It uses the ua-parser-js module to get information like the user’s browser out of the user agent included with the Lambda event.

File `index.js` contains the entry point for the function package, which runs the appropriate queries and returns the result back to the requester.

`deploy.sh`  then makes an archive with all of these files and stores the archive at `index.zip`.

## 5.2. Create a Lambda function

Open these files:

    lambda/code/index.js
    rds/instance_connection_details.csv

With the function package ready, go to the Lambda Management Console, and create a Lambda function. You can use a *Blank function* when selecting a *Blueprint*.

When configuring *Triggers*, select this *Integration*: **API Gateway**. For *Deployment Stage*, write in **stage**. For *Security*, select **Open**.

When configuring the function, select this *Runtime*: **Node.js 6.10**.

**Lambda function code**. For *Code entry type*, choose **Upload a .ZIP file**. Upload your *Function Package* from step 5.1. When specifying *Environment Variables*, specify all the keys of `process.env` in use by `index.js`. These are `HOST`, `USER`, `PASSWORD`, `DATABASE`. Specify their appropriate values. You captured this information in `instance_connection_details.csv` in step 2.3, and the database name is `prime`.

**Lambda function handler and role**. For *Role*, choose **Choose an existing role**. For **Existing role**, choose the *Role* you created in step 5.0.

**Advanced settings**. For *Memory*, choose **128 MB**. This is the minimum allowed value for a Lambda function and is more than enough for our workload. The less memory you allocate to your Lambda function, the more free invocations you get in a month. For *Timeout*, choose **1 min**. The default timeout of 3 sec is not enough for a request-response workload. We will have to establish a connection to the MySQL database, which is traditionally a job for a PHP server — known for its timeouts of 30 sec to 1 min. For *VPC*, choose the VPC you captured in `instance_connection_details.csv` in step 2.3. For *Subnets*, specify all available subnets. One data center is unlikely to be unavailable, more data centers are more unlikely to be unavailable at the same time, therefore the more subnets you send your Lambda function to, the higher its availability. For *Security Groups*, choose the Security Group you captured in `instance_connection_details.csv` in step 2.3. You opened allowed this Security Group to connect to your MySQL database in step 3.

# Step 6: API Gateway. Create a production environment

We have a backend capable of serving our requests. To invoke a request, you need an *Invoke URL*. We will create two Invoke URLs: one for the staging environment and one for the production environment.

From the AWS Management Console, go to API Gateway, select the *API* you created with Lambda in step 5, and go to its *Stages*. You should have one stage called **stage**. The *Stage Editor* tells you your *Invoke URL* for this stage. Navigate to that Invoke URL and make sure that your response communicates aggregate information about all requests that have been submitted to it. Connect to your database server and verify that a row has been inserted into the `apigw` table, a `hits` table, and that the `charts` view has the same information communicated by the response from the *Invoke URL*.

Create another stage with API Gateway with *Stage name* **prod**, and the most recent *Deployment*. Once created, check out its *Stage Editor* for the different *Invoke URL*. Navigate to that *Invoke URL* and observe that this hit counted as a production hit.

Now you will be able to make changes to the stage API without having to affect the way your API behaves in production.

# Step 7: S3. Upload your website

Open these files:

    s3/index.html
    rds/mysql/charts.view.sql

Replace the ajax url in this file (`https://ul6ado1u.execute-api.us-west-2.amazonaws.com/stage/modus`) with the stage Invoke URL from step 6. If you want to see what your frontend will look like before uploading it to S3, install a [local-web-server](https://www.npmjs.com/package/local-web-server) with npm, then run `ws` in the `s3` directory.

Go to the S3 Management Console, then Create a bucket with any name. No need for *Versioning*, *Logging*, or special *Permissions*.

Navigate to this bucket and upload `index.html` to it. When you set *Permissions* for it, you need to *Manage public permissions*. Make sure *Everyone* has **Read** permissions on the *Objects*. No need to change other *Properties*.

Navigate to the newly-uploaded `index.html` object and capture its *Link*. This is the link for your frontend. Navigate to the Link in your browser, and verify that the appropriate bars rise when you hit the website from your configuration. Try various devices, browsers, operating systems, and networks.

The networks chart will show the globe for a hit from any network. Replace IP addresses in this part of `charts.view.sql` with the IP addresses you know belong to your Home, Work, and School networks:

    CASE `ip`
     WHEN '127.0.0.0' THEN 'Home'
     WHEN '240.0.0.0' THEN 'School'
     WHEN '255.255.255.254' THEN 'Work'

Then you can run the query individually against your database. It will replace the `charts` view with the new definition. Observe how that changes the network chart.

----------

**Suggestions for next steps**. 

**Fork me**. This tutorial takes the microservices perspective on web application development. Take any configuration detail or any hunk of code that excites you and experiment with it, see how it changes the application as a whole. Use it as a boilerplate for your own application, make it as different as you want. Make this project better by submitting pull requests.

**Go further into AWS**. Give your S3-hosted website a pretty domain name with **Route 53**, enable HTTPS and caching with **CloudFront**, abstract all of the above configuration details with a single **CloudFormation** template, automate the deployment process with **CodeDeploy**, etc. AWS has a long list of services to explore.

