function Start-CyberMatrix {
    <#
    .SYNOPSIS
        Starts an interactive cyberpunk digital rain (Matrix screensaver) in the console.
    .PARAMETER Speed
        Delay in milliseconds per frame (default: 40).
    .PARAMETER Color
        Color theme for the rain (Green, Cyan, Magenta, Yellow).
    .EXAMPLE
        Start-CyberMatrix
    #>
    [CmdletBinding()]
    param(
        [int]$Speed = 40,
        [ValidateSet("Green", "Cyan", "Magenta", "Yellow")]
        [string]$Color = "Green"
    )

    $origCursor = [Console]::CursorVisible
    $origColor = [Console]::ForegroundColor

    try {
        [Console]::CursorVisible = $false
        [Console]::Clear()

        $width = [Console]::WindowWidth
        $height = [Console]::WindowHeight

        # Setup character pool (digits, letters, cyber glyphs)
        $chars = "0123456789ABCDEF!@#$%^&*<>~=+-_/\|[]{}µ§±"
        
        # Color palettes (Lead, Bright, Mid, Dim)
        $palettes = @{
            Green   = @("#FFFFFF", "#66FF99", "#00FF66", "#008833", "#004411")
            Cyan    = @("#FFFFFF", "#7DF9FF", "#00F0FF", "#0099B8", "#004D5C")
            Magenta = @("#FFFFFF", "#FF99DD", "#FF007F", "#B30059", "#5A002C")
            Yellow  = @("#FFFFFF", "#FFFF99", "#FCEE09", "#B8AD00", "#5C5600")
        }

        $activePalette = $palettes[$Color]
        $cHead   = Format-CyberFg -Hex $activePalette[0]
        $cBright = Format-CyberFg -Hex $activePalette[1]
        $cMid    = Format-CyberFg -Hex $activePalette[2]
        $cDim    = Format-CyberFg -Hex $activePalette[3]
        $cGhost  = Format-CyberFg -Hex $activePalette[4]
        $rst     = $script:RESET

        # Stream trackers per column
        $streams = @()
        for ($x = 0; $x -lt $width; $x++) {
            $streams += [PSCustomObject]@{
                X       = $x
                Y       = Get-Random -Minimum -25 -Maximum 0
                Length  = Get-Random -Minimum 8 -Maximum ($height - 2)
                Speed   = Get-Random -Minimum 1 -Maximum 3
                Tick    = 0
            }
        }

        # Clear key buffer
        while ([Console]::KeyAvailable) { [void][Console]::ReadKey($true) }

        # Render loop
        while (-not [Console]::KeyAvailable) {
            foreach ($s in $streams) {
                $s.Tick++
                if ($s.Tick -ge $s.Speed) {
                    $s.Tick = 0
                    $s.Y++

                    # Draw head
                    if ($s.Y -ge 0 -and $s.Y -lt $height -and $s.X -lt $width) {
                        try {
                            [Console]::SetCursorPosition($s.X, $s.Y)
                            $ch = $chars[(Get-Random -Minimum 0 -Maximum $chars.Length)]
                            [Console]::Write("$cHead$ch$rst")
                        } catch {}
                    }

                    # Draw body
                    for ($i = 1; $i -le $s.Length; $i++) {
                        $tailY = $s.Y - $i
                        if ($tailY -ge 0 -and $tailY -lt $height -and $s.X -lt $width) {
                            $tailColor = if ($i -lt 3) { $cBright } elseif ($i -lt 7) { $cMid } elseif ($i -lt 12) { $cDim } else { $cGhost }
                            try {
                                [Console]::SetCursorPosition($s.X, $tailY)
                                $tch = $chars[(Get-Random -Minimum 0 -Maximum $chars.Length)]
                                [Console]::Write("$tailColor$tch$rst")
                            } catch {}
                        }
                    }

                    # Erase tail end
                    $eraseY = $s.Y - $s.Length - 1
                    if ($eraseY -ge 0 -and $eraseY -lt $height -and $s.X -lt $width) {
                        try {
                            [Console]::SetCursorPosition($s.X, $eraseY)
                            [Console]::Write(" ")
                        } catch {}
                    }

                    # Reset stream if fallen off screen
                    if ($s.Y - $s.Length -gt $height) {
                        $s.Y = Get-Random -Minimum -15 -Maximum 0
                        $s.Length = Get-Random -Minimum 8 -Maximum ($height - 2)
                        $s.Speed = Get-Random -Minimum 1 -Maximum 3
                    }
                }
            }

            Start-Sleep -Milliseconds $Speed
        }

        # Consume the key that exited the loop
        [void][Console]::ReadKey($true)

    } finally {
        [Console]::Clear()
        [Console]::CursorVisible = $origCursor
        [Console]::ForegroundColor = $origColor
    }
}
