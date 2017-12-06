$SessionStartTime = (omnirpt -report single_session -session $inpSessionID | select-string "Start Time:").ToString().Substring(12)
$SessionStartTime

$nowtime = get-date -format G
$timediff = NEW-TIMESPAN –Start $SessionStartTime –End $nowtime | select-object -ExpandProperty Hours

if ($timediff -gt 24) {
    $SessionSpec = (omnirpt -report single_session -session $inpSessionID | select-string "Specification").ToString()
    if (($SessionSpec).Contains("Monthly") -or ($SessionSpec).Contains("Full")) {
        Write-Host "Skip"
    }
    else {
        Write-Host "Daily"
    }
}
else {
    write-host "Skip"
}