-- DBCC Commands Prepared By Bhanu Buddha 
-- Full form for DBCC is DataBase Console Commands
We have so many DBCC in sql server but we use and imp DBCC only few in  real time on daily basis.
The use of DBCC is to pull the SQL server details like Query details, consistancy check, index checks,
statistics check, buffer checks, shrink operation ...etc 
DBCC commands like are: 
DBCC help('indexdefrag')
DBCC CheckDB
DBCC Inputbuffer(64)
DBCC opentran
DBCC indexdefrag
DBCC DBreindex
DBCC sqlperf
DBCC show_statistics
DBCC showcontig
DBCC Shrinkdatabase
DBCC shrinkfile
DBCC Proccache
DBCC Dropcleanbuffers-- Never do it in Prod yservers
DBCC freeproccache -- Never do it in Prod servers-- This is sometimes acceptable. 
DBCC freesystemcache-- Never do it in Prod servers
DBCC checkalloc
DBCC checkident
DBCC Checktable
DBCC cleantable
DBCC traceon
DBCC traceoff
DBCC tracestatus
DBCC updatesuage
DBCC Page -- Undocumented 



DBCC CheckDB : 
It will check the database consistency check and it means that it will dig into page levels
and will identify the data pages , index pages and other pages to find the corrupted pages in it.
These pages called as inconsistency pages and it needs repairs on those pages to make the 
DB as consistent. To repair we have commands in the CHECKDB .

Inorder to execute the DBCC checkdb, Make sure that we have proper Downtime window or
when the users active is less. prefer to run on non-business hours. (saturday,sundays)
Becasue while checking the consistency the objects like tables and indexes in it will be
locked and performs the check. 

If the pages are corrupted , If the count reaches 1000 pages. then the DB can called as
corrupted and it goes to suspect mode.  

So it is recommended to schedule a job once in a week or once in two weeks. And observe
Output in the job logs for the corrupted pages. 

Procedure: 
--If the Db went to suspend mode. There may be any reason we need to identify the issue.
Since the DB is in suspend, no one can open the DB and also existing connections will be
remain as it is. Now we need to remove the existing connections and start ivestigation.

Step-1: Bring the Db into Single user. So that no one access and existing connection will be
removed.
SELECT * from sys.dm_os_r
Alter database <DB Name> set single_user with rollback immediate

Step-2: Now the DB is in single_user mode and can change it to Emergency Mode to perform Checkdb.

Alter database <DB Name> set Emergency 

Step-3: We can start checking the consistency Check on it. 

DBCC CHECKDB WITH ALL_ERRORMSGS
dbcc CheckDB 
(
    { 'database_name' | database_id | 0 } -- Pass your database name or dbid 
    [ , NOINDEX -- Pass "NOINDEX" if you do not want to check the index consistency check.
    | { REPAIR_ALLOW_DATA_LOSS -- Use of this cmd should be last action becasue It will repair the
	corrupted Page by removing the corruption area and it will loose that data in the page. 
    | REPAIR_FAST -- Maintains syntax for backward compatibility only. No repair actions are performed.
    | REPAIR_REBUILD -- It will repair only the Index pages but not data pages. 
    } ]
)
    [ WITH
        {
            [ ALL_ERRORMSGS ]-- It will show  the output of the checkdb with details of corruptuion pages. 
            [ , [ NO_INFOMSGS ] ] -- It will not show  the output of the checkdb.
            [ , [ ESTIMATEONLY ] ] -- It will show the tempdb estimate size to perform checkdb for a DB becasue the CHECKDB will take a
			--copy of data into tempdb and will perform the check. So it is very imp to check the estimate before running the 
			--consistency check. 
            [ , [ PHYSICAL_ONLY ] ] -- It will check on the data files on the pages only the physical structure like header, body only.
			--but it can also detect torn pages, checksum failures, and common hardware failures that can compromise a user's 
			--data. Becasue Logical check will have more stress to dig into the data level corruption. 
            [ , [ DATA_PURITY ] ] --Causes DBCC CHECKDB to check the database for column values that are not valid or out-of-range. 
			--For example, DBCC CHECKDB detects columns with date and time values that are larger than or less than the 
			--acceptable range for the datetime data type; or decimal or 
			--approximate-numeric data type columns with scale or precision values that are not valid.
			-- It is by default will check the data purity for a DB. Normally when we use this while the DB is updraging b/w 
			--the sql server or migrating the servers. Note: If PHYSICAL_ONLY is specified, column-integrity checks are not performed.
            [ , [ EXTENDED_LOGICAL_CHECKS  ] ] --performs logical consistency checks on an indexed view, XML indexes, and spatial indexes, where present.
			 [ , MAXDOP  = number_of_processors ] -- we can set MAXDP count for this query to run for this checkdb. 
			    [ , TABLOCK ]   -- It will perform the Exclusive(X) lock on the objects while the 
				-- CHeckdb performs.
        }
    ]

CASE:
	dbcc checkdb (5) with estimateonly 
	output:
 /* 
 DBCC results for 'bhanu1'.
Estimated TEMPDB space (in KB) needed for CHECKDB on database bhanu1 = 1863.
CHECKDB found 0 allocation errors and 0 consistency errors in database 'bhanu1'.
DBCC execution completed. If DBCC printed error messages, contact your system administrator.
*/ 

