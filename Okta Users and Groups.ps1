<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-AtkoGroupMember
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Param1,

        # Param2 help description
        [int]
        $Param2
    )

    Begin
    {
    }
    Process
    {
    }
    End
    {
    }
}
<
Notes:

$OktaGroups = (Get-OktaGroups).syncroot | 
Select @{L="Name";E={$_.profile.Name}},@{L="ID";E={$_.id}},`
@{L="Type";E={$_.type}}

$OktaGroupMember = (Get-OktaGroupMember -id 0oaasu38cgNRLTQOMQRI).syncroot | 
Select @{L="FirstName";E={$_.profile.firstName}},`
@{L="LastName";E={$_.profile.lastName}},`
@{L="UserName";E={$_.profile.login}},`
@{L="ID";E={$_.id}},@{L="UserStatus";E={$_.Status}} | Where ID -EQ '0ua19gvwxaclvoRIA0h8'


#>

$OktaGroups.id |
% {(Get-OktaGroupMember -id $_).syncroot | 
Select @{L="FirstName";E={$_.profile.firstName}},`
@{L="LastName";E={$_.profile.lastName}},`
@{L="UserName";E={$_.profile.login}}
}

#Get appuser ID for all users in Okta and display app.
$AllUsers = (Get-OktaUser).Syncroot

$AllUsers | Select @{L="FirstName";E={$_.profile.firstName}},`
@{L="LastName";E={$_.profile.lastName}},`
@{L="UserName";E={$_.profile.login}},`
@{L="ID";E={$_.id}},@{L="UserStatus";E={$_.Status}} | FT

