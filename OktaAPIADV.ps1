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

Function Get-axOktaUser {
<#
.Synopsis
   Retreives Okta User Account Information
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $UserName,

        # Param2 help description
        [int]
        $Param2
    )

    Begin{
        
    }
        Process{
        
        }
            End{
        
            }
}