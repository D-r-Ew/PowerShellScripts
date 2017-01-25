#How to add Sign-On Policies

<#
"settings": {
    "app": {},
    "notifications": {
      "vpn": {
        "network": {
          "connection": "ANYWHERE"
        }
#>

#App Schtuff

$Test = (Get-xOktaApps -AppName linkedin | Select -ExpandProperty _Links).users
$Test.href.TrimStart("$BaseUrl")
$AppU = Invoke-RestMethod $Test.href -Method GET -Headers $headers -Body $JsonBody -UserAgent $userAgent
ForEach ($U in $Appu) { 
    $U.pstypenames.Insert(0,"Okta.AppUser")
    Write-Output $U
}