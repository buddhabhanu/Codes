  -- SQL server Isolation levels and Locks and Blocking, deadlocks and much info in MSDN

  https://msdn.microsoft.com/en-us/library/jj856598(v=sql.120).aspx
  
  
  -- DMV's and DMF's
  DMV's'-> Dynamic Management Views-> It will view the server health checks by passing the DMV's' and it does not required any parameters. 
  DMF's' -> Dynamic Management functions (parameters). It will show the server health checks .Function needs a inputs to retrive the data 
  in the name of Parameters. 

DMV and DMF are started from sql server 2008 Onwards. Before these we are using DBCC commands.


  -- to view the structure of the DMV's and DMF's

  sp_help 'DMV or DMF name'

  Dynamic management views and functions return server state information that can be used to monitor the health of a server instance, 
  diagnose problems, and tune performance.

  Permissions needed for DMV and DMF
  ->SYSadmin can execute the DMV and DMF
  -> "VIEW SERVER STATE" permission required for other normal Logins to view Server-scoped health.
   -> "VIEW DATABASE STATE" permission required for other normal Logins to view Database-scoped health.


  To view the Server health using DMF and DMV, 
  we use "select * from DMV name"  
  or
  select * from DMF name(parameters)

  Note: All the DMV's' and DMF's' are belongs to sys schema.

  We have make sections topic wise DMV's' and DMF's'
  1. Always On Availability Groups Dynamic Management Views - Functions

  select * from sys.dm_hadr_auto_page_repair
  IMp column: page_id, error_type
  
  select * from sys.dm_hadr_availability_group_states

2. DB mirroring related Dynamic Management Views - Functions

  select * from sys.dm_db_mirroring_auto_page_repair
  IMp column: page_id, error_type
  
  select * from sys.dm_db_mirroring_connections


  3. Database related Dynamic Management Views - Functions 

 select * from sys.dm_db_persisted_sku_features
 This DMV shows the features of the edition specification of sql server.
 If the Enterprise edition supports some features and if we have a plan to downgrade
 the edition then we show check the server whether the supported features exists or not.

 Edition Supprt features are:
 1. CDC (change data capture)
 2. Cloumn storage Index
 3. Inmemory OLTP
 4. Data Compression.
 5. TDE 
 6. Table Partition.
 
 select db_name(database_id),* from sys.dm_db_log_space_usage
 It will show the database log file usage details.


 select * from sys.dm_db_partition_stats
 It will show the database table partition details.

 select * from sys.dm_db_uncontained_entities


 -- IMP 3 DMV's used for tempdb details like objects , pages, allocated, de-allocated pages etc

 select user_object_reserved_page_count,* from sys.dm_db_file_space_usage
 select (user_objects_alloc_page_count+internal_objects_alloc_page_count) as tot_count, * from sys.dm_db_task_space_usage 
 order by user_objects_alloc_page_count desc
 select (user_objects_alloc_page_count+internal_objects_alloc_page_count) as tot_count,* from sys.dm_db_session_space_usage
  order by user_objects_alloc_page_count desc

 dbcc inputbuffer(57)

 select * from sys.dm_db_index_physical_stats(5,261575970,1,1,'DETAILED')

  select * from sys.dm_db_index_physical_stats(5, null,null,null,null) where page_count>1000
  order by avg_fragmentation_in_percent desc

 select object_id('my_tab1')

 select * from sys.indexes where object_id= 261575970

 sp_who2 63

 -- 4. Execution related DMV and DMF
 This DMV and DMF are used to retrive the execution related info and details
  while the query executes. 

 select * from sys.dm_exec_requests where session_id>51
 This DMV is used to pull the info of a query by session wise and will provide much info
 like sql text, plan text, blocking, transaction_id, CPU time, Wait type, physical reads and writes,
 Logical  reads, Open trans, isolation levels, deadlock priority ..etc
 Note: Percent_complete can be calculated only for few operation like backup, restore, 
 Index defrag, shrink, dbcc checkdb. Also will show the Estimated time to complete. 

 capture IO stats for a query:
 set statistics io on -- To capture Logical reads and physical reads count
go
select * from my_tab1

