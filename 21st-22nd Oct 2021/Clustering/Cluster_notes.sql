--Clustering Notes
-> Clustering is a concept where we can bind the group of nodes(OS Machines). 
With atleast 2 or more. We can even create cluster with single node but no use of it because we cannot perform failover on it.
Hence single node clsuter cannot consider as High availability. 
-> Cluster on Windows Servers can be perform only on Windows Server edition machines. But cannot clsuter the 
domestic Editions. 
Windows Server edition are Windows Server 2003, 2008, 2008 R2, 2012 , 2012 R2, 2016,2019. 
All these are Operating Systems which used in Software Business Env and this OS provided by Microsoft INC. 
In Win Server Machines, the Hardware used show be huge like high capacity mother board( DELL),
More CPU like multiple core CPU ( It can divide into multiple Logical Proccessors)
and also having more socket to extend in future, 
Also will Support High Memory (RAM) and given more slots to extend the RAM in future. 
Also More Disks can add in such Servers. 

--> Only Win Server can handle more users in business ENV. 
Domestic Editions should not use in prod ENV and only for personal use.

-> Windows Server failover Cluster(WSFC) are used as a High availability(HA) in Windows 
but not in SQL Server HA. 
-> To install a cluster, First we should have a Cluster node either cluster node can be 
physical Server or Virtual. 
We should provide name for the clsuter group as "Cluster Network Virtual Name"(Ex: us02clusdbp001) and
an IP for this Node. Ex: (10.196.18.5) and Domain: dir.company.com and cluster group Server Name: us02clusdbp001.dir.company.com
-> If we are installing 2 node cluster, We should have 2 OS machines with Win server edtions.
Note:L Both the nodes should have same version and edtions of Win Servers OS. 
-> To bind the Nodes in the cluster, We should add these Nodes in the domain
 and provide an IP to each nodes and make sure these are in the same domain of the 
 cluster Group.Ex: Node Name: us02dbp001 (10.196.18.4) and us02dbp002(10.196.18.10).
 -> Now Windows will config the Nodes into a Cluster with these domains. 
 -> Once Configuration completes, The Windows failover cluster is ready .

 Features in CLuster:
 1. We have a Failover Cluster Manager to manage the Nodes and failover.
 It is a Dashboard or tool for Cluster. 
 We can perform activities from this Dashboard like 
 View Nodes, SQl Instances, Clsuter Group, SQl server failovers, Perffered Node,
 Owner Nodes, Failback preferrences, Add/remove Nodes to an existing Clsuter,
 Add/remove sql Nodes to an existing Cluster, Add/remove Disks in cluster, Network Ip views.
 Sql Instance IP's', Node restart, bring the disk online and offline as well. 
 Note: To navigate to the failover clsuter Manager.
 To go Adminstration tools-> failover clsuter Manager.
 or
 Server Manager-> tools-> failover clsuter Manager(FCM)
 Note: If not visiable , It means the tool FCM was not installed by Win admin.
 Notify them to install the tool. 

 2. In Clsuter nodes, only C drive will be independent (OS will install on it)
 Here remaining Drives for Data files, log files, backup drives(D,E,F,G...) are shared b/w the 
 nodes based upon the SQl Server active services. 
 3. Q drive belongs to Cluster for Quorum. It is not user accessed Drive. 
 Quorum is used to check the heart beat of the nodes and if active services nodes fails.
 It will perform auto-failover to second nodes to run the services un-interruptedly. 
 
 4. If we have a Active-Passive Cluster, the Drives belong to SQl Instance like data,log file drives
 will be on Active node only(we can visiable it on active node only).
 On passive Node, No Drives will be visiable or not existed(only C drive resided) .
 In case of failover the Sql server either auto or manual , The sql services will jump to passive
 node and the sql will start runnning on this node and the drives like (D, E,F,G...) will also
 jump to the passive node to make the sql to run here. So Jumping the drives are called shared drives.

Ex:
3 SQL Servr running on Node 32. Active Node for all these 3 SQl
And other Nodes are consider as Passive. It Means Only OS will be running but not the SQL Server(Not Running state).

Passive
Add Node Installation-> 31, 

