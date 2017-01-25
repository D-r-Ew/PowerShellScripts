#User Data Types
Update-TypeData -TypeName Okta.User -MemberType ScriptProperty -MemberName UserName -Value {$this.profile.login} -Force
Update-TypeData -TypeName Okta.User -MemberType ScriptProperty -MemberName FirstName -Value {$this.profile.firstName} -Force
Update-TypeData -TypeName Okta.User -MemberType ScriptProperty -MemberName LastName -Value {$this.profile.lastName} -Force
Update-TypeData -TypeName Okta.User -DefaultDisplayPropertySet ID,Username,FirstName,LastName,Status -DefaultDisplayProperty UserName -DefaultKeyPropertySet id -Force
#Group Data Types
Update-TypeData -TypeName Okta.Group -MemberType ScriptProperty -MemberName GroupName -Value {$this.profile.Name} -Force
Update-TypeData -TypeName Okta.Group -DefaultDisplayPropertySet GroupName,Id -DefaultDisplayProperty GroupName -DefaultKeyPropertySet id -Force


Function Get-XOktaGroup ($GroupName,$ID) {
    If ($GroupName){
        $OktaGroups = (Invoke-Method Get "/groups/").where{$_.profile.name -like "*$GroupName*"}
            ForEach ($G in $OktaGroups) {
                $G.pstypenames.Insert(0,"Okta.Group")
                Write-Output $G
            }
    }
        ElseIf ($ID) {
            $OktaGroups = Invoke-Method Get "/groups/$ID"
            ForEach ($G in $OktaGroups) {
                $G.pstypenames.Insert(0,"Okta.Group")
                Write-Output $G
            }
        }
            Else {
                $OktaGroups = Invoke-Method Get "/groups/"
                ForEach ($G in $OktaGroups) {
                    $G.pstypenames.Insert(0,"Okta.Group")
                    Write-Output $G
                }  
             }    
}

Function Get-xOktaGroupMember ($GroupName) {
    $OktaGroup = Get-XOktaGroup | Where GroupName -Like "*$GroupName*"
    $Users = Invoke-Method GET "/groups/$($OktaGroup.ID)/users"
        ForEach ($U in $Users) {
            $U.pstypenames.insert(0,"Okta.User")
            Write-Output $U
        }
}

Function Get-xOktaUserRole ($UserName) {
        Invoke-Method GET "/users/$((Get-OktaUser -id $UserName).id)/roles"
}


Function Delete-xOktaUserRole ($UserName,$Role) {
    $OKUserRole = (Get-OktaUserRole -UserName $UserName).id
    $OKUser = (Get-OktaUser -id $UserName).id
    Invoke-Method DEL "/users/$OKUser/roles/$OKUserRole"
}

Function Set-xOktaUserRole{
<#
.Synopsis
   Sets the UserRole for Okta Users
.DESCRIPTION
   Long description
.EXAMPLE
   Set-OktaUserRole -UserName Test10User10 -Group 'WWIT GTO MMD AD ADM_GS'
.EXAMPLE
   Another example of how to use this cmdlet
#>
    [CmdletBinding()]
        Param(
            # This can be either the UserName or the Okta UserID
            [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
            [String[]]$UserName,

            # This controls the BEGIN block where the $Body varible is set based on the Group Name
            [Parameter(Mandatory=$true)]
            [ValidateSet('WWIT GTO MMD AD ADM_GS','BCGDV IT-Flat')]
            $Group
        )
        Begin {
        
            $Body = If ($Group -eq 'BCGDV IT-Flat') {
                @{type = 'USER_ADMIN'}
            }
                ElseIf ($Group -eq 'WWIT GTO MMD AD ADM_GS') {
                    @{type = 'SUPER_ADMIN'}
                }

        }
            Process{
                $OKUser = (Get-OktaUser -id $UserName).ID
                Invoke-Method POST "/users/$OKuser/roles" -body $Body
            }
}

Function Add-UserAdmin ($GroupName, $ID) {
    If ($GroupName) {
        $GroupMembers = Get-xOktaGroupMember -GroupName $GroupName
        ForEach ($G in $GroupMembers) {Set-xOktaUserRole -UserName $G.id -Group 'BCGDV IT-Flat'}
    }
        ElseIf ($ID) {
            $GroupMembers = (Get-xOktaGroupMember -GroupName $GroupName).where{$_.ID -eq $ID}
            ForEach ($G in $GroupMembers) {Set-xOktaUserRole -UserName $G.id -Group 'BCGDV IT-Flat'}
        }            
}