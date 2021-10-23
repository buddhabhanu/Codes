-- Mirroring
Mirroring Prerequesities:
1. SQl Server version should be higher than 2005 sp1. 
Note: OS should be from windows Server 2003 Onwards. 
2. sql Server edition should be standard\Enterprise Edition only. 
3. Database should be in Full Recovery model.
4. Endpoints should be configured. 
Note: In prod env, Contact Firewalls team to enable the port no 5022 and 5023(optional). 
5. Principal and Mirror DB should be in same Domain and both server should 
have FQDN( Fully Qualified Domain Name). 
Note: If Computer name is not FQDN, configure by rt click-> "my compter"-> change name-> add domain-> and restart to effect the Sysytem.
6. All Servers used in mirroring setup should be in same version including SP and CU as well. 
Note: Witness Server can be standard/Enterprise edition. But principal and mirror should
be in same versions and editions as well. 
7. Service Accounts  should be the same login on both the DB instances and 
make sure the same login should exists in the individual DB instance with SYSadmin previlages. 
Note: It will not add in logins autmatically, You should add the service account login under secuirty tab.
8. Configure the schedule Log backup on principal after mirror setup. If not, Log will
grow and finally DB will become suspect state and mirroring will suspend. 
9. Network should be acquire b/w both the servers. 
10. Both the DB names should be same in mirror setup. 
11. Drive letters should be same in both the DB servers .
12. File stream will not support in mirroring setup. 

Mirroring Terminologies: 
1. Principal Database and Principal Server.
2. Mirroing Database and Mirroring Server.
3. End points: End points are the Port numbers. In mirroring, the actual Transaction 
communication will happen via End points through the network. These are points where
communication moves from one server to other. 
4. redo Queue: Transaction moved to Mirror server called as redo queue. 
If transaction in redo queue are not restoring then unrestore log will grow.
5. send queue: Transaction moving from principal to mirror server called as Send queue.
If the transaction in the send queue are not sending then unsent log will grow. 
6. Role : It will let us the know the DB state in Mirroring setup. 
7. Role switching: shifting the role from prinicpal to Mirror and vise versa. 
8. session:
9. Transaction Safety ON or OFF : It will let us know the type of modes we use in mirroring setup. 
10. Witness Server: It acts as witness in sync mode and support Automatic failover. 
11. Quorum and heart beat: Quorum will be used in Witness server. and it will
 check the heart beat of both the servers and helps in automatic F.O. 


 Types of Mirroring Mode: 

1.Mirroring is a High availability which maintains only one standby(Mirror DB) copy of the specific DB.
2.Here the Data sync will be done using Network and Communication will be happening using Endpoints.
3.The default Port number used in Mirroring are 5022, 5023, 5024 (optional).
4.If mirror setup is b/w untrusted Domains, We use SQl Certificate to accure Connection. 
In SQL Certificate, we will create a Master Key with a Valid Password and 
add the certificate to ENd Points. 
5. We have multiple types of Modes in Mirroring:
-> Syncronous  Mode.
   This Type of Mode ensures the data protection and safegaurd the transaction b/w
    both the DB. Here we use the " Tranasaction Safety FULL" It will make sure the data is surely 
	saved in both the servers.

	Internal Mechanisum of Sync Mode: 
	The data executed in the Log file of Principal DB will not save in the dataFile immediately after
	a checkpoint occurs. It will send that transaction to Mirror DB via Network and will restore
	the log in mirror DB and after a successfull restore it will send an aknowledgement copy to
	the principal DB saying the data commited safely and then same transaction will committed in
	Principal DB. This is because of we set "tranasaction Safety FULL". 
	We can see the "tranasaction Safety FULL" only in Sync Mode. 
	Pros: Here the no data loss and all transactions will be in Sync.
	Cons: The data committing is slow procedure. It may lead to performance issues of the select queries.
	Here we have 2-types of Sync Mode:

	-> High Safety Mode.
	  This Mode supports Automatic Failover and also will be data safegaurding. Here witness server will
	  take part of the automatic failover. In witness server, we have Quorum in it and it will check the 
	  heart beat of both the servers and it will expect the acknowledgement of ping back from the 
	  respective server. If 3 consecutive ping are not received the Quorum will take action. 
	  -> Quorum with 3 partners , Then no action required. 
	  -> Quorum with witness and any of the patner, 
	  If the quorum with principal Server, Mirror will be breaking and no role switching. 
	  If the quorum with Mirror Server, Automatic Failover. 
	  -> Quorum without witness Server, Manual Failover. 
	  Pros: Here the no data loss and Supports Automatic Failover and No Application Downtime.
	  Cons: Performance may hit. 

	-> High Protection Mode.
	  This Mode will support Manual Failover. Also we can perform role switching if required. 
	  As this Mode is part of Sync Mode, The data safegaurding and and protection is ensured.
	  Only Cons is manually the failover should perform.It cannot identify Auto failover as we 
	  do not have witness server here. 
	  Pros: Here the no data loss and all transactions will be in Sync.
	  Cons: We will have a certain Downtime to bring the mirror Up. 

