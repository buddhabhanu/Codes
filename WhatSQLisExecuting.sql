--	select GETDATE()
-- select * from sysprocesses

use master		
  --sp_lock dbcc tracestatus(-1)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
select				--  DBCC MEMORYSTATUS dbcc inputbuffer(58) DBCC TRACESTATUS (-1)
      r.session_id,
	  s.loginame,
      r.start_time,
      s.hostname,
  CAST(((DATEDIFF(s,start_time,GetDate()))/3600) as varchar) + ' hour(s), ' 
        + CAST((DATEDIFF(s,start_time,GetDate())%3600)/60 as varchar) + 'min, ' 
        + CAST((DATEDIFF(s,start_time,GetDate())%60) as varchar) + ' sec' as RUNNING_TIME,
      --r.blocking_session_id,
	  s.blocked,
      r.command,
      db_name(r.database_id) as Database_name,
      r.wait_type,
      --r.wait_time,
      --r.open_transaction_count,
      r.cpu_time,
      r.total_elapsed_time as 'time(ms)',
      r.percent_complete,
      SUBSTRING(t.text, (r.statement_start_offset/2)+1, 
        ((CASE r.statement_end_offset
          WHEN -1 THEN DATALENGTH(t.text)
         ELSE r.statement_end_offset
         END - r.statement_start_offset)/2) + 1) AS CurrentQuery,
	  t.text as ParentQuery      
from sys.dm_exec_requests r
	cross apply sys.dm_exec_sql_text(r.sql_handle) t
	join sys.sysprocesses s on (r.session_id = s.spid)
where r.session_id > 50
and r.session_id != @@spid

/*

-- To see blocking and running sessions

select der.blocking_session_id as blking_spid
,der.session_id as spid
,der.status
--,des.deadlock_priority
,der.wait_type
,der.wait_time 
,der.cpu_time as cpu_tm
,der.writes
,der.reads 
,der.logical_reads as L_reads
,der.Command
,der.row_count
,der.percent_complete as '%complete'  
,db_name(der.database_id) as dbname      
,SUBSTRING(SQLText.text, statement_start_offset/2 + 1,2147483647) as query
,object_name(SQLText.objectid,der.database_id) as object_name
,der.total_elapsed_time       
,des.host_name as c_host
,dec.client_net_address as c_ip           
,des.program_name
,des.login_name
,dec.auth_scheme
,dec.net_packet_size as packetsize
,dec.net_transport
,der.plan_handle
,SQLPlan.query_plan
,deqmg.used_memory_kb
from sys.dm_exec_requests der join sys.dm_exec_sessions des
on (der.session_id = des.session_id) join sys.dm_exec_connections dec
on (des.session_id = dec.session_id) left outer join sys.dm_exec_query_memory_grants deqmg
on (der.session_id = deqmg.session_id) 
cross apply sys.dm_exec_sql_text(der.sql_handle) as SQLText
cross apply sys.dm_exec_query_plan(der.plan_handle) as SQLPlan
where der.session_id > 50
and der.session_id <> @@SPID
order by der.total_elapsed_time desc








-- Query to get execution plan with query details
SELECT r.session_id, t.text,
    r.plan_handle,
    r.statement_start_offset,
    r.statement_end_offset,
    query_plan = (
        SELECT CONVERT(xml, query_plan)
        FROM sys.dm_exec_text_query_plan (
            r.plan_handle, 
            r.statement_start_offset,
            r.statement_end_offset
        )
    )
FROM sys.dm_exec_sessions s
JOIN sys.dm_exec_requests r
    ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE s.is_user_process = 1


*/

--Top 20 CPU utilization with queries

/*
SELECT TOP (20)
    st.text AS Query,
	qp.query_plan,GETDATE() as [date time],
    qs.execution_count,
    qs.total_worker_time AS Total_CPU,
    total_CPU_inSeconds = --Converted from microseconds
    qs.total_worker_time/1000000,
    average_CPU_inSeconds = --Converted from microseconds
    (qs.total_worker_time/1000000) / qs.execution_count,
    qs.total_elapsed_time,
    total_elapsed_time_inSeconds = --Converted from microseconds
    qs.total_elapsed_time/1000000
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
CROSS apply sys.dm_exec_query_plan (qs.plan_handle) AS qp
ORDER BY qs.total_worker_time DESC OPTION (RECOMPILE);


*/




--  select * from  sys.dm_exec_requests		select * from sys.sysprocesses where blocked >51

/*
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED --  master..xp_readerrorlog 1 -- sp_who2 active 79 kill 120 --  dbcc inputbuffer(216) -- kill 216

    -- What SQL Statements Are Currently Running?
    SELECT [Spid] =    session_Id
    ,start_time
	, ecid
	, [Database] = DB_NAME(sp.dbid)
	, [User] = nt_username
	, [Status] = er.status
	, [Wait] = wait_type
	/*, [Individual Query] = SUBSTRING(qt.text, (qs.statement_start_offset/2)+1, 
        ((CASE qs.statement_end_offset
          WHEN -1 THEN DATALENGTH(st.text)
         ELSE qs.statement_end_offset
         END - qs.statement_start_offset)/2) + 1)*/
	,[Parent Query] = qt.text
	, Program = program_name
	, Hostname
	, nt_domain
	, start_time
    FROM sys.dm_exec_requests er
    INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
    CROSS APPLY sys.dm_exec_sql_text(er.sql_handle)as qt
    WHERE session_Id > 50              -- Ignore system spids.
    AND session_Id NOT IN (@@SPID)     -- Ignore this current statement.
    ORDER BY 1, 2
*/


