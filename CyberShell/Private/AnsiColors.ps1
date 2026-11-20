# ==============================================================================
# CyberShell - ANSI 24-bit TrueColor & Styling Engine
# Compatible with PowerShell 5.1 and PowerShell 7+
# ==============================================================================

$script:ESC = [char]27
$script:RESET = "$script:ESC[0m"
$script:BOLD = "$script:ESC[1m"
$script:DIM = "$script:ESC[2m"
$script:ITALIC = "$script:ESC[3m"
$script:UNDERLINE = "$script:ESC[4m"

function Convert-HexToRgb {
    param([string]$Hex)
    if ($Hex.StartsWith('#')) { $Hex = $Hex.Substring(1) }
    if ($Hex.Length -eq 6) {
        $r = [Convert]::ToInt32($Hex.Substring(0, 2), 16)
        $g = [Convert]::ToInt32($Hex.Substring(2, 2), 16)
        $b = [Convert]::ToInt32($Hex.Substring(4, 2), 16)
        return @{ R = $r; G = $g; B = $b }
    }
    return @{ R = 255; G = 255; B = 255 }
}

function Format-CyberFg {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Hex,
        [string]$Text = ""
    )
    $rgb = Convert-HexToRgb -Hex $Hex
    $code = "$script:ESC[38;2;$($rgb.R);$($rgb.G);$($rgb.B)m"
    if ($Text) {
        return "$code$Text$script:RESET"
    }
    return $code
}

function Format-CyberBg {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Hex,
        [string]$Text = ""
    )
    $rgb = Convert-HexToRgb -Hex $Hex
    $code = "$script:ESC[48;2;$($rgb.R);$($rgb.G);$($rgb.B)m"
    if ($Text) {
        return "$code$Text$script:RESET"
    }
    return $code
}

function Format-CyberGradient {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [string]$FromHex = "#00F0FF",
        [string]$ToHex = "#FF007F"
    )

    if ([string]::IsNullOrEmpty($Text)) { return "" }
    $fromRgb = Convert-HexToRgb -Hex $FromHex
    $toRgb = Convert-HexToRgb -Hex $ToHex

    $len = $Text.Length
    if ($len -le 1) { return Format-CyberFg -Hex $FromHex -Text $Text }

    $result = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $len; $i++) {
        $ratio = [double]$i / ($len - 1)
        $r = [int]($fromRgb.R + ($toRgb.R - $fromRgb.R) * $ratio)
        $g = [int]($fromRgb.G + ($toRgb.G - $fromRgb.G) * $ratio)
        $b = [int]($fromRgb.B + ($toRgb.B - $fromRgb.B) * $ratio)
        [void]$result.Append("$script:ESC[38;2;$r;$g;${b}m$($Text[$i])")
    }
    [void]$result.Append($script:RESET)
    return $result.ToString()
}
