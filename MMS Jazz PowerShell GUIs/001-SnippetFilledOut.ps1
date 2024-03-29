﻿#region formHelper  
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}
#endregion
Add-Type -AssemblyName PresentationFramework
#ERASE ALL THIS AND PUT XAML BELOW between the @" "@ 
$inputXML = @"
<Window x:Class="MMSJazz_GUI_Demo.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:MMSJazz_GUI_Demo"
        mc:Ignorable="d"
        Title="MainWindow" Height="450" Width="800">
    <Grid>
        <Label Content="Welcome to mmS" HorizontalAlignment="Left" Margin="108,72,0,0" VerticalAlignment="Top"/>
        <Button Content="Click me please" HorizontalAlignment="Left" Margin="310,181,0,0" VerticalAlignment="Top" Width="75"/>

    </Grid>
</Window>

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
$Form.ShowDialog() | out-null
  
  
  