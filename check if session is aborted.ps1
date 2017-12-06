$inpsession = '${inpSessionID}';

#running omnistat to see whther the session in question appears as aborted after 5 min wait. 
#if session is not in omnistat - assuming that it has been aborted and gone already

$omnistat = omnistat | select-object -skip 2  | % {
    $split = $_ -split "\s+"
    [pscustomobject]@{
        'SessionID' = $split[0]
        'Type'      = $split[1]
        'Status'    = if ( $split[2] -match "In|Mount" ) { "$($split[2]) $($split[3])" } else { $split[2] } 
        'User'      = $split[-1]
    }
} | Where-Object {$_.Type -eq 'Backup' -and $_.SessionID -eq $inpsession}



if ($omnistat) {
    if ($omnistat.status -match 'Aborted') {
        'Aborted'
    }
    else {
        'Rerun the loop'
    }
}
else {
'Aborted'
}