set statistics io off -- To turn off the io stats

 select * from sys.dm_exec_sql_text(0x02000000235DED1CC650149A6C2C687FE54615B2F202A4050000000000000000000000000000000000000000)
 This DMF is used to retrive the sql query from the sql_handler. 
 You can get the sql_handler from different sources. 
 - sys.dm_exec_requests
 - sys.dm_exec_query_stats
 -sys.sysprocesses
 
 --Query joining to get the execution plan for all user sessions
 select * from sys.dm_exec_requests a cross apply sys.dm_exec_query_plan(a.plan_handle) where a.session_id>51

select * from sys.dm_exec_query_plan(0x060005007A5A883010C891700100000001000000000000000000000000000000000000000000000000000000)
 This DMF is used to retrive the execution plan of a query from the plan_handle. 
 You can get the plan_handler from different sources. 
 - sys.dm_exec_requests
 - sys.dm_exec_query_stats
 -sys.sysprocesses
 Note: we will get the execution plan in XML format.
  Just click on it to view the execution plan.


 select * from sys.dm_exec_query_stats

 This DMV is used to pull the info of a query with details resource
 utilization like physical and logical I/O, sql_text, plan_text, time consumed, 
 total exection time, total rows..etc
 Note: We cannot get the exact info of the session which is consuming the query resouces here.
 We need to Join other dmv like "exec_requests" to get more and exact info of it. 
 similar columns are sql_handle, plan_handle,...
 
 sp_who2 62

 select * from sys.dm_exec_text_query_plan(0x0500FF7F6F1C43D8F0B073700100000001000000000000000000000000000000000000000000000000000000,2498,2808)
Thic DMF is not so imp as we get same info in XML format of query in other DMF. 


select * from sys.dm_exec_sessions 
This DMV is used to pull the sql server sessions and their host infor and their details.
This is used for audit purpose mostly.
		
select * from sys.dm_exec_procedure_stats
This DMV is used to show the store proc info wise and their resouce consumption.
which is similar to dm_exec_query_stats DMV.

		
select * from sys.dm_exec_connections
This is used for audit purpose mostly. 

select * from sys.dm_exec_cached_plans
This DMV is used to show the memory utilization of the sql query.
Plan handle is used to identify the query.

--5. Index Related Dynamic Management Views and Functions
This DMV or DMF will check the Index related to a database details.
It will verify the missing index and their details, fragmentation and thier details,
Unused indexes and thier details.

select * from sys.dm_db_index_operational_stats(5,null,null,null) 

This DMF importance is to find the indexes created and their details like 
Index level Leaf insertion, deletion, updation count and also wait inform on the indexes. 
Note: 
->Ghost Count is for delete records count which are not showing in leaf_delete_count. 
->The Count of all these columns will be reset when we perform Index ReBuild of 
their individual Index. 
->Even Update table on a column will also like a Insert on their specific Index
on the column. 
-> Also it will capture the details of Latches (CPU and IO) on the
 indexes while performing DMLs. 
 ->Also will show the Row level and page level locks count on the records
  and pages. 

--Case (Example)
select db_name(i.database_id) as database_name,o.name,o.type,o.type_desc,* 
from sys.dm_db_index_operational_stats(5,null,null,null)  i join sys.objects o on i.object_id=o.object_id 
where 
--o.type='U' and o.name not like 'ms%' and o.name not like 'sys%' and 
o.object_id=565577053

-- Index Creation Syntax
create clustered index id_clust_new_tab1 on dbo.new_tab1(id asc)

-- Function to find the id of a table name
select object_id('[dbo].[new_tab1]')
-- Function to find the name of a object id.
select object_name(2222434)

-- Index Catalog 
select * from sys.indexes where object_id=565577053


select * from sys.dm_db_index_usage_stats 
This DMV will show you the usage of the Index in your table. 
It will show the scans, seek, lookups, index updates details of the Indexes created in a table.
Also the Last usage time of the Indexes.

Case: 
select db_name(database_id), object_name(object_id),* from sys.dm_db_index_usage_stats where database_id=5 order by user_scans desc

and object_id=565577053
order by user_scans desc
---------------------------------
select * from sys.dm_db_missing_index_details
This DMV is used to pull  the column in the table how it is used while retriving. 
So if the columns listed here will need be created an index on it.
Also Equality_coulmns means that column used in where clause with "=" and retrived the data.
Also inquality_coulmns means that column used in where clause not used"=" and retrived the data.
and might used (not like, not in, between..etc) 
So better performance will be in using "=" on the coulmns. 
** Here Index_handle is key column where we will get the details of the particular index_handler.

