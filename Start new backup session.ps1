$fsession = '${fSessionID}';

#Could be used to start a new backup session, based on the settings of old backup session $fsession.
#Checking, whether backup type is FS, SQL or LN, then if failed objects are full, diff, incr or mixed,
#Starting new backup based on that info. Backup command is hanging until backup is finished so 
#I had to create a process out of it and then kill it in 15 seconds, extracting ID of restarted session


$letsskip = $false
$SessionSpec = (omnirpt -report single_session -session $fsession | select-string "Specification").ToString().Substring(15)
if ($SessionSpec -match "MSSQL") {
    $SessionSpec = $SessionSpec.replace("MSSQL ","")
}

if ($SessionSpec -match "Lotus") {
    $SessionSpec = $SessionSpec.replace("Lotus ","")
}

$session_object = omnirpt -report session_objects -session $fsession -tab | Select-Object -Skip 7 | ForEach-Object -Process {
    $HashProp = [ordered]@{}
    $HashProp.ObjectType,$HashProp.Client,$HashProp.Mountpoint,
    $HashProp.Description,$HashProp.ObjectName,$HashProp.Status,$HashProp.Mode,
    $HashProp.StartTime,$HashProp.StartTime_t,$HashProp.EndTime,
    $HashProp.EndTime_t,$HashProp.Duration,$HashProp.Size,$HashProp.Files,
    $HashProp.Performance,$HashProp.Protection,$HashProp.Errors,$HashProp.Warnings,
    $HashProp.Device = $_ -split "`t"
    
    [pscustomobject]$HashProp 
} 

if ($session_object | Where-Object {$_.objecttype -eq 'WinFS'}) {
    $oldmode = $session_object.mode | Where-Object {$_.Status -ne 'Completed'} | Sort-Object -Unique
    $list = "-datalist"
    $bacmode = "-mode"
        if ($oldmode | select-string "full") {
            $mode = "full"
        }
        else {
            $incrn = $oldmode.replace("incr","")
            $mode = "Incremental$incrn"
        }
}
elseif ($session_object | Where-Object {$_.objecttype -eq 'BAR' -and $_.Description -eq 'MSSQL'}) {
    $oldmode = $session_object.mode | Where-Object {$_.Status -ne 'Completed'} | Sort-Object -Unique
    $list = "-mssql_list"
    $bacmode = "-barmode"
        if ($oldmode | select-string "trans") {
            $letsskip = $true
        }
        elseif ($oldmode | select-string "full") {
            $mode = "full"
        }
        else {
            $mode = "diff"
        }
}
elseif ($session_object | Where-Object {$_.objecttype -eq 'BAR' -and $_.Description -eq 'Lotus'}) {
    $oldmode = $session_object.mode | Where-Object {$_.Status -ne 'Completed'} | Sort-Object -Unique
    $list = "-lotus_list"
    $bacmode = "-barmode"
        if ($oldmode | select-string "full") {
            $mode = "full"
        }
        else {
            $mode = "incr"
        }
}

if ($letsskip) {
    "Skip"
}

else {

# Create process
$ProcessInfo                        = New-Object System.Diagnostics.ProcessStartInfo
$ProcessInfo.FileName               = "C:\Program Files\OmniBack\bin\omnib.exe"
$ProcessInfo.Arguments              = "$list `"$SessionSpec`" $bacmode $mode"
$ProcessInfo.WindowStyle            = [System.Diagnostics.ProcessWindowStyle]::Hidden
$ProcessInfo.UseShellExecute        = $false
$ProcessInfo.RedirectStandardOutput = $true
$Process                 = New-Object System.Diagnostics.Process
$Process.StartInfo       = $ProcessInfo
[void]$Process.Start()

# Wait 10 seconds
Start-Sleep -Seconds 10

# Kill and get output
$Process.kill()
$rsession = $Process.StandardOutput.ReadToEnd()  

#get restarted session number
($rsession -split '.*?(\d{4}/\d{2}/\d{2}-\d+).*')[1]

}