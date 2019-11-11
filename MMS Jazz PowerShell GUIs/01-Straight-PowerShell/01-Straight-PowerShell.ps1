## Add The Frameworks(s)
Add-Type -AssemblyName PresentationFramework
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

## Create Your Objects
$Window = New-Object System.Windows.Window
$Window.Height = 600
$Window.Width = 400
$Window.Title = "Big Surprise"
$Window.ResizeMode = "NoResize"

$StackPanel = New-Object System.Windows.Controls.StackPanel

$Surprise = New-Object System.Windows.Controls.Image
$Surprise.Source = "$PSScriptRoot\01-Surprise.jpg"
$Surprise.Visibility = "Hidden"
$Surprise.Height = 500

$Button = New-Object System.Windows.Controls.Button
$Button.Content = "How you doin?"
$Button.Height = 50
$Button.Width = 100

## Add Your Objects from Child to Parent (Excluding Window)
$StackPanel.AddChild($Surprise)
$StackPanel.AddChild($Button)

## Add Your Window Children
$Window.Content = $StackPanel

## Add Your Events
$Button.Add_Click({
    $Surprise.Visibility = "Visible"
})

## Show the Dialog
$null = $Window.ShowDialog()