--This is a DMF ,where the Index_handler will be the input here 
--and  the details will get from above DMV.
select * from sys.dm_db_missing_index_columns(9)
This DMF will show you the missing Coulmn where we need to create an index on it. 


select * from sys.dm_db_missing_index_groups

select * from sys.dm_db_missing_index_group_stats 


-- This DMF is used to find the details of Index Fragmentation.
Here the avg fragmentation in percent column should be the key. 
Also make sure the page count on a index should be more than 1000 to perform rebuild/ reorganize. 
Follow the fragmenation threshold to perform the maintainence task on Indexes
0-5%-> No action required.
>5 and <30% --> Index reorganize 
>30% --> Index rebuild. 

Case: 
select * from sys.dm_db_index_physical_stats(5,null,null,null,null) where 
page_count>1000 and 
avg_fragmentation_in_percent>30 order by avg_fragmentation_in_percent desc

Note: If the output retrives the records then you should start rebuild the indexes. 

-- To rebuild or reorganize all the indexes in a single table.

alter index all on dbo.new_tab1 rebuild
alter index all on dbo.new_tab1 reorganize

select object_name(629577281)

select * from sys.dm_server_registry
select size_in_bytes/1024/1024 size_in_MB, * from sys.dm_server_memory_dumps

-- 6. Object Related DMV and DMF
-- To find the statistics update details and when it was updated.
--we can use the DMF
select * from sys.dm_db_stats_properties(555149023,2)
parameters are Object id and stats_id
We can get the stats_id from a catalog "select * from sys.stats" 
use condition to get the object wise and take the stats_id from it. 

-- To find the object id
select object_id('[dbo].[new_tab1]')

-- To Find the stats_id of a table
select * from sys.stats where object_id=555149023

Note: To update the statistics of a DB
Use <DB Name>
go
sp_updatestats

-- to Update the Stats of a Table.
Note: We do not have stats for Table. As the Table have indexes in it. 
The stats of a Index\Indexes will get updated if you specify the table.

Use <DB Name>
go
Update statistics <Table Name> -- This will update the stats with a sample records.

Update statistics <Table Name> with FullScan -- This will perform entire Full scan of a table indexes.
--and will update the stats of it. It will take more time than normal operation.


7. --Server related DMV and DMF

select * from sys.dm_server_services
This DMV shows the SQL services details in an instance

select * from sys.dm_server_registry
This DMV shows the details of registry Editors of SQl server Only. 

8. --Operating System related DMV and DMF
These DMV and DMF are used to fetch the inform regarding the OS
like Memory, CPU, waits in the OS, other sort of info. 


 select * from sys.dm_os_nodes
 select * from sys.dm_os_cluster_nodes -- If the Evn is in Cluster and to know the details
 --of the node names.

 


 
 
 -- This DMV is to fetch the disk info by database_id and their file_id. 
select total_bytes/1024/1024/1024 Disk_Size_in_GB,available_bytes/1024/1024/1024 free_space_in_GB,
  (total_bytes-available_bytes)/1024/1024/1024 used_space_in_GB, ((total_bytes-available_bytes)*100 / total_bytes) USed_percent,
     * from  sys.dm_os_volume_stats(5,2)


select (total_bytes-available_bytes)*100 / total_bytes from sys.dm_os_volume_stats(5,1)


  
sp_helpdb bhanu1
-- This DMV is to just view the memory details in a OS. 
 select * from sys.dm_os_sys_memory 
 select virtual_memory_kb/1024/1024 ,* from sys.dm_os_sys_info 
 This DMV is used to find the CPU logical proccessor count and also shows the physical CPU's' exists.
 Physical and Virtual Memory size in bytes. and ** SQL server start time** will also capture here
 Note: SQL server start time can capture in different ways:
 1. Tempdb Creation date and check the tempdb files creation data and time.
 sp_helpdb tempdb
 2. Xp_readerrorlog
 3. eventviewer (from Windows)


 select * from sys.dm_os_waiting_tasks -- It will show the run time sessions with their wait_type .
 select * from sys.dm_os_wait_stats order by 2 desc    -- This wait type is a cummulative where it will keep on 
 --adding the wait counts and their times etc. 
 -- We have a cmd to reset the values of the wait_stats
 dbcc sqlperf('sys.dm_os_wait_stats',clear)

 Wait Types:

 We have Locking mechanisum on the tables we have different types of locks and will
 occur while the queries are executing.
 Lck_m_S,Lck_m_u,Lck_m_u....... 
 
 Lck_m_RS_S and Lck_m_RS_U
 
 This lock has two components: 
 1. a lock in shared mode on the range between two consecutive index entries or rows. 
 The locked range can't' be modified but can be read by other transactions.