Active
Failover Installation -> 32,
SQL1 -> H Drive -> Failed over to 33 -> H drive will move to 33 node.
SQl2 -> M Drive -> Failed over to 31 -> H drive will move to 31 node.
SQl3 -> N Drive 

---------------------------------------------
Active 
Add Node Installation-> 31, 
SQl3 -> N Drive 
SQl4 -> R Drive

Active
Failover Installation -> 32,
SQL1 -> H Drive -> Failed over to 33 -> H drive will move to 33 node.
SQl2 -> M Drive -> Failed over to 31 -> H drive will move to 31 node.

Active
Failover Installation -> 33,
SQL5 -> P Drive -> Failed over to 33 -> H drive will move to 33 node.
SQl6 -> S Drive -> Failed over to 31 -> H drive will move to 31 node.


--------------------------------------
31 to 35 Active
36 to 38 Passive

SQl 1 -> Failover Install-> Running on 31-> Active
SQl 1-> Add Node Install->  Not running on 36 -> Passive

SQl 2 -> Failover Install->Running on 32-> Active
SQl 2-> Add Node Install-> Not running on 36 -> Passive

SQl 3 -> Failover Install->Running on 33-> Active
SQl 3-> Add Node Install-> Not running on 37 -> Passive

SQl 4 -> Failover Install->Running on 34-> Active
SQl 4-> Add Node Install-> Not running on 38 -> Passive

SQl 5 -> Failover Install->Running on 33-> Active
SQl 5-> Add Node Install-> Not running on 37 -> Passive

SQl 6 -> Failover Install->Running on 35-> Active
SQl 6-> Add Node Install-> Not running on 38-> Passive


Add Node Installation->33, 
Add Node Installation->34,
Add Node Installation->35,
Add Node Installation->36,
Add Node Installation->37, 
Add Node Installation->38





 5. Also we can have Active-active Cluster, It means Sql Services will run on both the nodes.
 But the Imp point is These are not same sql services, Different SQl Instances on different nodes. 
 on Node1-> SQl1 (Active) (Drives: D,E,F) , sql2 (passive)
 on Node2-> SQl1 (Passive) , sql2 (Active) ( G,H,I) 
 Here Make sure the Drives letters used in the nodes should be unique . 
 No drive letter should repeat in any node.
 Because while failover it jumps on other nodes, if the drive letter already exists on second node.
 SQl services will not be up due to Drive conflict.

 Terminologies used in it:

 -> Cluster : A group of Nodes collective called as Cluster. we can bind 2 or more nodes to make a cluster. 

 -> NOde : It is a Windows Server machine with OS installed. 

 -> Failover : Moving the services from One node to another node in times of active node fails. 

 -> Failback : Moving the back the services to old active once it is reachable. 

 -> preffered Node: The sql Instances are preffered to run their service on this Node.
  We will set the peferred node for all the sql instances after installation. 
  If the services jumps to some other node. We can bring back the sql intance to run on preffered Node. 
  Note: Perffered nodes concept are used to manage the sql server instances to perform the 
  load equally on all the nodes in cluster.
    
 -> Owner Node : THe sql Instances current running the node is called Owner node. 
 Note: If the owner node and preffered node are same. No action required.
 If the owner node and preffered node of a sql instance are different. Then we need to perform a
 failover to preffered node. But we show have a proper window to do this.
 Note: Mostly we will do it in non-business hours. 

 -> Quorum : It is used to check the heartbeat of the nodes to help in automaatic failover 
 if active crashes\unreachable.

 -> MSTDC : Full form is Microsoft Distributor transaction co-ordinator. 
 It is used to communicate the transacrtion from node to node in case of failover happens. 

 -> SQL Network Name (or) SQl Virtual Network Name: 
 While Installing the sql Cluster we should create a virtual network name for a sql Instance. 
 It even called as SQl Network Name as that sql can identify in the domain network with this name.
 So we will give IP address to this SQl Name as well. 
 Note: For every sql installation in cluster, we will give sql network name and IP address to 
 to identify in the domain network. 
 Also we will give names for Default and named Instances under the sql network name.
 So that while connecting via SSMS.

Dafult Instance
Named Instance

