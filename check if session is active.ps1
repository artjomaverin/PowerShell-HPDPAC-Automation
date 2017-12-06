$inpsession = '${inpSessionID}';

#comparing output from omnirpt to omnistat. Session should be there with status including 'In Progress'. 
#If found with 'Failed' - session will be treated as failed. if not found - session will be skipped.

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
    if ($omnistat.status -match 'In Progress') {
        "In Progress"
    }
    elseif ($omnistat.status -eq 'Completed/Failures' -or $omnistat.status -eq 'Failed') {
        "Failed"
    }
    else {
        "Skip"
    }
}
else {
"Skip"
}