2. a lock in update mode on the index entries or rows. The locked rows can’t be accessed
 by other transactions while an update is performed.

LCK_M_RIn_NL
LCK_M_RIn_S
LCK_M_RIn_U
LCK_M_RIn_X

These locks are acquired  Insert Range lock between the current and previous key becuase
It will test the table by applying the lock on it before the actual Lock acquires.

LCK_M_RX_S
LCK_M_RX_U
LCK_M_RX_X

These are the range level locks to apply on a table bases upon the operation.
like selects, Insert, Update.

LCK_M_RX_S
Occurs when a task is waiting to acquire a Shared lock on the current key value, 
and an Exclusive Range lock between the current and previous key.

Note: the only difference b/w Rin and RX is that range lock applies on the Insert
(previous key and current key) and where as RX will acquire the Range Lock on entire
Table level. In such case if any operation like select,, update, insert comes.
RX_s, RX_U, RX_X locks will appear.  


Latches:
IMP link: http://www.sqlpassion.at/archive/2014/06/23/introduction-to-latches-in-sql-server/

Introduction to Latches in SQL Server


This is low-level synchronization object used by SQL Server:
 Latches. A latch is a lightweight synchronization object used by the Storage Engine of SQL Server to protect internal memory
  structures that can’t be accessed in a true multi-threaded fashion. In the first part of the blog posting I will talk about
   why there is a need for latches in SQL Server, and in the second part I will introduce various latch types to you,
    and how you can troubleshoot them.

Why do we need Latches?

Latches were first introduced in SQL Server 7.0, when Microsoft first introduced row-level locking. 
For row-level locking it was very important to introduce a concept like latching, because otherwise
 it would give rise to phenomena like Lost Updates in memory. As I have stated above, a latch is a 
 lightweight synchronization object used by the Storage Engine to protect memory structures used internally 
 by SQL Server. A latch is nothing more than a so-called Critical Section in multi-threaded programming – 
 with some differences.

In traditional concurrent programming, a critical section is a code path, which must always run
 single-threaded – with only one thread at a time. A latch itself is a specialized version of a 
 critical section, because it allows multiple concurrent readers. In the context of SQL Server this 
 means that multiple threads can concurrently read a shared data structure, like a page in memory, 
 but writing to that shared data structure must be performed single-threaded.

A latch is used to cordinate the physical execution of multiple threads within a database,
whereas a lock is used on a logical level to achieve the required isolation based on the 
chosen isolation level of the transaction. You, as a developer or DBA, can influence locks
 in some ways – e.g. through the isolation level, or also through the various lock hints
  that are available in SQL Server. A latch on the other hand, can’t be controlled
   in a direct way. There are no latch hints in SQL Server, and there is also no
    latch isolation level available. The following table compares locks and 
	latches against each other.

Locks vs. Latches

latches also support more fine grained modes like 
Keep and Destroy. A Keep latch is mainly used for reference counting,
 e.g. when you want to know how many other latches are waiting on a specific latch.
  And the Destroy latch is the most restrictive one (it even blocks the KP latch),
   which is used when a latch is destroyed, e.g. when the Lazy Writer wants to 
   free up a page in memory. The following table gives you an overview of the
    latch compatibility matrix in SQL Server.

Latch Compatibility Matrix

In the following short flipchart demo, 
I want to show you why latches are needed in SQL Server, 
and which phenomena would happen without them.

As you have seen in the previous flipchart demo, 
consistency can’t be achieved in SQL Server with locking alone.
 SQL Server still has to access shared data structures that are not 
 protected by the lock manager, like the page header. 
 And even other components within SQL Server that have single-threaded
  code paths are built on the foundation of latches. 
  Let’s continue therefore now with the various latch types in SQL Server,
   and how you can further troubleshoot them.