Node1 : us02dbp001.miscrosoft.com 
IP:(10.196.18.4) 

Node2: us02dbp002.miscrosoft.com 
IP:(10.196.18.10).

SQl Network Name: USAMZSQLClu01.miscrosoft.com
IP: 10.196.18.20


 Server Name: <SQL network name>\ <Instance Name>,<port no>
 or
 server name: <SQl network name>.<FQDN>,<port no>
 Ex: uso2sqldb001.dir.company.com,1198
 Here port number is must . 

 Port number is optional while connecting the server in SSMS. 


 -> Shared Drives : In Clustering, the Drives are shared b/w the active and passive node of a sql instance.
 Narammly the drives are attached/ visiable in active node only. If caqse of failover of the sql services
 Drives will jump\move to passive node along with the sql services to run in it. 

 Note: If the Disk failed in the CLuster, there will not be any other secondary drive to replace
 the old drive. We need to reach the Wintel Team to fix it ASAP. Untill they fix the issue, sql server
 databases will not be accessable. 

 -> Active- Passive: In 2-node clustering, We will be installing the sql instances on a node 
 called as active node and 
 where will be install their passive services on other node. So the Services will run on
 only active node and passive is a standby node where the services will not run but the
 Windows will up and running continously. Passive will become active only in case of 
 failover happens. We can maintain multiple passives for a single Active node.
 It is based upon the cluster configure(like 2-node, 3-node, 4-node...)
 So In case of failover we have a possability to jump the services to any of the passive node.
 Ex: Node 1 -> sql 1 (active)
 Node 2-> sql 1(passive)


 -> Active- Active : 
 In 2 nodes cluster, we can install the sql instances on a node and will maintain their passive
 on other node. And also we can install a new sql instance on the current passive node
 and will maintain thier passive on the first node. In such case, SQl Services are running 
 on both the nodes but the sql services are different. This is called Active-active cluster.
 Note: same concept can implument on any number of nodes cluster. (like 4-node, 6-node,7-node
 ,8-node....)
 Ex: Node 1-> sql 1(active) , sql2 (passive)
 Ex: Node 2-> sql 2(active) , sql1 (passive)

 Note: Also if we have 8 or 10 node cluster, It is not mandatory to intall passives on the
 remaining nodes. We can choose how many passive will be mainitained for a instance. 
 Better just got for only 2 or 3 passives. 


 -> Public Network : We need network to communicate the server to the outer world.
 Public Network IP address is used to communicate the cluster to the application. or others.
 -> Private Network : We use Private IP address to communicate b/w the nodes in the clsuter. 



 SQL Install on Cluster nodes:

 Pre-requisties for Clsuter Install:
 1. Windows Server should be configure in Clustering (WSFC). 
 2. Disks should be in place on any of the node. (provided by Storage Team) 
 Note : How many disks required and with which Size to it. 
 3. Get the sql server network name registered in the network domain and
 Also request the Network Team do the registeration and also ask 
 for an IP address to it. 
 Note: Network Team will take care every thing and let you know with IP address
 and subnet mask for it. 
 4. Make sure .net framework 3.5 sp1 Installed By wintel team .
 5. Make sure the DBA Team have a permission on "create computer Ojbect" in 
 windows level provided by Wintel Team.  
 Note: Because we are creating a SQL Network name while Installing the sql cluster.
 6. Make sure the SQL Installation DUMP copied on to all the nodes . 
 select @@VERSION
 Once everything is in place. We can start SQl installation:
 --Steps for sql cluster failover Installation:
 1. On a Node-1, Open the sql setup file and open the installation center.
 2. Go to Installation Tab -> Click on "sql failover cluster Installation". 
 3. Next license and product key, checks will run on it, and choose the sql features to
 install along with the shared connectivity tools .
 4. Here we find difference in only providing the "SQL Network Name" in the Instance configuration
 which is not in standalone install. 
 5. Next window is to just view the cluster group name and disk in cluster.
 6. Next window is to Provide the IPaddress for the sql network name and automatically
 picks the subnet mask for that. make sure not to tick the DHCP box, 
 Just tick on IPV4 box in that winodw.
 7. Next windows are same as standalone Installations. 
 8. Completed. 

 -- On Second Node we should install a passive services for that sql instance. 
 1.  1. On a Node-2, Open the sql setup file and open the installation center.
 2. Go to Installation Tab -> Click on "Add node cluster Installation". 
 3. repeat the same steps just like about step-3. 
 4. While Instance config, We should give the same "IP address" provided in 
 node -1 while sql instance install. It means it will acuquire the connection 
 with IP and acts as passive for the active services .
 5.  Next windows are same as standalone Installations. 
 6. Completed. 

 Note: 
 Still if you have more nodes we can also install "add node sql installation"
 by provided the sdame IP address here.
 By this we can maintain multiple Passive Nodes. 



 Patching on CLuster nodes :
 --For a Active -Passive Machine the steps for patching are:
 1. Start patching on your Passive node(node-2) first becasue the sql services are not running here. 
