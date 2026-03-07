Write-Host "Starting E-Commerce App QA Test Suite..." -ForegroundColor Cyan

# 1. Formatting & Code Quality
Write-Host "`n[1/5] Running RuboCop for code styling..." -ForegroundColor Yellow
bundle exec rubocop
$rubocopExit = $LASTEXITCODE

# 2. Security Audits
Write-Host "`n[2/5] Running Brakeman for static security analysis..." -ForegroundColor Yellow
bundle exec brakeman --no-pager
$brakemanExit = $LASTEXITCODE

Write-Host "`n[3/5] Running Bundler Audit for vulnerable gems..." -ForegroundColor Yellow
bundle exec bundler-audit
$bundlerAuditExit = $LASTEXITCODE

Write-Host "`n[4/5] Running Importmap Audit for vulnerable JS libraries..." -ForegroundColor Yellow
bin/importmap audit
$importmapAuditExit = $LASTEXITCODE

# 3. Automated Tests
Write-Host "`n[5/5] Running Minitest Suite (Unit, Request, System)..." -ForegroundColor Yellow
$env:RAILS_ENV = "test"
bundle exec rails test
$railsTestExit = $LASTEXITCODE
bundle exec rails test:system
$railsSystemTestExit = $LASTEXITCODE

Write-Host "`n======================================================="
Write-Host "QA SUMMARY"
Write-Host "======================================================="

$allPassed = $true

if ($rubocopExit -eq 0) { Write-Host "RuboCop: [PASSED]" -ForegroundColor Green } else { Write-Host "RuboCop: [FAILED]" -ForegroundColor Red; $allPassed = $false }
if ($brakemanExit -eq 0) { Write-Host "Brakeman: [PASSED]" -ForegroundColor Green } else { Write-Host "Brakeman: [FAILED]" -ForegroundColor Red; $allPassed = $false }
if ($bundlerAuditExit -eq 0) { Write-Host "Bundler Audit: [PASSED]" -ForegroundColor Green } else { Write-Host "Bundler Audit: [FAILED]" -ForegroundColor Red; $allPassed = $false }
if ($importmapAuditExit -eq 0) { Write-Host "Importmap Audit: [PASSED]" -ForegroundColor Green } else { Write-Host "Importmap Audit: [FAILED]" -ForegroundColor Red; $allPassed = $false }
if ($railsTestExit -eq 0) { Write-Host "Rails Tests: [PASSED]" -ForegroundColor Green } else { Write-Host "Rails Tests: [FAILED]" -ForegroundColor Red; $allPassed = $false }
if ($railsSystemTestExit -eq 0) { Write-Host "System Tests: [PASSED]" -ForegroundColor Green } else { Write-Host "System Tests: [FAILED]" -ForegroundColor Red; $allPassed = $false }

Write-Host "======================================================="
if ($allPassed) {
    Write-Host "OVERALL QA STATUS: PASSED (100% QUALITY ASSURANCE MET)" -ForegroundColor Green
    Write-Host "Your app is robust, secure, and on track to be a top 50 in the world!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "OVERALL QA STATUS: FAILED" -ForegroundColor Red
    exit 1
}
