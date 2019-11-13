#SECOND speed demo 
if (-not $remoteCred) {$remoteCred = Get-Credential}
if (-not $CMSession) {
    $CMSession = New-PSSession -ComputerName sccmtp -Credential $remoteCred
    Invoke-Command -Session $CMSession -ScriptBlock {
        $CMPSSuppressFastNotUsedCheck = $true
        If (!(Get-Module).Name.Contains('ConfigurationManager')){
            & C:\Scripts\SetupCMConnection.ps1
            $CMPSSuppressFastNotUsedCheck = $true
            }
    }
}

#enter PSSession to show what we've done
Enter-PSSession -Session $CMSession
Get-CMResource | select Name,ResourceID | ConvertTo-Json
Exit-PSSession

#region firstDemo
#retrieving CM device speed 
#built in CMDlets
measure-command {
    invoke-command -scriptblock {
        Get-CMResource 
        } -Session $CMSession
    }

#using optional -Fast param
measure-command {
    invoke-command -scriptblock {
        Get-CMResource -Fast
    } -Session $CMSession
}

#straight WMI
measure-command {
Get-CIMInstance -ComputerName sccmtp -Namespace root\SMS\Site_DEV -Query "select Name,ResourceID from SMS_R_SYSTEM" | select Name,ResourceID
}
#endregion


#Retrieving from AdminService
measure-command {
    $devices  = invoke-restMethod 'https://sccmtp/AdminService/wmi/SMS_R_System' -UseDefaultCredentials
} 


#Straight SQL
$CMConnection1 = New-mmsSqlConnection -ServerName sccmtp.foxdeploy.local -DatabaseName CM_DEV -ConnectionTimeout 10
measure-command {
    Invoke-mmsSqlCommand -Connection $CMConnection1 -ReturnResults -Query "Select Name0,ResourceID from V_R_System" | Select Name0,ResourceID
}


#Summary
Write-Output "Performance Results`n============================="

measure-command {
    invoke-command -scriptblock {
        Get-CMResource      
        } -Session $CMSession
    } | select TotalMilliseconds, @{Name='Method';Exp={'Get-CMResource'}}

measure-command {
        invoke-command -scriptblock {
    Get-CMResource  -Fast
    } -Session $CMSession
} | select TotalMilliseconds, @{Name='Method';Exp={'Get-CMResource -Fast'}}

measure-command {
    Get-CIMInstance -ComputerName sccmtp -Namespace root\SMS\Site_DEV -Query "select * from SMS_R_SYSTEM" 
} | select TotalMilliseconds, @{Name='Method';Exp={'Straight WMI'}}

measure-command {
    $devices  = invoke-restMethod 'https://sccmtp/AdminService/wmi/SMS_R_System' -UseDefaultCredentials
} | select TotalMilliseconds, @{Name='Method';Exp={'AdminService'}}

measure-command {
    Invoke-mmsSqlCommand -Connection $CMConnection1 -ReturnResults -Query "Select Name0,ResourceID from V_R_System" | Select Name0,ResourceID
} | select TotalMilliseconds, @{Name='Method';Exp={'Straight SQL'}}