Latch Types & Troubleshooting

SQL Server distinguishes between 3 different types of latches:
IO Latches -> PageIOlatch 
Buffer Latches (BUF) -> PageLatch
Non-Buffer Latches (Non-BUF) -> Latch

Latchs are of different modes:
1. Latch_NL : NUll -> No Latch
2. Latch_KP -> Keep-> Have two purposes: to keep a page in the buffer cache
 while another latch is placed upon it, and the second is to maintain reference counts.
3. Latch_Sh:  SHARED latch (SH): Taken out when a request to read the data page is received.
4. UPDATE latch (UP): Milder than an EX latch, this allows reads but no writes on the page while being updated.
5. EXCLUSIVE latch (EX): Severe latch that allows no access to the page while being written. Only one per page can be held.
6. DESTROY latch (DT): Used to destroy a buffer and evict it from the cache (returning the page to the free list).

Lets discuss about the why the pages are being destoryed from the buffer pool.
1. Lazy Writer
2. Dirty pages
3. Check point
4. Page life expectency 
5. Buffer cache Hit ratio

Lazy Writer: It is used by SQL server itself. This will be in sleeping mode majority.
It will appears only if the Buffer pool is getting filled up and full. 
It's' main purpose is to free up the space to the Buffer pool becasue the further pages 
should insert into it. 
--Mechanisum of Lazy writer:
1.First it will check the Buffer pool and immediately a Check point will occur on it.
2. Once the Check point occurs, all the Modified pages (dirty pages) in it will moved to 
I/O sub system (data files). 
3. Then it will start removing the old pages from the buffer in a phenomenon
 of "Last unused pages" to remove first from the buffer. So it will check all the pages and 
 their last used time. and starts removing the pages. It will continue the process untill 
 it reaches the available free space for new inserting pages into the buffer. 
 4. Once acheived that again Lazy writer will move to sleeping mode. 

 Dirty pages: These are the modified pages in the Buffer Pool. 

 Check point: It is a save point to apply on the transaction to save into a Data file.
 Once the transaction is committed we cannot rollback it. 

 Page Life expectency:
 It is a Percentage of checking the expected life of the page in the Buffer Pool.
 It should be in more % . Also if it is more %, then the retrivial will be faster.

 Buffer cache Hit Ratio:
 It is a page Checking Percentage. where it will verify the page that how many times 
 it is hitting the buffer cache to retrive the records of a table. 
 If the pages always found in the buffer for their selects then the "Page Life Expectency"
 is good and also hitting ratio will also increased.
 Normally it should be more than 80% to have a performance. 
 If you clear the buffer then all the pages in the buffer will be flushed out and percentage
 of Page life and hit ratio will decrease. 

 Also we have other types of latches on Buffer called as PageLatch.
 Also we have other types of latches on pages in IO level called as PageIOLatach.
 Note: Same type of modes are repeated here like Null, Keep, Shared, Exculsive, update, Destroy.

 IO_COMPLETION : It is doing task on IO to get it complete. 
 ASYNC_IO_COMPLETION : It means the IO operation on sql in not in sync with the 
 Disk immediately. There is a delay in syncing the data. 
 ASYNC_NETWORK_IO : Delay is becasue of Network. 
 ***CXpacket: This wait type will appears if the query is running under parallesium . 
 DBMIRRORING_CMD : While the Db is in Mirroring while the data is being transferred.

 BACKUP
BACKUPBUFFER
BACKUPIO
BACKUPTHREAD
All these wait types are for backups and reason for delays. 

WRITELOG : This wait appears while the data is loading into log file.

select * from sys.dm_os_performance_counters

-- Transaction related DMV and DMF


select * from sys.dm_tran_active_transactions
select * from sys.dm_tran_current_transaction


** Below two dmv's' are important in transaction related.
Because it will capture the Transaction based Log utilization in Byte and transaction log count.
So we can identify the trans action size if it is growing in a DB.
Also before killing the sessions it is very good to recommanded to check the SIze of transaction. 

** We can join these dmv's' with execution related dmv to get much info
of query, io, cpu, execution plan of a transaction. 

select database_transaction_log_bytes_used/1024/1024/1024 Log_in_GB,* from sys.dm_tran_database_transactions
select * from sys.dm_tran_session_transactions
