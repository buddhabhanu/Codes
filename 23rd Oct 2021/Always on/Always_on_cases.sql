-- Always on HADR

--While performing the Failover on the Ao.
Ans: 
We should be cautious while performing AO failover.
Make sure the Mode used on the AO group.
If the AO group is in Sync mode, All the databases will be in Syncronized and no proability
of lossing data while failover. So we can perform failover and later check the dashboard
for Health.

If the AO Group is in Async Mode, It means data safety is not guarantee. So while failover there
can be possiability of data loss. So inorder to overcome before the failover:
1. Change the Mode to SYNC Mode 
Navigate: Rt click on AO group-> properties-> Sync mode
Note: Check wheather all the DB's' are in Sync (synronized state) mode.
2. After the check, We are good to failover the AO to other replica.
3. After the failover completes, Check the Dashboard for the healthy(should be green).
4. Again Change the Mode back to Async Mode.

Note: If the AO group is in Async mode and if any failover performed then there is a
possiability of data loss and also after a failover on the secondary the DB's' will not be 
added in Synronized in the AO automatically. 
It looks in suspend state. Manually change every DB to "resume" on the AO group.


2. If any schema changes on the DB in the AO group then we should first remove the DB 
from the AO group ,by just rt click on the "available Databases" in the Group and remove it.

Once the changes on the DB completes again we can add the DB back in the AO group. 
Make sure the log backup are triggered in the meanwhile should be restored on the Secondary DB.
Once all Logs are restored, trigger another Log backup after the schema changes. then restore
the same on Secondary and add the DB in the AO group. 

Note: If the log backup schedule to Null Backups.
Then before the schema changes, Disable the Log backup job .