DBCC Inputbuffer(59)-- To view the query in the transaction from the SPID. We can view the 
--current running query in it. And no performance Impact to run this DBCC.

DBCC opentran-- This CMD should run on a specific DB to get their results of open transaction of the same DB.
--this CMD works under a DB context but not gobal. It will list the open trans on a specific DB.
DBCC indexdefrag -- This CMD is to reorganise the specific table index or View Index. 
-- So we need to pass parameters to perform Index reorg on a Specific Index.
--Parameters are below
Syntax: 
dbcc indexdefrag 
(
    { 'database_name' | database_id | 0 }  -- Pass the DB name
    , { 'table_name' | table_id | 'view_name' | view_id }-- Pass the table or view names
    [ , { 'index_name' | index_id } -- Pass the Index name of it
    [ , { partition_number | 0 } ] ] -- Specify the partition name or id of it. 
)
    [ WITH NO_INFOMSGS ]-- Not to show the details of the output. (this is optional)
	Ex: dbcc indexdefrag (9,'emp','id_dept_non_clustered',0)

D  -- This CMD is to rebuild the Specific Index on a table in a DB. 
-- Also can specify the Fill factor threshold while rebuilding the index. 
-- Run this CMD in a specific DB context only. 
Syntax: 

dbcc DBreindex 
(
    'table_name' -- pass a table name
    [ , 'index_name'  -- Pass a index name
	[ , fillfactor ] ] -- Set fill factor value
)
    [ WITH NO_INFOMSGS ]-- Not to show the details of the output. (this is optional)
Ex: dbcc DBreindex ('emp') -- It rebuild all the Indexes in a table with default Fill factor as 100.
DBCC sqlperf() : 

SYntax:
dbcc sqlperf(logspace)-- It will show the Usage stats of the t-log space and percentage of it. 
DBCC sqlperf("sys.dm_os_wait_stats" , CLEAR )-- It will reset the values of the DMV specified in the parameters.
DBCC sqlperf("sys.dm_os_latch_stats" , CLEAR )-- It will reset the values of the DMV specified in the parameters.
select * from sys.dm_os_wait_stats

DBCC showcontig-- This CMD will show the details of the pages and Index fragmentation 
--of every object in the database. 
--sample Output of the one table.
/*
Table: 'new_tab1' (565577053); index ID: 1, database ID: 5
TABLE level scan performed.
- Pages Scanned................................: 47
- Extents Scanned..............................: 6
- Extent Switches..............................: 5
- Avg. Pages per Extent........................: 7.8
- Scan Density [Best Count:Actual Count].......: 100.00% [6:6]
- Logical Scan Fragmentation ..................: 0.00%
- Extent Scan Fragmentation ...................: 0.00%
- Avg. Bytes Free per Page.....................: 53.0
- Avg. Page Density (full).....................: 99.34%
DBCC SHOWCONTIG scanning 'new_tab1' table...
*/

DBCC show_statistics("[mygroup3].[new_tab1]",[non_clust_name])
DBCC show_statistics("[dbo].[new_tab1]",[_WA_Sys_00000001_21B6055D])

update statistics [mygroup3].[new_tab1] fullscan

--We can Update the stats of the table
This cmd will update the statistics of all the Indexes in the table for all the records. Also it will 
apply table lock on it while performing. So DO NOT run this while Business Hours.
It will can entire table will all records.
CMD:
update statistics [mygroup3].[new_tab1] fullscan


-- This Cmd will update the stats of the table with Sample records might be 5% of the records.
*** IMP: We can run this command while we are facing Server Slowness and CPU 100% utilization Issues.
CMD : 
update statistics emp 

-- Update stats on a Database. Make sure to run on a specific DB session. 
Also this cmd will be a maintainence Job which runs daily\weekly to improve the Query Performance.

Use <DBName>
go
sp_updatestats


DBCC Shrinkdatabase -- This CMD is to shrink the entire DB. 
Syntax:

dbcc Shrinkdatabase (5,25)
(
    { 'database_name' | database_id | 0 } -- Pass DB name or id
    [ , target_percent ] -- We can set what can be our target free space.
    [ , { NOTRUNCATE |-- It will shrink the DB but it will not release the space to DIsk.
	 TRUNCATEONLY } ] --  It will shrink the DB and also it will release the space to DIsk.
)
    [ WITH NO_INFOMSGS ]-- Not to show the output details.This is optional. 

DBCC shrinkfile-- This CMD is to shrink the specific File of a DB we can perform in 3 ways .

dbcc shrinkfile 
(
    { 'file_name' | file_id }  -- Specify the Logical file name of a DB
    {
        [ , EMPTYFILE] -- To empty the existing file (3rd type in the below)
        | [ [, target_size ] -- To shrink the file to a specific Size.(2nd type in the below)
		[ , { NOTRUNCATE | -- It will shrink the file but it will not release the space to DIsk.
		TRUNCATEONLY } ] ]  --  It will shrink the file and also it will release the space to DIsk.(1st type in the below)
    }
)
    [ WITH NO_INFOMSGS ] -- Not to show the output details.This is optional. 

