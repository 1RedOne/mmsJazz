if (-not $CSInfo){
$csInfo = Get-ComputerInfo |select @{Name=‘installDate’;Expression={$_.OsInstallDate.DateTime}},
        @{Name=‘processor’;Expression={$_.CsProcessors[0].Name}},
        @{Name=‘ram’;Expression={[math]::Ceiling(($_.OsTotalVisibleMemorySize/ 1mb))}},
        @{Name=‘osName’;Expression={$_.OSName}},
        @{Name=‘osBuild’;Expression={$_.OsVersion}} 
}

if (-not $diskInfo){
$diskInfo =gcim win32_logicalDisk|select DeviceID, VolumeName,        
        @{Name=‘Size’;Expression={[math]::Ceiling(($_.Size/ 1mb))}},
        @{Name=‘Free Space’;Expression={[math]::Round($_.FreeSpace /1gb,2)}}
}

if ($server){$Server.Stop()} 
#Setup the server
$Path = Split-Path $MyInvocation.MyCommand.Path  -Parent
Set-Location $Path
$Server = [System.Net.HttpListener]::new()
$Server.Prefixes.Add('http://localhost:8001/')
$Server.Start()
#start http://localhost:8001/
#Make the server stop after 30 seconds
$StopAt = (Get-Date).AddSeconds(45)

Function Send-MMSJazzResponse($InputObject){
    $JSON = $InputObject | ConvertTo-Json
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($JSON)
    $Context.Response.ContentLength64 = $buffer.Length
    $Context.Response.OutputStream.Write($buffer, 0, $buffer.length)
    $Context.Response.OutputStream.Close()
    }

