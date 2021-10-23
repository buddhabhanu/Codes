--DB Performance Tunning and health checks
- Indexes
--system catalogs on DB server health check
-- This catalog is used to check the blocking and session details. 
select * from sys.sysprocesses
-- Here we can pull the details of only blocking sessions. 
select * from sys.sysprocesses where blocked>0
select * from sysprocesses where spid=79

Note: the SPID below 51 are system process ID. ( From spid 51 it is user sessions)
Note: spid= the session id notifies which is getting blocked.
Blocked= This session is blocking the main spid. 
note: we may have multiple blocking as well. we need to find the head blocker. 
And provide the details to the dev team but do not attemp to kill the sessions. 

--To kill any of the sessions
kill 80 -- pass the spid
kill 80 with statusonly
Note: once you kill the session it will start rollback of the transaction and will remove
 the completed DML's' in this batch. 
 Ex: if a transaction executed 70% and if we killed the session then it will start
  rollback(remove) the completed DML's'of  70% to it's' initial state
   as part of the ACID property. 
So it will take some time to release the session.
-- to check the status of the rollback state. 
kill 80 with statusonly

o/p: SPID 80: transaction rollback in progress. Estimated rollback completion: 0%. Estimated time remaining: 0 seconds.
select waittime/60000 as wait_in_mins,convert(varchar(200),spid) +' blocked by '+ convert(varchar(200),blocked), db_name(dbid),*
 from sys.sysprocesses where blocked>0

sp_who -- It a system proc, It will display the all the currently connected sessions in the DB server.
sp_who 66 -- It is like where condition where it will display only specific session details. 
sp_who active-- It will show only the currently user running/ runnable sessions. but not any sleeping/dormate sessions.

sp_who2 -- it is a next version of the sp_who and will have additional column 
of CPU time, Disk i/o, Last batch, program name. and can use same as sp_who and their parameters as well. 

-- stats related catalog. 
select * from sys.stats
-- we can see the stats of the I/o Operation of the queries. And it is a enabled only in specific session. 
--We can set either the stats on or off to check the physical/ logical reads, and writes on the disk. 
SET STATISTICS IO on
go
select * from [dbo].[my_tab1]

-- We can check the DB server health from Activity Monitor . 
In order to view the DB activity monitor we should have either a SYSadmin or a user should
 have "View Server State" server permissions.

 We can view the Session info, Disk i/o, expensive queries etc in GUI.
 But it is not recommended to check the Activity Monitor if the Server is suffering from 
 huge pressure like CPU, Disk I/o, Memory. 
 Note: We also have alternative to check the server health by using DMV and DMF's'
 which will not consume much resources. 

 Also USing GUI we can also check the Db health from the reports and also server health from the reports.
 Navigating: On a DB-> rt click-> reports
 Navigating: On server-> rt click-> reports

 Blocking: 
 dbcc inputbuffer(79)
 select * from sys.dm_exec_sql_text(0x010005008A1EF90B202182750100000000000000)


