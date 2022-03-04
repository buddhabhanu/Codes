Param(
  [validateset ("FULL","DIF","LOG")][string]$Type = "",
  [validateset ("NERP","ERP")][string]$Group = "",
  [validateset ("PROD","NONPROD")][string]$Env = "",
  [validateset ("2008","2012","2014","2016")][string]$Ver = ""
)

$backupGroup = $Group
$backupEnvironment = $Env
$backupType = $Type
$backupVersion = $Ver

import-module sqlps  
$Error.Clear()
# set the parameter values  
if($backupGroup -eq "ERP" -and $backupEnvironment -eq "NONPROD")
{
    $storageAccount = "dowsapstorageacct"  
    $blobContainer = "dowsap-container"
    $SASToken = "sv=2015-04-05&sr=c&sig=EYB9kHNZH9EEvLWs3ERUV28wzBXhKtGkbUsJKU2J4cw%3D&st=2018-09-14T18%3A49%3A30Z&se=2019-09-14T19%3A49%3A30Z&sp=rwdl"
    if($backupversion -eq "2008")
    {
        $blobContext = New-AzureStorageContext -StorageAccountName $storageAccount -SasToken $SASToken
    }
}
if($backupGroup -eq "ERP" -and $backupEnvironment -eq "PROD")
{
    $storageAccount = "proddowsapstorageacct"  
    $blobContainer = "proddowsap-container"
    $SASToken = "sv=2015-04-05&sr=c&sig=6xXzTVWD7D%2FBJ4QTQhxiYKDi5YVsgwi7K2iV61QkeT0%3D&st=2018-09-14T19%3A14%3A09Z&se=2019-09-14T20%3A14%3A09Z&sp=rwdl"
    if($backupversion -eq "2008")
    {
        $blobContext = New-AzureStorageContext -StorageAccountName $storageAccount -SasToken $SASToken
    }
}
if($backupGroup -eq "NERP" -and $backupEnvironment -eq "NONPROD")
{
    $storageAccount = "downerpstorageacct"  
    $blobContainer = "downerp-container"
    $SASToken = "sv=2015-04-05&sr=c&sig=d8B10MfqXvJ%2BDmX5CQ1p7e2YwD0WhEHgXla8tAUTomo%3D&st=2018-09-14T19%3A24%3A13Z&se=2019-09-14T20%3A24%3A13Z&sp=rwdl"
    if($backupversion -eq "2008")
    {
        $blobContext = New-AzureStorageContext -StorageAccountName $storageAccount -SasToken $SASToken
    }
}
if($backupGroup -eq "NERP" -and $backupEnvironment -eq "PROD")
{
    $storageAccount = "phazd0460sa"  
    $blobContainer = "prod-backups-archive"
    $SASToken = "sv=2019-02-02&sr=c&si=prod-backups-archive-policy&sig=JQCvb%2BLOUrpqWwjeeoUSmnGKjj7NU63w0zH05oRjtgc%3D"
    if($backupversion -eq "2008")
    {
        $blobContext = New-AzureStorageContext -StorageAccountName $storageAccount -SasToken $SASToken
    }
}  

$clusterName = $env:COMPUTERNAME.Substring(0,$env:COMPUTERNAME.Length-2)
$backupUrlContainer = "https://$storageAccount.blob.core.windows.net/$blobContainer"    
$sysDbs = "master", "msdb", "model", "distribution" 
$excludeDbs = "tempdb" 
$easternTime = [System.TimeZoneInfo]::ConvertTimeFromUtc((Get-Date).ToString(), [System.TimeZoneInfo]::FindSystemTimeZoneById('Eastern Standard Time'))
$datetime = ($easternTime).ToString("yyyyMMddHHmmss")

# cd to computer level  
Set-Location -Path SQLServer:\SQL\$env:COMPUTERNAME  
$instances = Get-childitem  
 
$backupdatabases = $instances.databases |Where-object {$_.name -notin $excludeDbs}  
$sysdatabases = $instances.databases |Where-object {$_.name -in $sysDbs}  
$allFiles = @()

