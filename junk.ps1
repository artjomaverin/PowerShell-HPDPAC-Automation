
| ForEach-Object {
    $session_list += $_.sessiontype
}

$session_list += Select-Object -Property sessionID
$session_list

ForEach-Object {
    omnirpt -report single_session -session $_.SessionID | Tee-Object -Variable letssee
}

omnidb -session 2017/03/03-136 
omnidb -session 2017/03/03-136 -report "major" -report "critical"
$letssee = omnirpt -report session_objects -session 2017/03/03-135

$letssee[9]


$session_search | where-object {$_.SessionType -eq 'Backup' -and $_.Mode -eq 'full'} |
Select-Object -Property specification | ForEach-Object {
    $_.Specification
}

$hash = @{}
$hash.add('test','value')
$hash.jaap = 'awesome'
$hash

Errors # Warnings # Files Success Session ID          


$sessions_list[7]
$sessions_list[5]

Errors # Warnings # Files Success Session ID          
$a, $b = 'hello','hi'

$session_search[4] -split '\t'

1..5 | % {
 'begin'   
} {
  $_
} {
 'end'
}


omnidbvss -get session_persistent -all older_than 2017/14/03

omnidb -session 2017/03/14-10
omnidb -session 2017/03/14-10 -detail
omnidb -session 2017/03/03-136 -report "major"
omnirpt -report single_session -session 2017/03/14-10
omnirpt -report single_session -session 2017/03/03-176 -level major
omnirpt -report session_objects -session 2017/03/14-10 
omnirpt -report session_hosts -session 2017/03/14-10 -level major -short
omnirpt -report session_hosts -session 2017/03/14-10 -level major -tab
omnirpt -report session_errors -hosts tmgsseasto03.emea.group.atlascopco.com -timeframe $Backup_StartDay 18:00 $Backup_EndDay 06:01
omnirpt -report host -host tmgsseoltp20.emea.group.atlascopco.com -level Major

omnistat


$a = omnirpt -report session_hosts -session 2017/03/03-176 -level major -tab | Select-Object -Skip 3 
$n = 1
[string]$a | % {
    $_ -split "#Host Statistics" | % {
    $_ -split "`r" | % {
        Write-Output $_
        #write-host "this should be on a new line"
        $n ++
        }
    }
}


$matches


$nahuj -match "Host Statistics" | ForEach-Object {$matches} write-host $matches
$matches

$omnistat = omnirpt -report session_hosts -session 2017/03/03-176 -level major | select-object -skip 2  | % {
    $split = $_ -split "^Host Statistics" }
    [pscustomobject]@{
        'SessionID' = $split[0]
        'Type'      = $split[1]
        'Status'    = if ( $split[2] -match "In|Mount" ) { "$($split[2]) $($split[3])" } else { $split[2] } 
        'User'      = $split[-1]
    }
}

omnirpt -report session_hosts -session 2017/03/03-176 -level major -tab | select-object -skip 3  > "C:\dailysessions\remediation\20170303-176.txt"

cd "C:\Program Files\OmniBack\"

.\pscp.exe "C:\dailysessions\remediation\20170303-176.txt" aaverin@util01.prod.atlascopco.ipcenter.com:/tmp/tmp.shK9dPeIqE

ping airsbeap0403.emea.group.atlascopco.com
ping 10.141.162.103

omnistat

omnib -preview -datalist  Filesystem_Orebro_01_Daily

omnistat

omniabort -session "-2017/03/20-596"

$PSRuser = "IBMauto_svc"
$PSRpass = "!Ps0ft2015!"
$user = $PSRuser
$pass = $PSRpass |ConvertTo-SecureString -AsPlainText -Force
$server = "tmgsseasto03.emea.group.atlascopco.com"