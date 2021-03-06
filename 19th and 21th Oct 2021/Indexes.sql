Index:
What is index and it's' importance.
Ans: Indexes are used to improve the query performance while retriving. 
We will create Indexes on tables and views. 
we can create different types of index depends upon the type of data we use 
in the table. 

-> Types of Indexes
- Clustered : IF the table have a unique data records then it is recommended to 
create clustered Index. 
- Cluster Index will sort the data either in ascending or desending order in an index pages.
- So if the table already have a primary key, then MS is recommended to create cluster index
on the same column data. 
- Reason behind creating cluster index on primary key column is that 
As the primary key column will sort out the order either in ascending or desending. 
If you create cluster Index on different column apart from primary key column again 
it will try to sortout the data. which will re-arrange the existing order of primary key
column. So it is a collusion . It is recommended to create both primary key and cluster
Index on same Column. Also we should not create multiple Cluster Indexes on a table 
because of sorting the data. 

B-tree Structure->  Cluster index uses B-tree and will create Index pages in a sort order
 and actually data will be saved in the index page while retriving it. 
 So it is very faster action to pull the data.
 Also it will take much space in creating a index pages. 

Nodes levels are root Level, Intermediate Level, Leaf level.
Note: The Cluster Index will arrange the data in a order using B-tree structure.
Ex: if the total records 1000 in a table
               1000  -- Root Level
        1-500        501-1000    -- Intermediate Level
    1-250  251-500  501-750   751-1000  -- Intermediate Level
	...............................
  ..............................................
  .......................................................
  1 2 3 4 5 6 7 8 9 10............................ 995 996 997 998 999 1000 -- Leaf level

 Note: In Cluster Index the actual data will be available in leaf level only.
 Also it is not a good practice to do much DML opertaion on Cluster Index Coulmn data. 
 Because it create more over head to re-arrange the order of the data in the index page and 
 it's' address gets change regularly. 
  
2)  Non- Clustered Index:
-These are other type of Indexes, Where we can add multiple coulmn 
in non- clustered Index. 
-We can have 'n' no.of non-clustered Indexes in a table.
-In non cluster Index pages, the coulmn data and their respective address space will
be saved to retrive it , but not the actual data. 
-So we do not have any dependencies with other column or other non- cluster indexes. 
-Also we can add one or more columns in a single non-cluster index.
-Also we can add new column to an existing non- cluster index called as Covering Index. 


Unique Index: 
Creating an index on a unique constraint column called as Unqiue Index.
We can create clustered or non-clustered Index on a unique constraint column.
Based upon the creation the name will be derived. 
-Unique cluster  Indexes.
-Unique non-cluster Indexes.
-non-Unique cluster Indexes
-non-Unique non-cluster Indexes.


Heap Table: A table without any Indexes especially without an Cluster Index column
called as Heap Table.


We can see how the indexes are operating on the table by using Execution plans only.
Execution Plan on Index created tables:
1. Table Scan : 
This operation occurs if the table does not have any Index and if
search element on a single or multiple column will results in sequential search in 
the table to find the result set. In such case, we can see Table Scan on a table.
It is performance degrade. So it is recommended to create a index on a search coulmn.

Ex: table does not have any index
select * from <table_name>
or
select * from <table_name> where column='values'

2. Index Scan :
This operation occurs if the coulmn does not have index on it, but the Table have 
index on other columns. Depends on the type of index exists in the table the name changes.

If the table have only Cluster Index and the search element does not have any index on it
 then the operation shows as "Clustered index scan"
 Ex: select * from [dbo].[new_tab1] where dept_no in(10,20,30)
 "id" have clustered Index and search element does not have any index. 

If the table have non-cluster and the search element does not have any index on it
and the retriving element have non-cluster index on it then we can see  "index scan" on non-clustered. 
Ex: select name from [dbo].[new_tab1] where salary=1000
"name" have non- clustered index and salary does not have any index.
then you may see "index scan".

3. Seek: 
This operation occurs if the coulmn have index on it and the select element 
belongs to the index.
We have clustered and non -clustered Seek.

