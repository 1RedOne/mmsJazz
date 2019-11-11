#region Boring beginning stuff
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

#region begin to draw forms

#draw background and name the window
$Form = New-Object System.Windows.Forms.form
$Form.Text = "Computer Pinging Tool"
$Form.Size = New-Object System.Drawing.Size(550,290)
$Form.StartPosition = "CenterScreen"
$Form.KeyPreview = $True
$Form.MaximumSize = $Form.Size
$Form.MinimumSize = $Form.Size

#$Form.ShowDialog() 
#break

#Draw a label ( a non-editable textbox)
$label = New-Object System.Windows.Forms.label
$label.Location = New-Object System.Drawing.Size(5,5)
$label.Size = New-Object System.Drawing.Size(450,75)
$label.Text = "Type any computer name to test if it is on the network and can respond to ping"
$label.Font = New-Object System.Drawing.Font("Segoe UI",12,[System.Drawing.FontStyle]::Regular)
#$label.Font.Size = 22
$Form.Controls.Add($label)


#draw a text box
$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Location = New-Object System.Drawing.Size(10,80)
$textbox.Size = New-Object System.Drawing.Size(160,85)
$textbox.Font =New-Object System.Drawing.Font("Segoe UI",12,[System.Drawing.FontStyle]::Regular)
#$textbox.Text = "Select source PC:"
$Form.Controls.Add($textbox)
 
#$Form.ShowDialog()
# break

$result_label = New-Object System.Windows.Forms.label
$result_label.Location = New-Object System.Drawing.Size(5,105)
$result_label.Size = New-Object System.Drawing.Size(290,30)
$result_label.Text = "Results will be listed here"
$result_label.Font = New-Object System.Drawing.Font("Segoe UI",12,[System.Drawing.FontStyle]::Regular)
$Form.Controls.Add($result_label)
 
$statusBar1 = New-Object System.Windows.Forms.StatusBar
$statusBar1.Name = "statusBar1"
$statusBar1.Text = "Ready..."

$statusBar1.Font = New-Object System.Drawing.Font("Segoe UI",12,[System.Drawing.FontStyle]::Regular)
$form.Controls.Add($statusBar1)

#$Form.ShowDialog()
#break
#Skip and come back to me


$ping_computer_click =
{
    $statusBar1.Text = "Testing..."
    $ComputerName = $textbox.Text
 
    if (Test-Connection $ComputerName -quiet -Count 1){
        Write-Host -ForegroundColor Green "Computer $ComputerName has network connection"
        $result_label.ForeColor= "Green"
        $result_label.Text = "Ping Successful"
    }
    Else{
        Write-Host -ForegroundColor Red "Computer $ComputerName does not have network connection"
        $result_label.ForeColor= "Red"
        $result_label.Text = "System is NOT Pingable"
    }
 
    $statusBar1.Text = "Testing Complete"

}


#make an OK button
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(210,80)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click($ping_computer_click)
$Form.Controls.Add($OKButton)

$Form.ShowDialog() 


 
$Form.Add_KeyDown({if ($_.KeyCode -eq "Enter"){& $ping_computer_click}})
$Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
{$Form.Close()}})
#endregion begin to draw forms
 
#Show form
$Form.Topmost = $True
$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()


#start https://poshgui.com/#