--select * from sys.dm_os_waiting_tasks
/*
SELECT * FROM sys.dm_exec_query_memory_grants where grant_time is null


SELECT mg.granted_memory_kb, mg.session_id, t.text, qp.query_plan 
FROM sys.dm_exec_query_memory_grants AS mg
CROSS APPLY sys.dm_exec_sql_text(mg.sql_handle) AS t
CROSS APPLY sys.dm_exec_query_plan(mg.plan_handle) AS qp
ORDER BY 1 DESC OPTION (MAXDOP 1)


--waits grouped together as a percentage of all waits on the system, in decreasing order 

WITH Waits AS
    (SELECT
        wait_type,
        wait_time_ms / 1000.0 AS WaitS,
        (wait_time_ms - signal_wait_time_ms) / 1000.0 AS ResourceS,
        signal_wait_time_ms / 1000.0 AS SignalS,
        waiting_tasks_count AS WaitCount,
        100.0 * wait_time_ms / SUM (wait_time_ms) OVER() AS Percentage,
        ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS RowNum
    FROM sys.dm_os_wait_stats
    WHERE wait_type NOT IN (
        'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK',
        'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR', 'LOGMGR_QUEUE',
        'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'XE_TIMER_EVENT', 'BROKER_TO_FLUSH',
        'BROKER_TASK_STOP', 'CLR_MANUAL_EVENT', 'CLR_AUTO_EVENT', 'DISPATCHER_QUEUE_SEMAPHORE',
        'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'BROKER_EVENTHANDLER',
        'TRACEWRITE', 'FT_IFTSHC_MUTEX', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
        'BROKER_RECEIVE_WAITFOR', 'ONDEMAND_TASK_QUEUE', 'DBMIRROR_EVENTS_QUEUE',
        'DBMIRRORING_CMD', 'BROKER_TRANSMITTER', 'SQLTRACE_WAIT_ENTRIES',
        'SLEEP_BPOOL_FLUSH', 'SQLTRACE_LOCK')
    )
SELECT
    W1.wait_type AS WaitType, 
    CAST (W1.WaitS AS DECIMAL(14, 2)) AS Wait_S,
    CAST (W1.ResourceS AS DECIMAL(14, 2)) AS Resource_S,
    CAST (W1.SignalS AS DECIMAL(14, 2)) AS Signal_S,
    W1.WaitCount AS WaitCount,
    CAST (W1.Percentage AS DECIMAL(4, 2)) AS Percentage,
    CAST ((W1.WaitS / W1.WaitCount) AS DECIMAL (14, 4)) AS AvgWait_S,
    CAST ((W1.ResourceS / W1.WaitCount) AS DECIMAL (14, 4)) AS AvgRes_S,
    CAST ((W1.SignalS / W1.WaitCount) AS DECIMAL (14, 4)) AS AvgSig_S
FROM Waits AS W1
    INNER JOIN Waits AS W2 ON W2.RowNum <= W1.RowNum
GROUP BY W1.RowNum, W1.wait_type, W1.WaitS, W1.ResourceS, W1.SignalS, W1.WaitCount, W1.Percentage
HAVING SUM (W2.Percentage) - W1.Percentage < 95; -- percentage threshold
GO

--To Kill the sessions uder specific Login and Host and with only Selects which runs more than 30 mins
select +'KILL ' +convert(varchar(100),spid),* from sys.sysprocesses where loginame='GIFFD_user' and hostname='us18gicgifdappp02' and cmd='Select'  and datediff(SS,login_time,GETDATE()) > 1800

-- To get the User sessions which runs more than 35 mins
select		
      distinct r.session_id,
	  s.loginame,
      r.start_time,
	  	  CAST(((DATEDIFF(s,start_time,GetDate()))/3600) as varchar) + ' hour(s), ' 
        + CAST((DATEDIFF(s,start_time,GetDate())%3600)/60 as varchar) + 'min, ' 
        + CAST((DATEDIFF(s,start_time,GetDate())%60) as varchar) + ' sec' as RUNNING_TIME,
      s.hostname,
      db_name(r.database_id) as Database_name,
      SUBSTRING(t.text, (r.statement_start_offset/2)+1, 
        ((CASE r.statement_end_offset
          WHEN -1 THEN DATALENGTH(t.text)
         ELSE r.statement_end_offset
         END - r.statement_start_offset)/2) + 1) AS CurrentQuery,
	  t.text as ParentQuery  
from sys.dm_exec_requests r
	cross apply sys.dm_exec_sql_text(r.sql_handle) t
	join sys.sysprocesses s on (r.session_id = s.spid)
where r.session_id > 50
and s.loginame not in ('NT AUTHORITY\SYSTEM')
and s.loginame not in ('tsi\svc_sqlgiw')
and s.loginame not in ('sa')
and s.loginame != ''
and r.session_id != @@spid 
and datediff(SS,r.start_time,GETDATE()) > 2000


--transaction Log check 
select database_transaction_log_bytes_used/1024/1024/1024 as database_transaction_log_in_GB ,database_transaction_log_record_count,db_name(database_id),* from sys.dm_tran_database_transactions where 
transaction_id=(
select transaction_id from sys.dm_tran_session_transactions where session_id=175)

-- Checking the current running backups details

select session_id,start_time,status,command,db_name(database_id),wait_type,wait_time,transaction_id,percent_complete,(estimated_completion_time/ (1000*60) % 1000) as Remaining_time_in_mins
 from sys.dm_exec_requests where command like '%backup%' or command like '%restore%'and session_id>=51

-- Sessions waits Details
select * from sys.dm_exec_session_wait_stats where session_id=224
*/