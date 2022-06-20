param
(
    [parameter(Mandatory = $true)]
    [Alias("HostName", "SeverName")]
    [string[]] $ComputerName
)
$ServersNotReachable = @()

$ComputerName | ForEach-Object {

    if (Test-Connection $_ -Count 1 -Quiet -ErrorAction SilentlyContinue)
  {  
    
          $data=Get-CimInstance -ClassName CIM_LogicalDisk -ComputerName $_ | Where-Object {$_.Drivetype -eq 3}
           
           foreach($disk in $data)
{
         
    $size= [math]::round($disk.Size/1GB,2)
    $FreeSpace= [math]::round($disk.FreeSpace/1GB,2) 
    $FreePercent =[math]::round([double]$Disk.FreeSpace / [double] $Disk.size * 100,2)
    
    
   [PScustomobject]@{
    Computer = $Disk.SystemName
    DiskName = $Disk.DeviceID
    Description = $Disk.Description
    Drivetype = $Disk.Drivetype
    "TotalDisk(GB)" =  $Size
    "FreeSpace(GB)" = $FreeSpace
    "FreePercent(%)" =Write-Output "    $FreePercent %"
    Compressed = $Disk.Compressed
    Filesystem= $disk.FileSystem
   }
        
}
   } 
else
    {
        $ServersNotReachable += $_ 
    }
} | format-table

Write-Host "The server(s) below is/are not reachable..." -ForegroundColor Red
$ServersNotReachable