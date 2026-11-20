# ==============================================================================
# CyberShell - Prompt Engine
# Renders high-performance neon cyberpunk prompts
# ==============================================================================

function Format-CyberPath {
    param([string]$Path, [string]$Style = "Short")

    $homeDir = $HOME
    if ($Path.StartsWith($homeDir, [System.StringComparison]::OrdinalIgnoreCase)) {
        $Path = "~" + $Path.Substring($homeDir.Length)
    }

    if ($Style -eq "Short") {
        $parts = $Path.Split([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
        if ($parts.Length -gt 4) {
            $Path = "$($parts[0])" + [System.IO.Path]::DirectorySeparatorChar + "..." + [System.IO.Path]::DirectorySeparatorChar + "$($parts[-2])" + [System.IO.Path]::DirectorySeparatorChar + "$($parts[-1])"
        }
    }
    return $Path
}

function Format-CyberDuration {
    param([TimeSpan]$Duration)

    if ($Duration.TotalMilliseconds -lt 1000) {
        return "$([int]$Duration.TotalMilliseconds)ms"
    } elseif ($Duration.TotalSeconds -lt 60) {
        return "$([Math]::Round($Duration.TotalSeconds, 1))s"
    } else {
        $mins = [int]$Duration.TotalMinutes
        $secs = [int]($Duration.TotalSeconds % 60)
        return "${mins}m ${secs}s"
    }
}

function Invoke-CyberAlert {
    param([string]$Message = "Command finished")
    try {
        if ($script:CyberConfig.soundEffects) {
            [Console]::Beep(880, 100)
            [Console]::Beep(1320, 150)
        }
    } catch {}
}

function Render-CyberPrompt {
    # Capture last command success status immediately
    $lastSuccess = $?
    $lastExitCode = $global:LASTEXITCODE

    $theme = $script:CyberTheme
    $cfg = $script:CyberConfig
    $colors = $theme.colors
    $syms = $theme.symbols

    $sb = New-Object System.Text.StringBuilder

    # --- 1. Execution Timer Telemetry ---
    $durText = ""
    try {
        $lastHistory = Get-History -Count 1 -ErrorAction SilentlyContinue
        if ($lastHistory -and $lastHistory.EndExecutionTime -and $lastHistory.StartExecutionTime) {
            $dur = $lastHistory.EndExecutionTime - $lastHistory.StartExecutionTime
            if ($dur.TotalMilliseconds -ge $cfg.executionTimeThresholdMs) {
                $durFormatted = Format-CyberDuration -Duration $dur
                $durText = "$($syms.timer) $durFormatted"

                if ($cfg.notifyOnLongExecution -and ($dur.TotalSeconds -ge $cfg.notifyThresholdSeconds)) {
                    Invoke-CyberAlert -Message "Process completed in $durFormatted"
                }
            }
        }
    } catch {}

    # --- 2. Exit Status Indicator ---
    $statusColor = if ($lastSuccess -and ($lastExitCode -eq 0 -or $lastExitCode -eq $null)) {
        $colors.success
    } else {
        $colors.error
    }
    $statusIcon = if ($lastSuccess -and ($lastExitCode -eq 0 -or $lastExitCode -eq $null)) {
        $syms.success
    } else {
        $syms.error
    }

    # --- 3. Path Segment ---
    $pwdPath = (Get-Location).Path
    $formattedPath = Format-CyberPath -Path $pwdPath -Style $cfg.pathStyle

    # --- 4. Git Segment ---
    $gitSegment = ""
    if ($cfg.showGit) {
        $git = Get-CyberGitStatus
        if ($git.InRepo) {
            $branchColor = if ($git.IsDirty) { $colors.gitDirty } else { $colors.gitClean }
            $dirtyGlyph = if ($git.IsDirty) { " $($syms.gitDirty)" } else { "" }
            $gitSegment = "$($syms.gitBranch) $($git.Branch)$dirtyGlyph"
        }
    }

    # --- 5. Assemble Prompt based on Style ---
    $reset = $script:RESET
    $bold = $script:BOLD

    if ($cfg.style -eq "NeonBar") {
        # Style: ┌─[ ✔ ]─[ ~ \ Projects ]─[  main ]─[ ⏱ 1.2s ]
        #        └─⚡ 
        $line1 = New-Object System.Text.StringBuilder
        $mutedFg = Format-CyberFg -Hex $colors.muted
        $textFg = Format-CyberFg -Hex $colors.text
        $pathFg = Format-CyberFg -Hex $colors.path
        $statFg = Format-CyberFg -Hex $statusColor

        [void]$line1.Append("$mutedFg┌─[$statFg$bold$statusIcon$reset$mutedFg]─")
        [void]$line1.Append("[$pathFg$bold $formattedPath $reset$mutedFg]")

        if ($gitSegment) {
            $gitFg = Format-CyberFg -Hex $branchColor
            [void]$line1.Append("─[$gitFg $gitSegment $reset$mutedFg]")
        }

        if ($durText -and $cfg.showExecutionTime) {
            $timerFg = Format-CyberFg -Hex $colors.timer
            [void]$line1.Append("─[$timerFg $durText $reset$mutedFg]")
        }

        $symFg = Format-CyberFg -Hex $colors.symbol
        $promptLine = "`n$($line1.ToString())`n$mutedFg└─$symFg$bold$($syms.prompt)$reset "
        return $promptLine

    } elseif ($cfg.style -eq "Powerline") {
        # Powerline Capsule Style: [ ✔ ] [ ~/Path ] [  main ] [ ⏱ 2s ]
        #                           ❯ 
        $pathFg = Format-CyberFg -Hex $colors.path
        $symFg = Format-CyberFg -Hex $colors.symbol
        $statFg = Format-CyberFg -Hex $statusColor

        [void]$sb.Append("`n$statFg$bold$statusIcon$reset ")
        [void]$sb.Append("$pathFg$bold$formattedPath$reset")

        if ($gitSegment) {
            $gitFg = Format-CyberFg -Hex $branchColor
            [void]$sb.Append(" $(Format-CyberFg -Hex $colors.muted)on$reset $gitFg$gitSegment$reset")
        }

        if ($durText -and $cfg.showExecutionTime) {
            $timerFg = Format-CyberFg -Hex $colors.timer
            [void]$sb.Append(" $timerFg[$durText]$reset")
        }

        [void]$sb.Append("`n$symFg$bold$($syms.prompt)$reset ")
        return $sb.ToString()

    } else {
        # Minimal Style: ~/Path [ main] ❯
        $pathFg = Format-CyberFg -Hex $colors.path
        $symFg = Format-CyberFg -Hex $colors.symbol

        [void]$sb.Append("$pathFg$formattedPath$reset")

        if ($gitSegment) {
            $gitFg = Format-CyberFg -Hex $branchColor
            [void]$sb.Append(" $gitFg($gitSegment)$reset")
        }

        if ($durText -and $cfg.showExecutionTime) {
            $timerFg = Format-CyberFg -Hex $colors.timer
            [void]$sb.Append(" $timerFg$durText$reset")
        }

        [void]$sb.Append(" $symFg$($syms.prompt)$reset ")
        return $sb.ToString()
    }
}
