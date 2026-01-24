$BaseDir = "$Home\Documents\GitLocal"
$Repos = if ($args[0]) { $args[0] } else { @("Packet-Foundry", "Terminal-Center", "Six-String-Sanctuary", "The-Inkwell", "gs6651") }

Write-Host "Starting GitSync..." -ForegroundColor Cyan

foreach ($Repo in $Repos) {
    $Target = Join-Path $BaseDir $Repo
    if (Test-Path $Target) {
        Write-Host "`n--------------------------------------------"
        Write-Host "Processing: $Repo" -ForegroundColor Yellow
        Push-Location $Target

        if ($Repo -eq "The-Inkwell" -and (Test-Path ".assets\update_stats.sh")) {
            sh "./.assets/update_stats.sh"
        }

        git add .
        $StashOut = git stash push -m "sync-stash"
        
        Write-Host "Fetching and Reversing..." -ForegroundColor Blue
        if (git pull origin main --rebase) {
            Write-Host "Success: Pull complete." -ForegroundColor Green
            if ($StashOut -notmatch "No local changes to save") { git stash pop --quiet }

            if (git status --porcelain) {
                git add .
                git commit -m "Auto-sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
                if (git push origin main) { Write-Host "Success: Pushed changes." -ForegroundColor Green }
            } else {
                Write-Host "Status: Already up to date." -ForegroundColor Blue
            }
        } else {
            Write-Host "Error: Pull failed." -ForegroundColor Red
            if ($StashOut -notmatch "No local changes to save") { git stash pop --quiet }
        }
        Pop-Location
    }
}
Write-Host "`n--------------------------------------------"
Write-Host "Done!" -ForegroundColor Green