foreach ($database in $backupdatabases)
{
    #Start constructing our backup name
    [string]$databaseName = $database.Name
    $instanceName = $database.Parent.InstanceName    
    $backupURLPath = "/" + $clusterName + "/" + $databaseName + '/' + $backupType + '/'
    $backupURLFile = $env:COMPUTERNAME + "__" + $instanceName + "__" + $databaseName + "__" + $backupType + "__" + $datetime
    $backupURLBuilder = $backupUrlContainer + $backupURLPath + $backupURLFile
    $allfiles += "*" + $backupURLFile + "*"

    #Adding AlwaysOn aware logic so we only take a backup of the preferred replica for backups
    if($backupversion -ne "2008")
    {
        $preferredReplica = Invoke-Sqlcmd -Query "select sys.fn_hadr_backup_is_preferred_replica('$databaseName') AS isPreferredReplica;" -ServerInstance "localhost\$instanceName"
    } 
    if($preferredReplica.isPreferredReplica -or $backupversion -eq "2008")
        {
        #Adding logic for creating backup paths 
        if($backupversion -eq "2008")
        {
            New-Item -Path "Z:\" -Name "Backups$backupURLPath" -ItemType "directory" -Force
        }

        #full backup of user databases
        if($backupType -eq "FULL")
            {
                #create appropriately named files for striped backup - this is based on the size of the database
                if($backupversion -eq "2016")
                {
                    $spaceQuery = "SELECT db.name, CONVERT(VARCHAR,SUM(mf.size)*8) AS [TotalDiskSpaceKB] " + 
                                    "FROM sys.databases db JOIN sys.master_files mf ON db.database_id=mf.database_id " +
                                    "where type_desc = 'ROWS' and db.name = '" + $databaseName +"' GROUP BY db.name"
                    $QueryResult = Invoke-Sqlcmd -Query $spaceQuery -ServerInstance "localhost\$instanceName"
                    #Database size / 195GB = # of stripes 
                    [int]$sliceCount = [int][Math]::Ceiling($QueryResult.TotalDiskSpaceKB/204472320) #KB is 195GB
                }
                else
                {
                    [int]$sliceCount = 1
                }
                #create the full path of our backup file(s)
                [string]$backupfile = ""
                for($n = 1; $n -lt $sliceCount + 1; $n++)
                {
                    $backupfile += $backupURLBuilder + "__"+ $n.ToString("00") +".bak,"
                }
                #remove trailing comma
                $backupfile = $backupfile.Substring(0,$backupfile.Length - 1)
                $backuplocalfile = "Z:/Backups" + $backupURLPath + $backupURLFile + "__01.bak"

                if($backupversion -eq "2016")
                {
                    Backup-SqlDatabase -DatabaseObject $database -backupfile @($backupfile.split(',')) -CopyOnly -BlockSize 65536 -MaxTransferSize 4194304 -Compression On -Checksum # -Script 
                }
                elseif($backupversion -eq "2012" -or $backupversion -eq "2014")
                {
                    Backup-SqlDatabase -DatabaseObject $database -backupfile @($backupfile.split(',')) -CopyOnly  -Compression On -Checksum -SQLCredential $backupUrlContainer # -Script 
                }
                if($backupversion -eq "2008")
                {
                    Backup-SqlDatabase -DatabaseObject $database -backupfile $backuplocalfile -CopyOnly  -Compression On -Checksum # -Script    
                }
            }
        #differential backup of all user databases
        if($backupType -eq "DIF")
            {
                #create appropriately named files for differential backup
                $backupfile = $backupURLBuilder + "__01.bak"
                $backuplocalfile = "Z:/Backups" + $backupURLPath + $backupURLFile + "__01.bak"

                if($backupversion -eq "2016")
                {
                    Backup-SqlDatabase -DatabaseObject $database -backupfile @($backupfile.split(',')) -CopyOnly -BlockSize 65536 -MaxTransferSize 4194304 -Compression On -Checksum -Incremental # -Script 
                }
                elseif($backupversion -eq "2012" -or $backupversion -eq "2014")
                {
                    Backup-SqlDatabase -DatabaseObject $database -backupfile @($backupfile.split(',')) -CopyOnly -Compression On -Checksum -Incremental -SQLCredential $backupUrlContainer # -Script
                }
                elseif($backupversion -eq "2008")
                {
                    Backup-SqlDatabase -DatabaseObject $database -backupfile $backuplocalfile -CopyOnly -Compression On -Checksum -Incremental # -Script
                }
            }

        #tlog backup of all user databases - system databases are in simple recovery mode
        if($backupType -eq "LOG" -and $database -notin $sysdatabases)
            {
                #create appropriately named files for log backup
                $backupfile = $backupURLBuilder + "__01.log"
                $backuplocalfile = "Z:/Backups" + $backupURLPath + $backupURLFile + "__01.log"
                
                if($backupversion -eq "2016")
                {
                    Backup-SqlDatabase -DatabaseObject $database -backupfile @($backupfile.split(',')) -BlockSize 65536 -MaxTransferSize 4194304 -Compression On -Checksum  -BackupAction Log # -Script
                }
                elseif($backupversion -eq "2012" -or $backupversion -eq "2014")
                {
                    Backup-SqlDatabase -DatabaseObject $database -backupfile @($backupfile.split(',')) -Compression On -Checksum  -BackupAction Log -SQLCredential $backupUrlContainer # -Script
                }
                elseif($backupversion -eq "2008")
                {
                    Backup-SqlDatabase -DatabaseObject $database -backupfile $backuplocalfile -Compression On -Checksum  -BackupAction Log # -Script
                }
            }
        }

}
if($backupversion -eq "2008")
{
    #Earlier we log each backup file
    #then we pass them in as the pattern for copy
    #when done cleanup - local backups
        
    # We are required to have the following installed for this to work  
    # Install-Module AzureRM

    ForEach($file in $allfiles)
    {
        Get-ChildItem -File -Path "Z:\Backups\" -Recurse -Filter $file | ForEach-Object { Set-AzureStorageBlobContent -File $_.FullName -Blob $_.FullName.TrimStart("Z:\Backups\") -Container $blobContainer -Context $blobContext }
        Get-ChildItem -Path "Z:\Backups\" -Recurse -Filter $file | Remove-Item 
    }
}

