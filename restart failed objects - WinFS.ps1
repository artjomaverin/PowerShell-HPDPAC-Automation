$fsession = '${fSessionID}';

#Restart failed objects from session $fSessionID. Restart command is hanging until backup is finished so 
#I had to create a process out of it and then kill it in 15 seconds, extracting ID of restarted session

# Create process
$ProcessInfo                        = New-Object System.Diagnostics.ProcessStartInfo
$ProcessInfo.FileName               = "C:\Program Files\OmniBack\bin\omnib.exe"
$ProcessInfo.Arguments              = "-restart $fsession"
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