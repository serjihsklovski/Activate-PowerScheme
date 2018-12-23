param (
    [ValidateNotNullOrEmpty()]
    [string]$scheme
)

$REGEX = [regex]'^Power Scheme GUID:\s+(?<guid>[\da-f]{8}-(?:[\da-f]{4}-){3}[\da-f]{12})\s+\((?<name>.+)\)(?<is_active>(?:\s\*)?)$'

$existing_schemes = @(powercfg.exe /list) | Select-Object -Skip 3
$scheme_found = $false
$regex_error_occured = $false
foreach ($line in $existing_schemes) {
    if ($line -match $REGEX) {
        if ($Matches.name.Equals($scheme)) {
            $scheme_found = $true

            if ($Matches.is_active -ne ' *') {
                powercfg.exe /setactive $Matches.guid
                Write-Host -ForegroundColor:Green "SUCCESS: Power scheme '$scheme' is activated successfully."
                break
            } else {
                Write-Host -ForegroundColor:Yellow "WARNING: Power scheme '$scheme' is already activated; nothing changed."
                break
            }
        } else {
            continue
        }
    } else {
        $regex_error_occured = $true
        Write-Host -ForegroundColor:Red "ERROR: 'powercfg.exe' output line '$line' does not match regular expression /$REGEX/."
        break
    }
}

if (!$scheme_found -and !$regex_error_occured) {
    Write-Host -ForegroundColor:Red "ERROR: Power scheme '$scheme' does not exist; nothing changed."
}
