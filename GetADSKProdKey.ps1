Function Get-ADSKProdKey {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [int] $Year,
        [Parameter(Mandatory = $false)]
        [string[]] $ProductName
    )
## Extract the tables out of the web request
$WebRequest = Invoke-WebRequest -Uri "https://knowledge.autodesk.com/customer-service/download-install/activate/find-serial-number-product-key/product-key-look/$Year-product-keys"
$tables = @($WebRequest.ParsedHtml.getElementsByTagName("TABLE"))
$table = $tables[0]
$titles = @()
$rows = @($table.Rows)
## Go through all of the rows in the table
    ForEach($row in $rows) {
        $cells = @($row.Cells)
## If we’ve found a table header, remember its titles
         If(($cells[0].tagName -eq "th") -or ($cells[0].innerText -like "Product*")) {
             $titles = @($cells | % { ("" + $_.InnerText).Replace(" ","") })
             continue
         }
## If we haven’t found any table headers, make up names "P1", "P2", etc.
        If(-not $titles) {
            $titles = @(1..($cells.Count + 2) | % { "P$_" })
        }
## Now go through the cells in the the row. For each, try to find the
## title that represents that column and create a hashtable mapping those
## titles to content
        $resultObject = [Ordered] @{}
        For($counter = 0; $counter -lt $cells.Count; $counter++){
            $title = $titles[$counter]
            If(-not $title) { continue }
            $resultObject[$title] = ("" + $cells[$counter].InnerText).Trim()
        }
## And finally cast that hashtable to an object. Additional If statement applied when the ProductName is specified 
            If ($ProductName) {
                [PSCustomObject] $resultObject | Where ProductName -like "*$ProductName*"
            }
                Else {
                    [PSCustomObject] $resultObject
                }
    }
}