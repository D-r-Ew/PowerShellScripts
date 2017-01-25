If ((Get-Module -Name OktaAPI).name -eq $Null) {
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes",""
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No",""
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes,$no)
    $caption = "Module Not Loaded"
    $message = "Do you want to install the latest Module?"
    $result = $Host.UI.PromptForChoice($caption,$message,$choices,0)
    if($result -eq 0) { 
        Install-Module -Name OktaAPI -Force -Confirm:$false

    }
    if($result -eq 1) { Write-Output "OktaAPI Module Will Not Be Installed." }
}
    ElseIf ((Get-Module -Name OktaAPI).Version.ToString() -eq (Find-Module -Name OktaAPI).Version.ToString()) {
        Write-Output "Module is Up to Date"
    } 
            Else {
                Write-Output "Module will be updated"
                Update-Module -Name OktaAPI -Force -Confirm:$false
            }

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$caption = "Module Out of Date!"
$message = "Do you want to install the latest Module?"
$yesNoButtons = 4

if ([System.Windows.Forms.MessageBox]::Show($message, $caption, $yesNoButtons) -eq "NO") {
Write-Output "You answered no"
}
else {
Write-Output "You answered yes"
}

