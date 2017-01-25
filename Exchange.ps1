$drew = Invoke-Command -Session $Skate -ScriptBlock {Get-ADuser drew.pador -Properties MemberOf}

Invoke-Command -Session $Skate -ScriptBlock {Get-ADuser Denzel.Thomas -Properties MemberOf |Select -ExpandProperty memberof,Modified | %{Get-ADGroup -Identity $_}}

Invoke-Command -Session $Skate -ScriptBlock {Get-ADUser -Identity $Drew}

New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://<exchange server FQDN>/PowerShell/ -Credential (Get-credential) -authentication kerberos
$UserCredential = Get-Credential drew.pador@boardwith.life
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection