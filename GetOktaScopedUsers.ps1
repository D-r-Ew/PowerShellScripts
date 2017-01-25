Function Get-OktaScopedAppUsers ($AppID) {
    $AppUser = Invoke-Method GET "/apps/$AppID/users/"
    ForEach ($User in $AppUser) {
        Select-Object -InputObject $User -Property @{L="Scope";E={$User.scope}},`
        @{L="Username";E={(Get-OktaUser -id $User.id).profile.login}},`
        @{L="Status";E={$user.status}},`
        @{L="Group";E={$user._links.group.name}}
    }
}