$user = '${PSRUser}'; $pass = '${PSRPass}' |ConvertTo-SecureString -AsPlainText -Force; $server = '${host}';

#taking credentials and hostname from variables in automata, then restarting VSS and Omniinet services at the host. 
#In case of problems reporting CRITICAL error, which is treated as automata break and -> this session will not be restarted

$credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user,$pass

Invoke-Command -ComputerName $server -Credential $credentials -ScriptBlock {
    $services = @("vss", "omniinet")
    foreach ($service in $services) {
        $servicestatus = Get-Service $service | Select-Object -ExpandProperty Status
            if ($servicestatus -match "Running") {
                "[NORMAL] The $service Service on $env:COMPUTERNAME is $servicestatus. Disconnecting." 
            }
            if ($servicestatus -match "Stopped") {
                "[WARNING] The $service service on $env:COMPUTERNAME is $servicestatus. Attempting to start it." 
                Start-Service $service
                $check = Get-Service $service | Select-Object -ExpandProperty Status
                if ($check -eq "Running") {
                    "[NORMAL] Service has been succesfully started. Disconnecting."
                }
                else { "[CRITICAL] Issues encountered. Service might be hung, check manually" }
            }
            if ($servicestatus -match "Starting" -or $servicestatus -match "Stopping") {
                $procid = get-wmiobject win32_service | where { $_.name -eq "$service"} | Select-Object -ExpandProperty ProcessId
                "[WARNING] The $service Service on $env:COMPUTERNAME is $servicestatus. Attempting to kill and restart it. (PID : $procid )"
                taskkill /f /pid $procid
                Start-Service $service
                $servicestatus = Get-Service $service | Select-Object -ExpandProperty Status
                if ($servicestatus -match "Running") {
                    "[NORMAL] Service has been succesfully started. Disconnecting."
                }
                else { "[CRITICAL] Issues encountered. Service might be hung, check manually" }
            }
    }
}