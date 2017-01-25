<#
Here is the module I created with a few extra commands I was working on.

For your use case, we can disable individual users with this command:

Get-xOktaUser -UserName Test | 
#>

$OktaToken = "00HcltScb8laqTnrH3GSTyi-B-SGINbDMlF-EfwM-0"
$OktaBaseUrl = "https://boardwith.okta.com"
Connect-Okta -token $OktaToken -baseUrl $OktaBaseUrl

$headers = @{"Authorization" = "SSWS $OktaToken"; "Accept" = "application/json"; "Content-Type" = "application/json"}
$baseUrl = "$OktaBaseUrl/api/v1"
$userAgent = "OktaAPIWindowsPowerShell/0.1"
#User Data Types
Update-TypeData -TypeName Okta.User -MemberType ScriptProperty -MemberName UserName -Value {$this.profile.login} -Force
Update-TypeData -TypeName Okta.User -MemberType ScriptProperty -MemberName FirstName -Value {$this.profile.firstName} -Force
Update-TypeData -TypeName Okta.User -MemberType ScriptProperty -MemberName LastName -Value {$this.profile.lastName} -Force
Update-TypeData -TypeName Okta.User -DefaultDisplayPropertySet ID,Username,FirstName,LastName,Status -DefaultDisplayProperty UserName -DefaultKeyPropertySet id -Force
#Group Data Types
Update-TypeData -TypeName Okta.Group -MemberType ScriptProperty -MemberName GroupName -Value {$this.profile.Name} -Force
Update-TypeData -TypeName Okta.Group -DefaultDisplayPropertySet GroupName,Id -DefaultDisplayProperty GroupName -DefaultKeyPropertySet id -Force
#App Data Types
Update-TypeData -TypeName Okta.App -MemberType ScriptProperty -MemberName AppName -Value {$this.Name} -Force
Update-TypeData -TypeName Okta.App -DefaultDisplayPropertySet AppName,Id,SignOnMode,Status,Features -DefaultDisplayProperty GroupName -DefaultKeyPropertySet id -Force
#AppUser Data Types
Update-TypeData -TypeName Okta.AppUser -MemberType ScriptProperty -MemberName AppUserName -Value {$this.credentials.username} -Force
Update-TypeData -TypeName Okta.AppUser -DefaultDisplayPropertySet AppUserName,Id,Status,Features -DefaultDisplayProperty AppUserName -DefaultKeyPropertySet id -Force
Update-TypeData -TypeName Okta.App.User -MemberType ScriptProperty -MemberName DisplayName -Value {$this.label} -Force
Update-TypeData -TypeName Okta.App.User -DefaultDisplayPropertySet Id,DisplayName,AppName -DefaultDisplayProperty App.User -DefaultKeyPropertySet id -Force
#Event Data Types
Update-TypeData -TypeName Okta.Event -MemberType ScriptProperty -MemberName Message -Value {$this.action.message} -Force
Update-TypeData -TypeName Okta.Event -MemberType ScriptProperty -MemberName Actor -Value {$this.actors.displayname} -Force
Update-TypeData -TypeName Okta.Event -MemberType ScriptProperty -MemberName Target -Value {$this.targets.login} -Force
Update-TypeData -TypeName Okta.Event -DefaultDisplayPropertySet EventId,Published,Message,Target,Actor -DefaultDisplayProperty EventId -DefaultKeyPropertySet eventId -Force

#Helper Functions
Function Invoke-xMethod($method, $path, $body) {
    $url = $baseUrl + $path
    $jsonBody = ConvertTo-Json -compress $body
    Invoke-RestMethod $url -Method $method -Headers $headers -Body $jsonBody -UserAgent $userAgent | Write-Output
}

Function Invoke-xPagedMethod($url) {
    if ($url -notMatch '^http') {$url = $baseUrl + $url}
    $response = Invoke-WebRequest $url -Method GET -Headers $headers -UserAgent $userAgent
    $links = @{}
    if ($response.Headers.Link) { # Some searches (eg List Users with Search) do not support pagination.
        foreach ($header in $response.Headers.Link.split(",")) {
            if ($header -match '<(.*)>; rel="(.*)"') {
                $links[$matches[2]] = $matches[1]
            }
        }
    }
    @{objects = ConvertFrom-Json $response.content; nextUrl = $links.next; response = $response}
}

Function Get-xOktaEvents {
    $params = @{limit = 1000}
    $OKEvents = do {
                   $page = Get-xAllOktaEvents @params
                   $Events = $page.objects
                   foreach ($Event in $Events) {
                       $Event.pstypenames.Insert(0,"Okta.Event")
                       Write-Output $Event
                   }
                       $params = @{url = $page.nextUrl}
               } 
                   while ($page.nextUrl)
                   $OKEvents
}

