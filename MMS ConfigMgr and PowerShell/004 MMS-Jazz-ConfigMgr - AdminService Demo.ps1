invoke-restMethod 'https://sccmtp/AdminService/wmi/SMS_R_System' -UseDefaultCredentials
start https://sccmtp/AdminService/wmi/$metadata
#Search for SMS_Collection


#region hide me 
$body = @{Name="MMSJazz Collection2";CollectionType=2; LimitToCollectionID='SMS00001'} | ConvertTo-Json 
Invoke-RestMethod -Method POST -uri https://sccmtp/AdminService/wmi/SMS_Collection `
 -body $boy  -UseDefaultCredentials -ContentType 'application/Json' | tee -Variable Response
#endregion



#doesn't work yet 
$body = @{    
    LimitToCollectionID='SMS00001';      #Limiting Collection ID
    LimitToCollectionName='All Systems'; #Limiting Collection Name
    MachineID=16777228;                  #Target Machine Name
    SiteID='DEV00016';                   #Target CollectionID
    CollectionName="MMSJazz Collection2";#Target Collection Name
    } | ConvertTo-Json 
Invoke-RestMethod -Method Post -uri https://sccmtp/AdminService/wmi/SMS_DeviceCollectionMember `
 -body $body  -UseDefaultCredentials -ContentType 'application/Json' | tee -Variable Response
