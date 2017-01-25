Function Get-OktaApps ($AppName){
    If ($AppName -ne $null){
        $App = Invoke-Method GET "/apps?filter=status+eq+%22ACTIVE%22&limit=+2000"
        $App | Where Name -eq "$AppName" |
        Select @{L="Name";E={$_.Name}},`
        @{L="ID";E={$_.id}},`
        @{L="Status";E={$_.status}},`
        @{L="Features";E={$_.Features}}
    } 
        Else {
            $Apps = Invoke-Method GET "/apps?filter=status+eq+%22ACTIVE%22&limit=+2000"
            $Apps | Select @{L="Name";E={$_.Name}},`
            @{L="ID";E={$_.id}},`
            @{L="Status";E={$_.status}},`
            @{L="Features";E={$_.Features}}
        }      
}

Function Get-OktaAppUserName {
    $Apps = Get-OktaApps | Select Name,ID
    ForEach ($App in $Apps) {
        $AppUsers = Get-OktaAppUser -appid $App.ID
        $AppUsers | Select @{L="AppName";E={$App.Name}},`
        @{L="AppUserName";E={$_.credentials.userName}},`
        @{L="UserName";E={(Get-OktaUser -id $_.ID).profile.email}}
    }
}

$License = Get-Msoluser -UserPrincipalName okta.admin@boardwithlife.onmicrosoft.com | Select *
Set-MsolUserLicense -UserPrincipalName drew.pador@boardwith.life -AddLicenses $License.licenses.accountSkuID
New-MsolUser -UserPrincipalName $drew.EmailAddress -ImmutableId "$([system.convert]::ToBase64String(([GUID]($drew.ObjectGUID)).tobytearray()))" -FirstName $drew.GivenName -LastName $drew.Surname -DisplayName $drew.DisplayName