#region formHelper  
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}
#endregion
Add-Type -AssemblyName PresentationFramework
#ERASE ALL THIS AND PUT XAML BELOW between the @" "@ 
$inputXML = @"

"@ 
  
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
[xml]$XAML = $inputXML
#Read XAML
  
    $reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{
    $Form=[Windows.Markup.XamlReader]::Load( $reader )
}
catch [System.Management.Automation.MethodInvocationException] {
    
    Write-Warning "We ran into a problem with the XAML code.  Check the syntax for this control..."
    write-host $error[0].Exception.Message -ForegroundColor Red
    
    if ($error[0].Exception.Message -like "*button*"){
        write-warning "Ensure your &lt;button in the `$inputXML does NOT have a Click=ButtonClick property.  PS can't handle this`n`n`n`n"}
}
catch{ 
    Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."
    Write-error $error[0] | format-list * 
}
  
#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================
  
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}
  
Get-FormVariables
  
#===========================================================================
# Use this space to add code to the various form elements in your GUI
#===========================================================================
                                                                     
      
    #Reference 
  
    #Adding items to a dropdown/combo box
      #$vmpicklistView.items.Add([pscustomobject]@{'VMName'=($_).Name;Status=$_.Status;Other="Yes"})
      
    #Setting the text of a text box to the current PC name    
      #$WPFtextBox.Text = $env:COMPUTERNAME
      
    #Adding code to a button, so that when clicked, it pings a system
    # $WPFbutton.Add_Click({ Test-connection -count 1 -ComputerName $WPFtextBox.Text
    # })
    #===========================================================================
    # Shows the form
    #===========================================================================
write-host "To show the form, run the following" -ForegroundColor Cyan
'$Form.ShowDialog() | out-null'
  
  
  