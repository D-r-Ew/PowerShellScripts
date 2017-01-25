Function Get-xOktaUser ($UserName) {
    $OKUsers = Invoke-Method GET "/users/"
    $OKUser = $OKUsers.syncroot | 
    Where Profile.email -Like "*$($UserName)*"
    $OkUser | Select @{L="UserID";E={$}}
}

#Building out this function for a better base

$OKUsers = Invoke-xMethod GET "/users/" | FT @{Name="ID";E={$_.ID}},@{L="Login";E={$_.profile.login}}


$headers = @{"Authorization" = "SSWS $OktaToken"; "Accept" = "application/json"; "Content-Type" = "application/json"}
$baseUrl = "$OktaBaseUrl/api/v1"


$OKUser = Invoke-xMethod get "/users"
$OKUser | Select @{L="Login";E={$_.profile.login}},@{L="ID";E={$_.ID}} | Sort -Descending login


$OKU.pstypenames.Insert(0,"Okta.UserObject")

Update-TypeData -TypeName Test.Group -MemberType ScriptProperty -MemberName Login -Value {$this.User} -Force
Update-TypeData -TypeName Okta.UserObject -DefaultDisplayPropertySet Login,Id -Force

$G = Get-OktaUser drew.pador | Select @{Name="ID";E={$_.ID}},@{L="Login";E={$_.profile.login}}
$GName = (Get-OktaUserGroups -id $G.id ).syncroot

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


$G = Get-OktaUser drew.pador | Select @{Name="ID";E={$_.ID}},@{L="Login";E={$_.profile.login}}
Function Get-xTest ($Id) {
$GroupOb = (Get-OktaUserGroups -id $Id.id).syncroot
ForEach ($a in $GroupOb) {
    $a.pstypenames.Insert(0,"Test.Group")
    Write-Output $a
}
}
    Update-TypeData -TypeName Okta.Group -MemberType ScriptProperty -MemberName GroupName -Value {$this.profile.Name} -Force
    Update-TypeData -TypeName Okta.Group -MemberType ScriptProperty -MemberName ID -Value {$this.ID} -Force
    Update-TypeData -TypeName Okta.UserObject -DefaultDisplayPropertySet Login,Id -Force

##############################################################################################
$headers = @{"Authorization" = "SSWS $OktaToken"; "Accept" = "application/json"; "Content-Type" = "application/json"}
$baseUrl = "$OktaBaseUrl/api/v1"

function Invoke-xMethod($method, $path, $body) {
    $url = $baseUrl + $path
    $jsonBody = ConvertTo-Json -compress $body
    Invoke-RestMethod $url -Method $method -Headers $headers -Body $jsonBody -UserAgent $userAgent | Write-Output
}

Function Get-xOktaUser ($UserName) {
    If ($UserName) {
        $OKUser = (Invoke-xMethod get "/users").where{$_.profile.login -like "*$UserName*"}
        ForEach ($U in $OKUser) {
            $U.pstypenames.Insert(0,"Okta.User")
            Write-Output $U
        }
        Update-TypeData -TypeName Okta.User -MemberType ScriptProperty -MemberName UserName -Value {$this.profile.login} -Force
        Update-TypeData -TypeName Okta.User -DefaultDisplayPropertySet UserName,Id -DefaultDisplayProperty UserName -DefaultKeyPropertySet id -Force
    }
}

Function Get-XOktaGroups {
    $OktaGroups = Invoke-xMethod Get "/groups/"
    ForEach ($G in $OktaGroups) {
        $G.pstypenames.Insert(0,"Okta.Group")
        Write-Output $G
    }      
    Update-TypeData -TypeName Okta.Group -MemberType ScriptProperty -MemberName GroupName -Value {$this.profile.Name} -Force
    Update-TypeData -TypeName Okta.Group -DefaultDisplayPropertySet GroupName,Id -DefaultDisplayProperty GroupName -DefaultKeyPropertySet id -Force
}

Get-XOktaGroups | %{Get-OktaGroupMember -id $_.id }

Function Get-xOktaGroupMember ($GroupName) {
    $OktaGroup = Get-XOktaGroups | Where GroupName -Like "*$GroupName*"
    $OktaGroupMembers = Invoke-xMethod GET "/groups/$($OktaGroup.ID)/users" | 
    %{Get-xOktaUser -UserName $_.profile.login | Select @{L="GroupName";E={$OktaGroup.GroupName}},Login,Id}
    $OktaGroupMembers | FT -GroupBy GroupName -Property Login,ID
}