$fsession = '${fSessionID}';

#getting list of objects in session, extrating only those with status != 'Completed'. 
#then adding clients related to these objects to an array and clearing duplicates out of the array

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

$fClientList = $session_object | Where-Object {$_.Status -ne 'Completed'} | Select-Object -ExpandProperty Client | Sort-Object -Unique
$fClientList = $fClientList -join (",")
$fClientList