while (($Server.IsListening)-and ((Get-Date) -le $StopAt)) {
    Write-Output "Listening..."
    $Context = $Server.GetContext()
    
    Write-Host "$($Context.Request.UserHostAddress) [$($Context.Request.HttpMethod)]=> $($Context.Request.Url)"  -ForegroundColor Green

    if(($Context.Request.Url -like "*.js.*") -or ($Context.Request.Url -like "*.css*") -or ($Context.Request.Url -like "*.css.map") -or ($Context.Request.Url -like "*.download*") -or ($Context.Request.Url -like "*.ico") -or ($Context.Request.Url -like "*.png")){
    }
    else{
    Write-Output "actionable request"
    }


    $RequestData = $Context.Request.Headers.GetValues('RequestData')
    if ($Context.Request.Url.AbsolutePath -eq '/Online'){
        Write-Host "Received request for Online, testing if machine is online"  -ForegroundColor Green
        $Body = [System.IO.StreamReader]::new($Context.Request.InputStream, $Context.Request.ContentEncoding)
        $Data = $Body.ReadToEnd() | convertfrom-stringdata
        $Body.Close()
        write-host -ForegroundColor Yellow "Testing if $($Data.computername) is online..."

        $results = Test-Connection -ComputerName $Data.COmputerName -Count 1 -quiet | Select-Object

        Send-MMSJazzResponse $results

    }
    if ($Context.Request.HttpMethod -eq 'POST') {
        if ($Context.Request.HasEntityBody) {
            $Body = [System.IO.StreamReader]::new($Context.Request.InputStream, $Context.Request.ContentEncoding)
            $Data = $Body.ReadToEnd()
            $Body.Close()
        }
    } elseif ($Context.Request.HttpMethod -eq 'GET' -and $null -ne $RequestData) {
        switch($RequestData) {
            "Process" {
                $Processes = Get-Process
                
                $JSON = ConvertTo-Json $Processes
            }
            "CSinfo" {      
                $csInfo = Get-ComputerInfo |select @{Name=‘installDate’;Expression={$_.OsInstallDate.DateTime}},
        @{Name=‘processor’;Expression={$_.CsProcessors[0].Name}},
        @{Name=‘ram’;Expression={[math]::Ceiling(($_.OsTotalVisibleMemorySize/ 1mb))}},
        @{Name=‘osName’;Expression={$_.OSName}},
        @{Name=‘osBuild’;Expression={$_.OsVersion}} 
                $Payload = $CSInfo
                $JSON = ConvertTo-Json $Payload                
            }
            "diskInfo" {      
                $Payload = @{data=@($diskInfo)}
                $JSON = ConvertTo-Json $Payload                
            }
            "SystemName" {      
                $JSON = "BEHEMOTH" #ConvertTo-Json $Payload                
            }
            "serviceInfo" {
                $services = gsv | select Status,Name,DisplayName, StartType| sort Status -desc
                $PayLoad = @{data=@($services)}
                $JSON = ConvertTo-Json $Payload
            }
            "processInfo" {                
                $processes = Get-Process | select Name,@{Name=‘Memory’;Expression={[math]::Ceiling(($_.PrivateMemorySize/ 1mb))}},@{Name=‘cpuTime’;Expression={$_.PrivilegedProcessorTime.Seconds}},@{Name=‘processID’;Expression={$_.ID}}
                $PayLoad = @{data=@($processes)}
                $JSON = ConvertTo-Json $Payload
            }

            default {
                $BadRequest = "" | Select Response,ExitCode
                $BadRequest.Response = "Invalid Request"
                $BadRequest.ExitCode = 1
                $JSON = ConvertTo-Json $BadRequest
            }
        }
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($JSON)
        $Context.Response.ContentLength64 = $buffer.Length
        $Context.Response.OutputStream.Write($buffer, 0, $buffer.length)
        $Context.Response.OutputStream.Close()
    } elseif ($Context.Request.HttpMethod -eq 'PUT') {
        #Process the Body and Convert it to an Object
        $Body = [System.IO.StreamReader]::new($Context.Request.InputStream, $Context.Request.ContentEncoding)
        $Data = $Body.ReadToEnd()
        $Obj = ConvertFrom-Json $Data

        $NewObj = "" | Select Name,Message,Number,HostName,HostAddress
        $NewObj.Name = $Obj.Name
        $NewObj.Message = $Obj.Message
        $NewObj.Number = $Obj.Number
        $NewObj.HostName = $Context.Request.UserHostName
        $NewObj.HostAddress = $Context.Request.UserHostAddress

        $ToSend = ConvertTo-Json $NewObj

        #Write the body parts out
        Write-Host -NoNewline -ForegroundColor Magenta "$($Obj.Number)`t"
        Write-Host -NoNewline -ForegroundColor Yellow "$($Obj.Name)`t"
        Write-Host -ForegroundColor Cyan "$($Obj.Message)"

        #Respond to the client so that they can close the connection
        $Result = Post-LogAnalyticsData -WorkspaceID $WorkspaceID -Key $Key -Body $ToSend -LogType $LogType
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($Result)
        $Context.Response.ContentLength64 = $buffer.Length
        $Context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
        $Context.Response.OutputStream.Close()        
    } else {
        $file = ($Context.Request.RawUrl).Substring(1)
        Write-output ":request for $file"
        if ($File.Length -eq 0) {            
            $file="Index"
            }
            
            #check if user browsed to a verb, and serve the matching page
            if($file.Split(".")[1] -eq $null){
                Write-Output "Received request for $file Verb, serving matching page"
                $file = $file + ".html"
            }

            if ((Test-Path -Path $file) -and ((([System.IO.FileInfo]::new("$($Path)\$($file)")).Length) -gt 0)) {
                if ($file -eq "SystemInfo.html"){
                    $fileContent = (Get-Content $file -Raw) -replace '$csInfo',$csinfo
                    $buffer = [System.Text.Encoding]::UTF8.GetBytes($fileContent)     
                }                           
                else{
                    $buffer = [System.Text.Encoding]::UTF8.GetBytes((Get-Content $file -Raw))
                }
                                
                $Context.Response.ContentLength64 = $buffer.Length
                $Context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
                $Context.Response.OutputStream.Close()
            } else {
                Write-Warning -Message "$($file) not found or was 0 length.  Will not serve."
                $Context.Response.OutputStream.Close()
            }
        }
    
}
Write-Output "'`$StopAt' reached,  Stopping Server."
$Server.Stop()