Index seek on non-clustered will appears if the search element is part of non-clustered index.
Ex: select dept_no from [dbo].[new_tab1] where name='bhanu'
"Name" is non-clustered index.

Index seek on clustered Index  will appears if the search element is part of clustered index.
Ex: select dept_no from [dbo].[new_tab1] where id=10
"id" is clustered Index.

Note: Seek is a performance improvement where it will not sequencially search for the data.
If will search for the data dependencies on the type of index we use. 


6. lookups(RID lookup and Bookmark lookup)  
Looksups are the performance degrade operations.
-> RID Lookup appears if the table does not have cluster index and the search element
have non-clustered index and the retrival elements are the columns without any indexes.

To supress the RID lookup we need to create a non-cluster Index on the retrival element
or we can add as covering index on existing non-clustered index as well. 
Also create a cluster index but check the possiability of creating it. 
Case:
select dept_no,id,name,salary from [dbo].[new_tab1] where name ='bhanu'
 For this query, we will see "table scan".
 -> Create a non-Cluster Index on a column (id) 
 Now we can see "Index Scan"
 -> Create non-clustered index on column(dept_no, name) 
 -> Now we can see "RID Lookup" as the retrival column all may not have 
 Indexes and  still any of the column does not any index and
  it is participating in retrival. So it results in RID lookup.
  -> Create non-cluster index on a column where it is missing index.
Syntax: Here i added Covering Index or create new non-cluster index on that column. 
create nonclustered Index id_noncluster_new_tab2 on [dbo].[new_tab1](name,dept_no)
include(salary)
or
create nonclustered Index id_noncluster_new_tab2 on [dbo].[new_tab1](salary)

-> Now check the execution plan it will show the "Index seek" on the query which will
improve the performance. 
 Syntax : 
 CREATE NONCLUSTERED INDEX id_noncluster2_new_tab1
ON [dbo].[new_tab1] (name)
INCLUDE (dept_no,id)

Now in the result check the execution plan again , now we can see "Index seek" which 
improves the query performance. 

-- Bookmark lookup or Key Lookup.

Bookmark Lookup appears on the table we have clustered index and the search element
have clustered or non-clustered index and the retrival elements are the columns without any indexes.

Inorder to supress the key or bookmark lookup. 
We need to create non-clustered Index or covering index
on the columns participated in the query selection. So we can eleminate key lookup
and results in Index seek which will improve the performance. 

Case:
select dept_no,id,name,salary from [dbo].[new_tab1] where name ='bhanu'
 For this query, we will see "table scan".
 -> Create a Cluster Index on a column (id) 
 Now we can see "Index Scan"
 -> Create non-clustered index on column(dept_no, name) 
 -> Now we can see "Key Lookup" as the retrival column all may not have 
 Indexes and  still any of the column does not any index and
  it is participating in retrival. So it results in Key lookup.
  -> Create non-cluster index on a column where it is missing index.
  Syntax: Here i added Covering Index. 
create nonclustered Index id_noncluster_new_tab2 on [dbo].[new_tab1](name,dept_no)
include(salary)
-> Now check the execution plan it will show the "Index seek" on the query which will
improve the performance. 

Reference Link for lookups:

https://mostafaelmasry.com/2013/06/17/bookmark-lookup-key-lookup-rid-lookup-in-sql-server/

->Performance improvment using Cluster and non-cluster Indexes.
->Maintainence on Indexes.
-> Fragmentation on the Index.
-> De-Fragmentation the Index
-> Rebuild Index
-> Re-organise Index


-> Missing Indexes
-> Unused Indexes.
-> Covering Indexes.

Syntax:

/****** Object:  Index [x]    Script Date: 11/7/2017 11:04:22 AM ******/
CREATE NONCLUSTERED INDEX [INDEX Name] ON [dbo].[CustomerAddress]
(
	[CustomerID] ASC,
	[AddressID] ASC
)

WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, 
DROP_EXISTING = OFF, ONLINE = On, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
 ON [fg1]
GO
[dbo].[CustomerAddress]