#Ignore expected/known error messages
foreach ($e in $error | where {$_.Exception -like "System.IO.IOException: Directory * cannot be removed because it is not empty." -or
                               $_.Exception -like "System.IO.DirectoryNotFoundException: Could not find a part of the path *AzInstallationChecks.json*"})
{
    $error.Remove($e)
}

if($Error.Count -gt 0)
{ 
    $From = "Alert Scheduled Task <DBAlert@phibred.com>"
    $To = "Corteva_DBA_Dupont@accenture.com" 
    $Subject = "Scheduled task 'Database Backup - " + $backupType + "' failed"
    $Body = "Database backup task errors on server $env:COMPUTERNAME Error Messages:"
    foreach($msg in $Error) { $Body += "`n" + $msg.ToString() + "`n" + $msg.Exception}

    Write-Host $Body

    $SMTPServer = "smtprelay.phibred.com"
    $SMTPPort = "25"

    Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort 
    #-UseSsl -Credential $Cred
}
#full backup of user databases
#$userdatabases | Backup-SqlDatabase -backupfile @($backupfile.split(','))  -BlockSize 65536 -MaxTransferSize 4194304 -Compression On -Script 

#incrimental backup of all user databases
#$userdatabases | Backup-SqlDatabase -BackupContainer $backupUrlContainer -Compression On -Incremental -script

#tlog backup of all user databases
#$userdatabases | Backup-SqlDatabase -BackupContainer $backupUrlContainer -Compression On -BackupAction Log  -script