Note: In case if it fails it will not impact the running sql services. 
2. Once the patching completes, we should check the version of it.
Note: we can check it from sql config manager-> Instance rt click-> advance options. 
or We can check it from the SQL logs. 
Or from Power shell we can check it.
 NOte: It should be restarted the windows box inorder to update the DLL's' of the CU. 
 Once the restart completes and server came up then we are good to move the sql services 
 on to this passive.
 3. We should perform a failover onto Passive node now.
 4. Now we are good to patch the old active Node.
 Note: Repeat the same procedure...and restart the node after completed.
 5. Then Failover again the services to move the instance to old place (node-1). 

  --For a Active -Active Machine the steps for patching are:
  1. Choose the node to perform Patching on it.
  Here We choose Node-2 to have a patching First. 
  2. Now we should move all the active services from the Node-2 to nOde-1
 Here we have SQL 2 and 3 are running on node-2 and we will failover the services to Node-1.  
 3. Install the patching on Node-2 and restart it after completes.
 4.  Failover all the 4-active running services from Node1 to Node -2 (one after another)
 5. Then Start patching on Node-1 and restart it.
 6. Again jump backup services to it's' previous state. 

 Note: If we have 4 sql instances with same versions here. 
 Then One time patching is enough. as it will automatically pick the
 respective sql which falls under same CU update. 
 Also we can exclude any of the sql Instance from being patched 
 if even  thow the same sql version are being patched .
 In patching wizard ,Just uncheck the sql instance which do not want to patch .  

 Note: If we have different sql instances out of  4-sql's' . We can patch only specific 
 SQL according But failovers on other sql instance are mandatory . Becasue the node
 should be rebooted after patching. 


 How many minimum Ips are required to Install SQL Cluster (Active-Passive)
 Ans: 
 Individual Node have each IP(If 2 node) -> 2 IP's'
 Windows CLuster node -> 1 IP
 For SQl Network Name \SQl Instance we need IP -> 1 IP
 Public Network-> 1 IP
 Private Network -> 1 IP (optional, But in Real Env we will use atleast 2 IP)
 Quorum -> 1 IP
  Total 7 IP's' required for an sql cluster (A-P)

How many minimum Ips are required to Install SQL Cluster (Active-Active)
Ans: 
 Individual Node have each IP(If 2 node) -> 2 IP's'
 Windows CLuster node -> 1 IP
 SQl Instance1 -> 1 IP
 SQl Instance2 -> 1 IP
 Public Network-> 1 IP
 Private Network -> 1 IP(optional, But in Real Env we will use atleast 2 IP)
 Quorum -> 1 IP

  Total 8 IP's' required for an sql cluster (A-A)

  Troubleshooting:
  1. If one of the node in cluster is not available(node crashed).
  The immediately reachout to Windows(wintel) Team to get it fixed.

  2. If any of the Disks are not available(Disk crash or any reason)
  We can first try to bring it online (On Failover cluster Manager-> by rt click-> bring Online)

  On Failover cluster Manager
  -Roles-> It will show you the sql server Instances
  Ex: Sql Server(Instance Name)
  We can also the see the all resources running on the instance . Just click on it.
  At the bottom , We can see the sql network name(Client access name)
  Owner node, Priority, IP address of it.
  Click on resources-> It will show the storage like disk running on this Instance and
  Ruuning Services like sql DB engine and sql agent. 


 