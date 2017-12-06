$inpsession = '${inpSessionID}';

#getting current time in unix epoch format. Getting session specification (group), checking if it's monthly. 
#if yes - process it if started more than 12 hours ago, if not - more than 8h. 
#Treating object as stuck only if there is no process and object duration != 0 (otherwise it's not stuck, but failed)

$nowtime = Get-Date (get-date).touniversaltime() -UFormat %s
$nowtime = [int][double]::Parse(($nowtime))


$session_object = omnirpt -report session_objects -session $inpsession -tab | Select-Object -Skip 7 | ForEach-Object -Process {
    $HashProp = [ordered]@{}
    $HashProp.ObjectType,$HashProp.Client,$HashProp.Mountpoint,
    $HashProp.Description,$HashProp.ObjectName,$HashProp.Status,$HashProp.Mode,
    $HashProp.StartTime,$HashProp.StartTime_t,$HashProp.EndTime,
    $HashProp.EndTime_t,$HashProp.Duration,$HashProp.Size,$HashProp.Files,
    $HashProp.Performance,$HashProp.Protection,$HashProp.Errors,$HashProp.Warnings,
    $HashProp.Device = $_ -split "`t"
    
    [pscustomobject]$HashProp 
} 

$monthly = $false

$SessionSpec = (omnirpt -report single_session -session $inpsession | select-string "Specification").ToString().Substring(15)
    if (($SessionSpec).Contains("Monthly") -or ($SessionSpec).Contains("Full")) {
        $monthly = $true
        }

    if ($monthly) {
        $stuck_sessions = $session_object | Where-Object {$_.StartTime_t -lt ($nowtime - 43200) -and $_.Status -eq "Running" -and $_.Performance -eq "0.00" -and $_.Duration -ne "0:00"}
    }
    else {
        $stuck_sessions = $session_object | Where-Object {$_.StartTime_t -lt ($nowtime - 28800) -and $_.Status -eq "Running" -and $_.Performance -eq "0.00" -and $_.Duration -ne "0:00"}
    }

    if ($stuck_sessions) {
        Write-Host "Stuck"
    }
    else {
        Write-Host "Skip"
    }