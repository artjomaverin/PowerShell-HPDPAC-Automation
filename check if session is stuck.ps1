$ProgressCheck = omnirpt -report single_session -session $inpSessionID | select-string "Success: 0%"

$SessionStartTime = (omnirpt -report single_session -session $inpSessionID | select-string "Start Time:").ToString().Substring(12)
$SessionStartTime

$nowtime = get-date -format G
$timediff = NEW-TIMESPAN –Start $SessionStartTime –End $nowtime | select-object -ExpandProperty Hours

$monthly = $false

$SessionSpec = (omnirpt -report single_session -session $inpSessionID | select-string "Specification").ToString()
    if (($SessionSpec).Contains("Monthly") -or ($SessionSpec).Contains("Full")) {
        $monthly = $true
        }
        if ($timediff -gt 12 -and $ProgressCheck) {
            Write-Host "Stuck"
        }
        elseif ($timediff -gt 8 -and $monthly -and $ProgressCheck) {
            Write-Host "Stuck"
        }
        else {
            Write-Host "Skip"
        }         