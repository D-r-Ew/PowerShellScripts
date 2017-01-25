#Export Office 365 User Data to CSV

Get-MsolUser | 
Select UserprincipalName,  Firstname, Lastname, DisplayName, Title, StreetAddress, City, State ,Country, PostalCode, Department, PhoneNumber, Fax, MobilePhone, Office, @{L='ProxyAddress_1';E={$_.proxyaddresses[0]}}, @{L='ProxyAddress_2';E={$_.proxyaddresses[1]}}, @{L='ProxyAddress_3';E={$_.proxyaddresses[2]}}, @{L='ProxyAddress_4';E={$_.proxyaddresses[3]}}, @{L='ProxyAddress_5';E={$_.proxyaddresses[4]}} | 
Export-Csv c:\proxytest.csv -NoTypeInformation

#Connect to Exchange
$Exchange = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential (Get-Credential drew.pador@boardwith.life) -Authentication Basic -AllowRedirection

Import-PSSession $Exchange