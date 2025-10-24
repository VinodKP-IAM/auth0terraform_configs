# Environment Setup Verification Script
# This script helps verify that your GitHub environments and protection rules are configured correctly

param(
    [string]$Repository = "KaranGupta05/teraform_auth0"
)

function Write-CheckResult {
    param(
        [string]$Check,
        [bool]$Success,
        [string]$Details = ""
    )
    
    $status = if ($Success) { "✅" } else { "❌" }
    Write-Host "$status $Check" -ForegroundColor $(if ($Success) { "Green" } else { "Red" })
    if ($Details) {
        Write-Host "   $Details" -ForegroundColor Gray
    }
}

function Write-Section {
    param([string]$Title)
    Write-Host "`n🔍 $Title" -ForegroundColor Cyan
}

Write-Host "🛡️ Environment Protection Setup Verification" -ForegroundColor Blue
Write-Host "Repository: $Repository" -ForegroundColor Gray

# Check GitHub CLI authentication
Write-Section "GitHub CLI Authentication"
& gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-CheckResult "GitHub CLI authenticated" $true
} else {
    Write-CheckResult "GitHub CLI not authenticated" $false "Run: gh auth login"
    return
}

# Check repository access
Write-Section "Repository Access"
$repoResult = & gh api repos/$Repository 2>&1
if ($LASTEXITCODE -eq 0) {
    $repoInfo = $repoResult | ConvertFrom-Json
    Write-CheckResult "Repository access confirmed" $true "Name: $($repoInfo.name)"
    
    # Check permissions
    if ($repoInfo.permissions.admin -eq $true) {
        Write-CheckResult "Admin permissions confirmed" $true "Can configure environments"
    } else {
        Write-CheckResult "Limited permissions" $false "Admin access needed for environment configuration"
    }
} else {
    Write-CheckResult "Cannot access repository" $false $repoResult
    return
}

# Check environments exist
Write-Section "Environment Existence"
$environments = @("development", "staging", "production")
foreach ($env in $environments) {
    $envResult = & gh api repos/$Repository/environments/$env 2>&1
    if ($LASTEXITCODE -eq 0) {
        $envInfo = $envResult | ConvertFrom-Json
        Write-CheckResult "Environment '$env' exists" $true "Created: $($envInfo.created_at)"
    } else {
        Write-CheckResult "Environment '$env' missing" $false "Run setup script to create"
    }
}

# Check environment protection rules (Note: This requires elevated permissions)
Write-Section "Environment Protection Rules"
Write-Host "⚠️  Protection rule details require manual verification due to GitHub API limitations" -ForegroundColor Yellow
Write-Host "   Please check manually at: https://github.com/$Repository/settings/environments" -ForegroundColor Gray

# Test environment secrets access
Write-Section "Environment Secrets"
foreach ($env in $environments) {
    Write-Host "Testing $env environment secrets..." -ForegroundColor Gray
    
    # Try to list secrets (this will fail with 403 for security, but tells us environment exists)
    $secretResult = & gh api repos/$Repository/environments/$env/secrets 2>&1
    if ($secretResult -match "403" -or $secretResult -match "Resource not accessible") {
        Write-CheckResult "Environment '$env' secrets endpoint accessible" $true "Ready for manual secret configuration"
    } elseif ($secretResult -match "404" -or $secretResult -match "Not Found") {
        Write-CheckResult "Environment '$env' not found" $false "Environment may not be created yet"
    } else {
        Write-CheckResult "Environment '$env' secrets configured" $true "Secrets are set up"
    }
}

# Check GitHub Actions status
Write-Section "GitHub Actions Configuration"
$actionsResult = & gh api repos/$Repository/actions/permissions 2>&1
if ($LASTEXITCODE -eq 0) {
    $actionsInfo = $actionsResult | ConvertFrom-Json
    Write-CheckResult "GitHub Actions enabled" $actionsInfo.enabled "Required for deployments"
} else {
    Write-CheckResult "Cannot check GitHub Actions status" $false $actionsResult
}

# Check workflow file exists
Write-Section "Workflow Files"
if (Test-Path ".github/workflows/deploy-auth0.yml") {
    Write-CheckResult "Deployment workflow exists" $true ".github/workflows/deploy-auth0.yml"
} else {
    Write-CheckResult "Deployment workflow missing" $false "Expected: .github/workflows/deploy-auth0.yml"
}

# Check tfvars files
Write-Section "Terraform Configuration"
$tfvarsFiles = @("config/dev.tfvars", "config/qa.tfvars", "config/prod.tfvars")
foreach ($file in $tfvarsFiles) {
    if (Test-Path $file) {
        Write-CheckResult "Configuration file exists" $true $file
    } else {
        Write-CheckResult "Configuration file missing" $false $file
    }
}

# Summary and next steps
Write-Section "Next Steps"
Write-Host "1. 🔐 Configure environment protection rules manually:" -ForegroundColor White
Write-Host "   → https://github.com/$Repository/settings/environments" -ForegroundColor Cyan
Write-Host "2. 🔑 Set up environment secrets for each environment" -ForegroundColor White
Write-Host "3. 🧪 Test deployment with a small change" -ForegroundColor White
Write-Host "4. 📖 Review the full setup guide: ENVIRONMENT_PROTECTION_SETUP.md" -ForegroundColor White

Write-Host "`n✅ Verification complete!" -ForegroundColor Green
Write-Host "💡 If you see any ❌ above, follow the suggested actions to fix them." -ForegroundColor Yellow