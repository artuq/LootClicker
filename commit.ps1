# Auto-commit and push with issue reference
# Usage: .\commit.ps1 -message "Your commit message" -issues "3, 6"

param(
    [Parameter(Mandatory=$true)]
    [string]$message,
    
    [Parameter(Mandatory=$false)]
    [string]$issues = ""
)

# Build commit message with issue references
$commitMsg = $message

if ($issues) {
    $commitMsg = "$message (fixes #$($issues.Replace(', ', ', #')))"
}

Write-Host "Committing: $commitMsg" -ForegroundColor Cyan
git add .
git commit -m "$commitMsg"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Commit successful" -ForegroundColor Green
    Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
    git push origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Pushed to GitHub successfully!" -ForegroundColor Green
    } else {
        Write-Host "Push failed - check your network/credentials" -ForegroundColor Yellow
    }
} else {
    Write-Host "Commit failed" -ForegroundColor Red
}
