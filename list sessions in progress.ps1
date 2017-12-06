#Creating array of backup sessions, that toke place between 18:00 yesterday and 06:01 today. 
#Only those that are not 100% successful and are still in progress are shown. 
#It is also filtered by backup groups that are managed by Atlas Copco themselves: C:\dailysessions\remediation\exceptions.txt. 
#List of session IDs is extracted. 

$Backup_StartDay = (Get-Date).addDays(-1).ToString("yyyy/MM/dd"); $Backup_EndDay = (Get-Date).ToString("yyyy/MM/dd");

$session_search = omnirpt -report list_sessions -timeframe $Backup_StartDay 18:00 $Backup_EndDay 06:01 -tab |
Select-Object -Skip 5 | ForEach-Object -Process {
    $HashProp = [ordered]@{}
    $HashProp.SessionType,$HashProp.Specification,$HashProp.Status,
    $HashProp.Mode,$HashProp.StartTime,$HashProp.StartTime_t,$HashProp.EndTime,
    $HashProp.EndTime_t,$HashProp.Queuing,$HashProp.Duration,
    $HashProp.GBWritten,$HashProp.Media,$HashProp.Errors,$HashProp.Warnings,
    $HashProp.PendingDA,$HashProp.RunningDA,$HashProp.FailedDA,$HashProp.CompletedDA,
    $HashProp.Objects,$HashProp.Files,$HashProp.Success,$HashProp.SessionOwner,$HashProp.SessionID = $_ -split "`t"
    
    [pscustomobject]$HashProp 
} | Where-Object {$_.SessionType -eq 'Backup' -and $_.Success -ne '100%'} |
    Where-Object {(Get-Content "C:\dailysessions\remediation\exceptions.txt") -notcontains $_.Specification} 

$sessions_inprogress = $session_search | where-object {$_.Status -eq 'In Progress' -or $_.Status -eq 'In Progress/Failures' -or $_.Status -eq 'In Progress/Errors'} | Select-Object -ExpandProperty SessionId
$sessions_inprogress = $sessions_inprogress -join (",")
$sessions_inprogress