1. To release all unused space.
2. To shrink the file to a specific Size. 
3. To empty the file and move the data onto other file in the same file group.
 
DBCC Proccache -- This CMD is to get the details of the procedure cache ,
This is not harm to run in prod server. 
The procedure cache included the following:
Compiled plans
Execution plans
Algebrizer tree
Extended procedures

DBCC freeproccache -- This CMD is very harm to run in prod server.
--Becasue it will remove all the entire Plan Cahches in your SQL Instance from the BUffer. 
--But we remove a specific plan of a procedure by passing plan handler or SQL handler in parameters.
Syntax:
dbcc freeproccache -- Witout parameters  will remove entire plan caches in sql server instances.
[ ( @HANDLE | 'POOL NAME' ) ]-- PAss plan or sql hanlder or pool name
[ WITH NO_INFOMSGS ] -- Not to show the output details.This is optional. 


DBCC Dropcleanbuffers-- This CMD is also very Harmful to run in prod servers.
--It will remove the entire Bufferts from the SYstem. It will lead to performance impact and 
--next executed querries Will reach the I/O to fetch the Data.  
Syntax: 
dbcc Dropcleanbuffers [ WITH NO_INFOMSGS ]


DBCC freesystemcache -- This is also very harmful to run in prod servers.
--It will remove the entire Cache in the system. It will lead to performance impact 
Syntax: 

dbcc freesystemcache 
(
    'ALL' [, 'POOL NAME'] -- All will remove entire Cache
)
    [ WITH
        {
            [ MARK_IN_USE_FOR_REMOVAL ]
            [, [ NO_INFOMSGS ] ]
        }
    ]


DBCC checkalloc -- Checks the consistency of disk space allocation structures for a specified database.
Note: refer to checkdb for more info. 


DBCC checkident -- This CMD is rarely used if we want to reset the identity coulmn values . 
-- Also we can use on this on the table only if it have identity coulmn in it. 

DBCC CHECKIDENT   
 (   
    table_name  
        [, { NORESEED -- 
		| { RESEED 
		[, new_reseed_value ] } } ]  
)  
[ WITH NO_INFOMSGS ]  
/*
DBCC CHECKIDENT ( table_name, NORESEED )	Current identity value is not reset. DBCC CHECKIDENT returns the current identity value and the current maximum value of the identity column. If the two values are not the same, you should reset the identity value to avoid potential errors or gaps in the sequence of values.
DBCC CHECKIDENT ( table_name )

or

DBCC CHECKIDENT ( table_name, RESEED )	If the current identity value for a table is less than the 
maximum identity value stored in the identity column, it is reset using the maximum value in the identity column. 
See the 'Exceptions' section that follows.
DBCC CHECKIDENT ( table_name, RESEED, new_reseed_value )	Current identity value is set to the new_reseed_value. 
If no rows have been inserted into the table since the table was created, or if all rows have been removed by using 
the TRUNCATE TABLE statement, the first row inserted after you run DBCC CHECKIDENT uses new_reseed_value as the identity.

If rows are present in the table, the next row is inserted with the new_reseed_value value. In version SQL Server 2008 R2 and earlier, the next row inserted uses new_reseed_value + the current increment value.

If the table is not empty, setting the identity value to a number less than the maximum value in the identity column can result in one of the following conditions:

-If a PRIMARY KEY or UNIQUE constraint exists on the identity column, error message 2627 will be generated on later insert operations into the table because the generated identity value will conflict with existing values.

-If a PRIMARY KEY or UNIQUE constraint does not exist, later insert operations will result in duplicate identity values.
*/

DBCC traceon  -- We have trace flags in sql server and we can enable in startup parameters to 
--effect your SQl Instance. But it need sql services restart to effect the system.
--So we use DBCC trace on and Off to enable/Disable the trace flags temperorily in sql instances.
We can enable the trace either Locally or Globally.
Locally Mean it will be applicable only to current session.
Sytax: 
DBCC traceon( flag no)

Globally Means It will be applicable to entire SQl instance in any of the sessions.
And the life of this Globle Trace on is till we restart the sql services. 
Syntax:
DBCC traceon (flag no, -1)
-1 will enable the trace in globally. 
  
DBCC traceoff -- This CMD is to disable the trace which is already enabled.
Syntax:
DBCC traceoff(flag no)

DBCC tracestatus -- This CMD is to check the status of the flag num whether it
--enabled or disabled. 
Syntax:
DBCC tracestatus(flag num)

DBCC updateusage( 5,[new_tab1]) with  COUNT_ROWS

sp_spaceused ([new_tab1])
DBCC help('show_statistics')

dbcc traceon(3604,-1)

dbcc tracestatus(3604)


dbcc traceoff(3604),-1)

dbcc help('freesystemcache')

DBCC Page(file no, page no, mode) 
-- This is undocumented DBCC 
We will get the page header info using this cmd but inorder to view the output
we need to enable a trace flag 3604.
Note: M_type is the type of the page will show in the header.


