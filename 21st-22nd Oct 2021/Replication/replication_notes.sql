--Replication
Replication explination blog: https://www.codeproject.com/Articles/715550/SQL-Server-Replication-Step-by-Step

Key points: 
1. It is a one of the high availability and started from sql server 2000 onwards and we are
using currently till data. 
2. Replication have different types of topologies(structure or design)
Note: we have so many types of topologies and will design basedupon the client requirment. 
 Here we use News Paper terminology.
 Publisher , Distributor, Subscriber. 
 -> Publisher we can publish only selected and specific data but not all data.
 So we can save space and reduce maintainence as well. 
 The replication main DB called as publication DB, We can create our own published data called publisher.
 This publisher data in it will be saved in distributor(Distribution DB). 

-> Distributor will create a Distribution Database and
 will works as intermediate to send the specific articles and data from pubs to subs. 
 Note: all the object are called as Articles in replication. 

 -> Subscriber: The publisher data will create a subscriber and with a DB called 
 Subscription DB.  This is a destination data. 


 We have differnt types of replication:

 1. Snapshot replication.
 2. Transactional Replication.
 3. Merge replication
 4. Peer-to-peer replication.

 1. Snapshot replication:
 -> This is the first replication feature and also it is mandatory for all the replications.
  ->In snapshot rep, It will replicate the schema of the articles like table structure, sp code,
  View structure and along with the data in it.  Here we need a location to load the snapshot 
  called as Snapshot Folder. It will resides in Distribution DB server. 
 ->In the location it will create a UNC folder and under it snapshot folder gets created
   with all the schema, data. 
   
   Note: 
   schema copy with .sch files.
   Data copy with .bcp files.
   Index copy with .idx files.
   script the table for snapshot with .pre files.
   Note 2: Make sure this path have a enough permissions of read\write to perform snapshot
   and to re-initalize the snapshot in subscriber. 

-> In snapshot rep, we use two Agents.
Snapshot Agent : This Agent will resides in Distributor DB server and will take the snapshot 
of the publisher with specific articles. 

Internally it will create a Login in Distributor Server "distributor_admin" and in 
publisher it will create a Linked server "repl_distributor" .
Using this Linked server , it will pull the data from publisher to distributor DB 
with the help of snapshot Agent. 

->Snapshot is a one time sync, Also we can schedule it if required. 
And re-initilazing the subscriber will be taken care by Distribution Agent.

Distribution Agent : 

This Agent help in intializing the subscriber with the article pulled out from the
snapshot Agent. 
THis agent used in snapshot replication and transaction replication only. 
Also this Agent resides either in the distribution Server or Subscription server.
It is based upon the type of subscription we use here.
We have two types of subscription:
-> Push subscription. 
If we use Push subs, The distribution agent resides in Distribution Db server.
Note: This is a default subscription. 
-> Pull Subscription.
If we use Pull subs, The distribution agent resides at subscription server.
Note: This type may leads to performance degrade some times. 

Pre-requisties of replication: 

1. While installing the SQL server, make sure we install replication feature.
2. Publisher , distributor, subscriber should have more than sql 2000 sp3 
onwards either same sql versions or different version also supported but have
limitations. 
For all the types of replication the distrution DB version must be no earlier
 than the publisher version. 
 For transaction replication, a subscription to a publication can be same and any version.
Ex:  Pubs    dist           subs
     2005    2008          2005 -> not valid
	 2012    2012/2014     2012 ->valid

4. FOr merge replication, a subs to a merge pubs can be any version 
not later than publication version.
Ex:  Pubs             subs
     2008    2008/2005/2000  -> this is valid  
	 2012    2014/2016        -> This is invalid versions.
Configuration of Snapshot Replication:
1. Configure your Distributor first on distributor Server.
Note: navigate to the next options by reading it throwly.  
Also you should specify the Publication server name in the distributor 
config. And the authenticaing with a password on it.
Note -2: We can add 'n' no.of publication server in the distributor.

2. Once the DIst Configurateion completes, We will start config of publisher
on Publication server-> Replication-> Local Publication (It means the publication is in the local server)
a. You should specify the distributor using for this replication setup, which is already configured.
And also it should authenticate the distributor with the set password on distributor. 
Note: Once the authentication successful. It will take to Publisher Server deatils like DB names.
b. Choose the database name for replication.
c. Choose the type of replication.(Here we go for Snapshot replication)
d. Choose the selected Articles like Tables, views, store procs.
Note: We can also choose the specific article coulmn from the list of articles.(Column Filter)
e. Choose the selected records as well by applying conditions on it.(record filter)
f. Configure the Snapshot Agent whether to run immediate or any schedules after the configre.
g. Specify the security login to which it should logging for snapshot agent. 
Note: Normally we will use the agent service account login here on snapshot agent Job.
It will create a job in distribution Server. 
h. We can create the script for the same wizard by enabling the script.
i. Finally we should give a "publisher Name" for it. and Finish.
Note: It will listed a new publication in the local publication list. 

3. We should configure Subscriber either remotely from publication or Go to local subscriber on 
subscriber Server. 
a. New Subscriber-> We should choose the publication server and created Publisher from the list. 
b. Configure the Distributor Agent, Also we should choose the type of subcriber we use here.
Based on the type of subcriber, the distributor Agent will reside on it.
Push Subscription -> Distributor Agent will be on Distribution Server.
Pull Subscription -> Distributor Agent will be on Subscriber Server.
c. Create a Subscription Database here .
d. We should provide the scurity Login for Distributor Agent and authentcating in distributuion Server
and Subscriber Server. 
Note: Normally we will use the agent service account login here on distributor agent Job.
It will create a job on the either of the server by the type of subscription we use in it.
e. Here the data sync of the article via distributor agent can be running continous or it can be 
ondemand sync. 
f. The snapshot we already took on publisher can be applied on subscriber by initializing it 
immedaitely after a snapshot occurs or just to initialize it only first time sync.  
Note: Normally we go for immediate sync. 
g. creating a script is optional.
h. Finish the configuration. 
Note: After the configure we may or may not see the subscriber under local subscribtion.
If not  Please trigger a snapshot and initialize the snapshot on subscriber, It will appear. 
 
Note: Once the replication is configured, We will get almost 9 Jobs for a replication in all the servers.

Also replication monitor is very important to verify the replication sync and health of it.
Note: Make sure you connect the object explorer with valid server name. But not with IP address , server and port no.
Because the replication monitor will not open . 