-> Asyncronous Mode. 
    This Type of Mode ensures the performance of the transaction and will not ensure the data Sync
	B/w both the DB's'. Here we use the "tranasaction Safety OFF" 

	Internal Mechanisum of ASync Mode: 
	The data executed in the Log file of Principal DB will save the data immediately after
	a checkpoint occurs and then will send that transaction to Mirror DB via Network and Mirror DB 
	will not send any aknowledgement copy to the principal DB. So Principal cannot ensure the data sync becasue
	The tranaction may reach the mirror DB or not. This is because of we set "tranasaction Safety OFF". 
	We can see the "tranasaction Safety OFF" only in ASync Mode. 
	Also in ASync Mode, we have a type of Async Mode:
	
	-> High Performance Mode: 
	This mode will support Forced Failover and role switch can perform only if Principal DB
	is not available. It means we can bring the mirror Server up forcefully only if prncipal is
	not accessable/crash/unavailable.  here there is an expected Data loss while failover the DB.
	Note: This mode can used incase of using the DB for report genation purpose. 
	Pros: The performance of the DB will fast when compares to Sync Mode.
	Cons: There is a expecte Data loss and only forced failover supported here. 

***** Step by Step to Setup DB Mirroring******
1. Take Full Backup on the Principal DB.
2. Take tlog Backup on the Principal DB.
Note: Make sure to Disable the scheduled Log Backups if any. If not, LSN mismatch while restoring on Mirror DB.
3. Copy the Backups from Win server 1(Principal DB server) to Winserver 2(Mirror DB server)
4. Restore the Backups of Full and Tlog onto Mirror DB Server and Make sure to Keep in Norecovery.
5. Using Mirror Setup Wizard, you can continue setup the DB mirror in any of 3 modes you like
High Safety mode, High Protection Mode, High Performance Mode.
6. Make sure the DB's are in healthy state by GUI or Script. 	


Failover in SYnc and Async Modes:

	In High safety Mode, Failover will be taken care by Witness and support Automatic Failover.
	Note: Here DBA action is not required. 

	In High Protection Mode, It supports manual failover. and DBA is required to perform this. 

	If principal Db crashes,
	Steps:
	1. Break the Mirror First.
	 CMD: 
	 Alter database <DB Name> set partner Off -- To break the mirror setup.
   2. Take a tail-log backup on  principal DB.
    CMD: 
	Backup database <DB Name> to disk ='path' with no_truncate

   3. Restore the tail-log backup on mirror DB.
   CMD: 
   	Restore database <DB Name> from disk ='path' with recovery
	Note: If DB is recovered , then use
	Restore database <DB Name> with recovery.

	In High performance Mode, It supports forced failover.

	IF Principal Db crashes, 

	1. We need to force failover the Db to Mirror:

	Alter database [DB Name] set partner force_service_allow_data_loss
Note: 
This procedure will have a possiabilty of data loss. 
We can go with another alternative procedure just like manual failover.
Steps:
1. Take the tail-log on principal DB.
2. Restore the log on mirror and bring the Db up in mirror side.

Note: This procedure will avoid the data loss if principal crashes. 


Failback in SYnc and Async Mode:

In High safety mode, After a auto failover the role will switch and once the principal DB 
came back to online. The DB will automatically added in the mirror and old principal Db will
be your Current Mirror DB. If you want to bring it to old position then we can role switch
by failing over the DB's'.

CMD: 
ALter database [DB name] set partner failover-- It will switch the roles

In High protection Mode, After a manual failover the mirror DB will be now active principal DB. 

To failback,
1.  we need to take FUll and t-log backup of the Active principal DB. 
Note: Make sure the scheduled T-log backups are disabled. ( Please refer mirror_setup_setps.sql) for more details.
2. Restore the same backups with norecovery on old principal Server. 
3. Setup the mirror configure. 
4. Then to switch the role and trigger the CMD:
CMD: 
ALter database [DB name] set partner failover-- It will switch the roles

Note: Also we can follow the failback procdure we used in log shipping failback. 

In High Performance Mode, After a Forced failover the mirror DB will the active Principal DB.
 To failback,
 Note: Follow the failback procdure we used in log shipping failback. 

 Steps:
 1. Take Full backup on active principal DB. 
 2. Restore teh Full backup with norecovery on old principal DB.
 3. Make sure the DB is in read-only and trigger the T-log backup on active principal DB.
 4. Restore the t-log backuo with reocovery on old principal DB.
 Note: Now the DB is ready in principal side. Again we need to setup mirror from first. 
 5. Take FUll and T-log backup on Old Principal DB.
 6. Restore and replace the DB with the full and t-log backups with norecovery on old mirror DB.
 7. Setup the mirror again . 
 Note: make sure the t-log backup are enabled back in principal DB. 

 Mirroring CommandS:

 -- To break the Mirror
ALter database [DB name] set partner OFF

-- To pause the mirror
CMD: 
ALter database [DB name] set partner suspend

-- To resume the mirror
CMD: 
ALter database [DB name] set partner resume

-- To Manual failover the DB's and also used to switch the roles

ALter database [DB name] set partner failover

-- To forced failover the DB. Trigger this CMD in mirror side. 

Alter database [DB Name] set partner force_service_allow_data_loss

-- To set the transaction safety Full or OFF

alter database [DB name] set SAFETY full -- TO SET IN SYNC Mode.It will change to High protection Mode.

alter database [DB name] set SAFETY off -- TO SET IN ASYNC Mode. It will change to High performance Mode.

--Catalog and DMV's' used to check the health of the mirroring:

select * from sys.database_mirroring
select * from sys.database_mirroring_endpoints
select * from sys.database_mirroring_witnesses

-- DMV's 






-- To check the Mirror Monitor

Use msdb
go
sp_dbmmonitorresults [DB name], 4,0
Note: 
First Parameter is the DB name.
second parameter indicates transaction history duration. 
Ex: 2 hrs, 4  hrs, 8 hrs, 1 day, 1 week, 100 records, 500 records, 10000 records.
Third parameter is either 0 or 1.
0 indicates the historey records will update in DB.
1 indicates the history reocrds will update the DB and will result .

