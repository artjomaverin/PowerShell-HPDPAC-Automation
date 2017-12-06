$inpsession = '${inpSessionID}';

#Creating a list of objects per session and extracting object type. 
#Assuming that all objects have the same type and never mixed, 
#so if WinFS is found once, the whole session is considered to be WinFS

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

if ($session_object | Where-Object {$_.objecttype -eq 'WinFS' -or $_.objecttype -eq 'FileSystem'}) {
    'WinFS'
}
elseif ($session_object | Where-Object {$_.objecttype -eq 'BAR' -and $_.Description -eq 'MSSQL'}) {
    'MSSQL'
}
elseif ($session_object | Where-Object {$_.objecttype -eq 'BAR' -and $_.Description -eq 'Lotus'}) {
    'Lotus'
}
else {
    'Restart'
}