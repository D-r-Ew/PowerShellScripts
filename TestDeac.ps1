<#
Here is the module I created with a few extra commands I was working on.

For your use case, we can disable individual users with these commands:



$DeactivateUsers = Import-Csv -Path [EnterFilePath]

ForEach ($User in $DeactivateUsers) {
    Disable-xOktaUser -UserName $User
}

#>

#$OktaToken = "ENTER API TOKEN HERE"
#$OktaBaseUrl = "https://yourorg.okta.com"
#Connect-Okta -token $OktaToken -baseUrl $OktaBaseUrl

$headers = @{"Authorization" = "SSWS $OktaToken"; "Accept" = "application/json"; "Content-Type" = "application/json"}
$baseUrl = "$OktaBaseUrl/api/v1"
Update-TypeData -TypeName Okta.User -MemberType ScriptProperty -MemberName UserName -Value {$this.profile.login} -Force
Update-TypeData -TypeName Okta.User -MemberType ScriptProperty -MemberName FirstName -Value {$this.profile.firstName} -Force
Update-TypeData -TypeName Okta.User -MemberType ScriptProperty -MemberName LastName -Value {$this.profile.lastName} -Force
Update-TypeData -TypeName Okta.User -DefaultDisplayPropertySet ID,Username,FirstName,LastName,Status -DefaultDisplayProperty UserName -DefaultKeyPropertySet id -Force
Update-TypeData -TypeName Okta.Group -MemberType ScriptProperty -MemberName GroupName -Value {$this.profile.Name} -Force
Update-TypeData -TypeName Okta.Group -DefaultDisplayPropertySet GroupName,Id -DefaultDisplayProperty GroupName -DefaultKeyPropertySet id -Force
Update-TypeData -TypeName Okta.App -MemberType ScriptProperty -MemberName AppName -Value {$this.Name} -Force
Update-TypeData -TypeName Okta.App -DefaultDisplayPropertySet AppName,Id,Status,Features -DefaultDisplayProperty GroupName -DefaultKeyPropertySet id -Force
Update-TypeData -TypeName Okta.AppUser -MemberType ScriptProperty -MemberName AppUserName -Value {$this.credentials.username} -Force
Update-TypeData -TypeName Okta.AppUser -DefaultDisplayPropertySet AppUserName,Id,Status,Features -DefaultDisplayProperty AppUserName -DefaultKeyPropertySet id -Force

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

#User Functions

Function Get-xOktaUser ($UserName) {
    If ($UserName) {
        $OKUsers = do {
                      $page = Get-xOktaUsers @params
                      $users = $page.objects
                      foreach ($u in $users) {
                          $U.pstypenames.Insert(0,"Okta.User")
                          Write-Output $U
                      }
                        $params = @{url = $page.nextUrl}
                  }
                while ($page.nextUrl)
                    $OKUsers.where{$_.profile.login -like "*$UserName*"}
                    ForEach ($U in $OKUser) {
                        $U.pstypenames.Insert(0,"Okta.User")
                        Write-Output $U
                   }
    }
        Else {
           $params = @{limit = 200}
           $OKUsers = do {
                          $page = Get-xOktaUsers @params
                          $users = $page.objects
                          foreach ($u in $users) {
                              $U.pstypenames.Insert(0,"Okta.User")
                              Write-Output $U
                          }
                            $params = @{url = $page.nextUrl}
                      }
                while ($page.nextUrl)
                    ForEach ($U in $OKUsers) {
                        $U.pstypenames.Insert(0,"Okta.User")
                        Write-Output $U
                    }
        }
}

function Get-xOktaUsers($q, $filter, $limit = 200, $url = "/users?q=$q&filter=$filter&limit=$limit") {
    Invoke-xPagedMethod "/users?q=$q&filter=$filter&limit=$limit"
}

function Disable-xOktaUser($UserName) {
    Invoke-Method POST "/users/$((Get-xOktaUser -UserName $Username).id)/lifecycle/deactivate"
    Get-xOktaUser -UserName $Username
}