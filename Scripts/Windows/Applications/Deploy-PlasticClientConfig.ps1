function Deploy-PlasticClientConfig {

    param (
        [Parameter(Mandatory)] [byte[]] $ZipContent,
        [Parameter(Mandatory)] [string] $ConfigFolder
    )

    $PlasticConfigZipLocation = "${PSScriptRoot}\plastic-config.zip"
    try {
        [IO.File]::WriteAllBytes($PlasticConfigZipLocation, $ZipContent)
        Expand-Archive -LiteralPath $PlasticConfigZipLocation -DestinationPath $ConfigFolder -Force -ErrorAction Stop
    } finally {
        Remove-Item $PlasticConfigZipLocation -ErrorAction SilentlyContinue
    }
}