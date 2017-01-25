Function Get-ADLMInfo ($LICFilePath) {
    $Content = (Get-Content $LICFilePath | Select -First 2).split(' ') | Select -Last 2
        $Object = [PSCustomObject]@{
            "Server" = $Content[0]
            "MAC" = $Content[1]
        }
    $Object
}