Function Get-xAllOktaEvents($startDate, $filter, $limit = 1000, $url = "/events?startDate=$startDate&filter=$filter&limit=$limit") {
    Invoke-xPagedMethod $url
}

#User Functions

Function Get-xOktaUser ($UserName) {
    If ($UserName) {
            $OKUser = Invoke-Method GET "/users/$Username" 
            $OKUser.pstypenames.Insert(0,"Okta.User")
            Write-Output $OkUser
    }
        Else {
            Get-xOktaAllUsers
        }
}

Function Get-xOktaAllUsers {
    $params = @{limit = 200}
    $OKUsers = do {
                $page = Get-xOktaUsers @params
                $users = $page.objects
                ForEach ($user in $users) {
                    $User.pstypenames.Insert(0,"Okta.User")
                    Write-Output $User
                }
        $params = @{url = $page.nextUrl}
    } 
    while ($page.nextUrl)
    $OkUsers    
}

Function Get-xOktaUsers($q, $filter, $limit = 200, $url = "/users?q=$q&filter=$filter&limit=$limit") {
    Invoke-xPagedMethod $url
}

Function Disable-xOktaUser($UserName) {
    Invoke-Method POST "/users/$((Get-xOktaUser -UserName $Username).id)/lifecycle/deactivate"
    Get-xOktaUser -UserName $Username
}

Function Delete-xOktaUser ($UserName) {
    Invoke-xMethod DELETE "/users/$((Get-xOktaUser -UserName $Username).id)"
}

Function Set-xOktaUserRecoveryQuestion ($UserName, $Question, $Answer) {
    $Body = @{credentials = @{ recovery_question = @{question = $Question; answer = $Answer }}}
    Invoke-Method PUT "/users/$((Get-xOktauser -UserName $UserName).id)/" -body $Body
}

#Group Functions
Function Get-XOktaGroup ($GroupName,$ID) {
    If ($GroupName){
        $OktaGroups = (Invoke-xMethod Get "/groups/").where{$_.profile.name -like "*$GroupName*"}
            ForEach ($G in $OktaGroups) {
                $G.pstypenames.Insert(0,"Okta.Group")
                Write-Output $G
            }
    }
        ElseIf ($ID) {
            $OktaGroups = Invoke-xMethod Get "/groups/$ID"
            ForEach ($G in $OktaGroups) {
                $G.pstypenames.Insert(0,"Okta.Group")
                Write-Output $G
            }
        }
            Else {
                $OktaGroups = Invoke-xMethod Get "/groups/"
                ForEach ($G in $OktaGroups) {
                    $G.pstypenames.Insert(0,"Okta.Group")
                    Write-Output $G
                }  
             }    
}

Function Get-xOktaUserGroups ($UserName) {
    $Groups = Invoke-xMethod GET -path "/users/$($(Get-xOktaUser -UserName $Username).ID)/groups/"
    ForEach($G in $Groups) {
        Get-xOktaGroup -GroupName "$($G.profile.name)"
    }
}

Function Get-xOktaGroupMember ($GroupName) {
    $OktaGroup = Get-XOktaGroup | Where GroupName -Like "*$GroupName*"
    $Users = Invoke-xMethod GET "/groups/$($OktaGroup.ID)/users"
        ForEach ($U in $Users) {
            $U.pstypenames.insert(0,"Okta.User")
            Write-Output $U
        }
}

#App Functions
Function Get-xOktaApps ($AppName){
    If ($AppName){
        $App = (Invoke-xMethod GET "/apps?filter=status+eq+%22ACTIVE%22&limit=+2000").where{$_.Name -like "*$AppName*"}
            ForEach ($A in $App) {
                $A.pstypenames.insert(0,"Okta.App")
                Write-Output $A
            }
     } 
        Else {
            $Apps = Invoke-Method GET "/apps?filter=status+eq+%22ACTIVE%22&limit=+2000"
            ForEach ($A in $Apps) {
                $A.pstypenames.insert(0,"Okta.App")
                Write-Output $A
            }
        }      
}

Function Get-xOktaUserApps ($UserName) {
    $OktaUserID = (Get-xOktaUser -UserName $UserName).id
    $OktaApps = Invoke-xMethod GET -path "/users/$OktaUserID/appLinks/"
    ForEach ($App in $OktaApps) {
        $App.pstypenames.insert(0,"Okta.App.User")
        Write-Output $App
    }
}

Function Get-xOktaAppUser($AppName, $UserName) {
$OktaAppUserID = (Get-xOktaUser -UserName $UserName).id
$OktaAppID = (Get-xOktaApps -AppName $AppName).id
$AppUser = Invoke-xMethod GET "/apps/$OktaAppid/users/$OktaAppUserID"
    ForEach ($A in $AppUser) {
        $A.pstypenames.insert(0,"Okta.AppUser")
        Write-Output $A
    }
}