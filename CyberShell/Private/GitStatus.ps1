# ==============================================================================
# CyberShell - Ultra-Fast Git Status Engine
# Checks .git direct structure first for zero-latency performance
# ==============================================================================

function Find-GitRoot {
    param([string]$Path = (Get-Location).Path)

    try {
        $curr = [System.IO.DirectoryInfo]::new($Path)
        while ($curr -ne $null) {
            $gitDir = [System.IO.Path]::Combine($curr.FullName, ".git")
            if ([System.IO.Directory]::Exists($gitDir) -or [System.IO.File]::Exists($gitDir)) {
                return $gitDir
            }
            $curr = $curr.Parent
        }
    } catch {}
    return $null
}

function Get-CyberGitStatus {
    $status = @{
        InRepo    = $false
        Branch    = ""
        IsDirty   = $false
        Ahead     = 0
        Behind    = 0
        Untracked = $false
    }

    $gitRoot = Find-GitRoot
    if (-not $gitRoot) {
        return $status
    }

    $status.InRepo = $true

    # Resolve gitdir if submodule or worktree (.git is a file)
    $actualGitDir = $gitRoot
    if ([System.IO.File]::Exists($gitRoot)) {
        try {
            $content = [System.IO.File]::ReadAllText($gitRoot).Trim()
            if ($content.StartsWith("gitdir:")) {
                $relPath = $content.Substring(7).Trim()
                $parent = [System.IO.Path]::GetDirectoryName($gitRoot)
                $actualGitDir = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($parent, $relPath))
            }
        } catch {}
    }

    # Direct read of HEAD (zero process overhead)
    $headFile = [System.IO.Path]::Combine($actualGitDir, "HEAD")
    if ([System.IO.File]::Exists($headFile)) {
        try {
            $headContent = [System.IO.File]::ReadAllText($headFile).Trim()
            if ($headContent.StartsWith("ref: refs/heads/")) {
                $status.Branch = $headContent.Substring(16)
            } else {
                # Detached HEAD - take first 7 chars
                $status.Branch = if ($headContent.Length -gt 7) { $headContent.Substring(0, 7) } else { $headContent }
            }
        } catch {
            $status.Branch = "git"
        }
    }

    # If git binary exists, check quick porcelain status for dirty flag
    $gitCmd = Get-Command git -ErrorAction SilentlyContinue
    if ($gitCmd) {
        try {
            $psi = New-Object System.Diagnostics.ProcessStartInfo
            $psi.FileName = "git"
            $psi.Arguments = "status --porcelain --ignore-submodules=dirty"
            $psi.RedirectStandardOutput = $true
            $psi.RedirectStandardError = $true
            $psi.UseShellExecute = $false
            $psi.CreateNoWindow = $true

            $proc = [System.Diagnostics.Process]::Start($psi)
            if ($proc.WaitForExit(100)) {
                $out = $proc.StandardOutput.ReadToEnd()
                if (-not [string]::IsNullOrEmpty($out)) {
                    $status.IsDirty = $true
                    if ($out -match '^\?\?') {
                        $status.Untracked = $true
                    }
                }
            } else {
                try { $proc.Kill() } catch {}
            }
        } catch {}
    }

    return $status
}
