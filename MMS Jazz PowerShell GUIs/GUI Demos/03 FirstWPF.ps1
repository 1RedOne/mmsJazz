    #ERASE ALL THIS AND PUT XAML BELOW between the @" "@ 
$inputXML = @"

<Window x:Class="Stephens_MMS_GUI.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:Stephens_MMS_GUI"
        mc:Ignorable="d"
        Title="MainWindow" Height="450" Width="800">
    <Grid>
        <DatePicker HorizontalAlignment="Left" Margin="124,99,0,0" VerticalAlignment="Top"/>
        <Label Name="Label" Content="MMS 2018" HorizontalAlignment="Left" Height="93" Margin="75,176,0,0" VerticalAlignment="Top" Width="296"/>
        <Button Name="OK" Content="Button" HorizontalAlignment="Left" Margin="391,176,0,0" VerticalAlignment="Top" Width="75"/>
        <StatusBar HorizontalAlignment="Left" Height="12" Margin="10,409,0,-0.333" VerticalAlignment="Top" Width="773"/>

    </Grid>
</Window>

  
"@ 
  
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
  
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
$Form=[Windows.Markup.XamlReader]::Load( $reader )  
#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================
  
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}
  
get-variable WPF*

write-host "To show the form, run the following" -ForegroundColor Cyan
'$Form.ShowDialog() | out-null'