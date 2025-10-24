# GitHub Actions Deployment Test Script
# This script tests the GitHub Actions workflow by triggering deployments and monitoring results

param(
    [switch]$TestWorkflow = $false,
    [switch]$TriggerManualDeploy = $false,
    [switch]$TestBranchDeploy = $false,
    [string]$Environment = "development"
)

# Helper Functions
function Write-Step {
    param([string]$Message, [string]$Color = "Yellow")
    Write-Host "`n📋 $Message" -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️ $Message" -ForegroundColor Cyan
}

function Test-GitHubCLI {
    Write-Step "Testing GitHub CLI Authentication"
    
    try {
        $authStatus = gh auth status 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "GitHub CLI is authenticated"
            return $true
        } else {
            Write-Error "GitHub CLI is not authenticated"
            Write-Info "Run: gh auth login"
            return $false
        }
    } catch {
        Write-Error "GitHub CLI is not installed or not in PATH"
        Write-Info "Install from: https://cli.github.com"
        return $false
    }
}

function Test-RepositoryAccess {
    Write-Step "Testing Repository Access"
    
    try {
        $repoInfo = gh repo view KaranGupta05/terraform_auth0 --json name,owner,defaultBranchRef,visibility 2>$null
        if ($LASTEXITCODE -eq 0) {
            $repo = $repoInfo | ConvertFrom-Json
            Write-Success "Repository access confirmed"
            Write-Host "  Repository: $($repo.owner.login)/$($repo.name)" -ForegroundColor Gray
            Write-Host "  Default Branch: $($repo.defaultBranchRef.name)" -ForegroundColor Gray
            Write-Host "  Visibility: $($repo.visibility)" -ForegroundColor Gray
            return $true
        } else {
            Write-Error "Cannot access repository KaranGupta05/terraform_auth0"
            return $false
        }
    } catch {
        Write-Error "Error checking repository access: $_"
        return $false
    }
}

function Test-WorkflowExists {
    Write-Step "Checking Workflow Configuration"
    
    try {
        $workflows = gh workflow list --repo KaranGupta05/terraform_auth0 --json name,path,state 2>$null
        if ($LASTEXITCODE -eq 0) {
            $workflowList = $workflows | ConvertFrom-Json
            $deployWorkflow = $workflowList | Where-Object { $_.name -eq "Deploy Auth0 Infrastructure" }
            
            if ($deployWorkflow) {
                Write-Success "Deploy Auth0 Infrastructure workflow found"
                Write-Host "  Path: $($deployWorkflow.path)" -ForegroundColor Gray
                Write-Host "  State: $($deployWorkflow.state)" -ForegroundColor Gray
                return $true
            } else {
                Write-Error "Deploy Auth0 Infrastructure workflow not found"
                Write-Host "Available workflows:" -ForegroundColor Yellow
                $workflowList | ForEach-Object { 
                    Write-Host "  - $($_.name)" -ForegroundColor Gray
                }
                return $false
            }
        } else {
            Write-Error "Cannot list workflows"
            return $false
        }
    } catch {
        Write-Error "Error checking workflows: $_"
        return $false
    }
}

function Test-EnvironmentSecrets {
    Write-Step "Testing Environment Secrets"
    
    $environments = @("development", "staging", "production")
    $requiredSecrets = @("AUTH0_DOMAIN", "AUTH0_CLIENT_ID", "AUTH0_CLIENT_SECRET")
    $allSecretsValid = $true
    
    foreach ($env in $environments) {
        try {
            Write-Host "`n🌍 Checking $env environment:" -ForegroundColor Cyan
            $secrets = gh api "repos/KaranGupta05/terraform_auth0/environments/$env/secrets" --jq '.[].name' 2>$null
            
            if ($LASTEXITCODE -eq 0 -and $secrets) {
                $secretsList = $secrets -split "`n" | Where-Object { $_ -ne "" }
                Write-Success "Secrets found for $env environment:"
                
                foreach ($secret in $secretsList) {
                    $status = if ($requiredSecrets -contains $secret) { "✅" } else { "ℹ️" }
                    Write-Host "    $status $secret" -ForegroundColor Gray
                }
                
                # Check for missing required secrets
                $missing = $requiredSecrets | Where-Object { $_ -notin $secretsList }
                if ($missing) {
                    Write-Error "Missing required secrets in ${env}:"
                    $missing | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
                    $allSecretsValid = $false
                }
            } else {
                Write-Error "No secrets found for $env environment"
                $allSecretsValid = $false
            }
        } catch {
            Write-Error "Could not check secrets for $env environment: $_"
            $allSecretsValid = $false
        }
    }
    
    return $allSecretsValid
}

function Get-WorkflowRuns {
    param([int]$Limit = 5)
    
    Write-Step "Recent Workflow Runs"
    
    try {
        $runs = gh run list --repo KaranGupta05/terraform_auth0 --workflow="Deploy Auth0 Infrastructure" --limit $Limit --json status,conclusion,createdAt,headBranch,event,displayTitle 2>$null
        
        if ($LASTEXITCODE -eq 0 -and $runs) {
            $runList = $runs | ConvertFrom-Json
            
            if ($runList.Count -eq 0) {
                Write-Info "No workflow runs found"
                return
            }
            
            Write-Success "Found $($runList.Count) recent workflow runs:"
            Write-Host ""
            Write-Host "Status      | Conclusion | Branch        | Event    | Title" -ForegroundColor Yellow
            Write-Host "------------|------------|---------------|----------|------" -ForegroundColor Yellow
            
            foreach ($run in $runList) {
                $status = $run.status.PadRight(11)
                $conclusion = if ($run.conclusion) { $run.conclusion.PadRight(10) } else { "N/A".PadRight(10) }
                $branch = if ($run.headBranch) { $run.headBranch.PadRight(13) } else { "N/A".PadRight(13) }
                $event = $run.event.PadRight(8)
                $title = if ($run.displayTitle.Length -gt 50) { $run.displayTitle.Substring(0, 47) + "..." } else { $run.displayTitle }
                
                $color = switch ($run.conclusion) {
                    "success" { "Green" }
                    "failure" { "Red" }
                    "cancelled" { "Yellow" }
                    default { "Gray" }
                }
                
                Write-Host "$status | $conclusion | $branch | $event | $title" -ForegroundColor $color
            }
        } else {
            Write-Info "No workflow runs found or error accessing runs"
        }
    } catch {
        Write-Error "Error getting workflow runs: $_"
    }
}

function Start-ManualWorkflow {
    param(
        [string]$Environment = "development",
        [bool]$ForceDeploy = $false,
        [bool]$CreateTag = $false
    )
    
    Write-Step "Triggering Manual Workflow"
    Write-Host "  Environment: $Environment" -ForegroundColor Gray
    Write-Host "  Force Deploy: $ForceDeploy" -ForegroundColor Gray
    Write-Host "  Create Tag: $CreateTag" -ForegroundColor Gray
    
    try {
        $forceDeployStr = if ($ForceDeploy) { "true" } else { "false" }
        $createTagStr = if ($CreateTag) { "true" } else { "false" }
        
        gh workflow run "Deploy Auth0 Infrastructure" `
            --repo KaranGupta05/terraform_auth0 `
            --field environment=$Environment `
            --field force_deploy=$forceDeployStr `
            --field create_tag=$createTagStr
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Workflow triggered successfully"
            Write-Info "Waiting for workflow to start..."
            Start-Sleep -Seconds 5
            Get-WorkflowRuns -Limit 3
        } else {
            Write-Error "Failed to trigger workflow"
        }
    } catch {
        Write-Error "Error triggering workflow: $_"
    }
}

function Test-BranchBasedDeployment {
    Write-Step "Testing Branch-Based Deployment"
    
    # Get current branch
    $currentBranch = git branch --show-current
    Write-Host "Current branch: $currentBranch" -ForegroundColor Gray
    
    # Test deployment by pushing to development branch
    $testBranch = "test-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    try {
        Write-Host "`n🔀 Creating test branch: $testBranch" -ForegroundColor Cyan
        git checkout -b $testBranch
        
        # Make a small change to trigger deployment
        $testFile = "test-deployment.txt"
        "Test deployment at $(Get-Date)" | Out-File -FilePath $testFile -Encoding UTF8
        git add $testFile
        git commit -m "test: trigger deployment workflow - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        
        Write-Host "🚀 Pushing to trigger workflow..." -ForegroundColor Cyan
        git push origin $testBranch
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Test branch pushed successfully"
            Write-Info "This should trigger a workflow run for feature branch (plan only)"
            
            Write-Host "`n⏳ Waiting for workflow to start..." -ForegroundColor Yellow
            Start-Sleep -Seconds 10
            Get-WorkflowRuns -Limit 3
            
            # Switch back to original branch
            git checkout $currentBranch
            
            # Optionally clean up test branch
            $cleanup = Read-Host "`nDelete test branch '$testBranch'? (Y/n)"
            if ($cleanup -ne 'n' -and $cleanup -ne 'N') {
                git branch -D $testBranch 2>$null
                git push origin --delete $testBranch 2>$null
                Write-Success "Test branch cleaned up"
            }
        } else {
            Write-Error "Failed to push test branch"
            git checkout $currentBranch
        }
    } catch {
        Write-Error "Error during branch deployment test: $_"
        git checkout $currentBranch 2>$null
    }
}

function Show-DeploymentUrls {
    Write-Step "Deployment URLs and Resources"
    
    Write-Host "🔗 GitHub Repository URLs:" -ForegroundColor Cyan
    Write-Host "  Repository: https://github.com/KaranGupta05/terraform_auth0" -ForegroundColor Gray
    Write-Host "  Actions: https://github.com/KaranGupta05/terraform_auth0/actions" -ForegroundColor Gray
    Write-Host "  Environments: https://github.com/KaranGupta05/terraform_auth0/settings/environments" -ForegroundColor Gray
    Write-Host "  Secrets: https://github.com/KaranGupta05/terraform_auth0/settings/secrets" -ForegroundColor Gray
    
    Write-Host "`n🎯 Workflow Triggers:" -ForegroundColor Cyan
    Write-Host "  Push to 'development' → Deploy to development environment" -ForegroundColor Gray
    Write-Host "  Push to 'main' → Deploy to production environment" -ForegroundColor Gray
    Write-Host "  Create PR → Plan only (no deployment)" -ForegroundColor Gray
    Write-Host "  Create tag 'v*.*.*' → Deploy to production with release" -ForegroundColor Gray
    Write-Host "  Manual trigger → Deploy to selected environment" -ForegroundColor Gray
}

# Main execution
Write-Host "🚀 GitHub Actions Deployment Verification" -ForegroundColor Blue
Write-Host "Repository: KaranGupta05/terraform_auth0" -ForegroundColor Cyan

# Step 1: Basic validations
if (-not (Test-GitHubCLI)) { exit 1 }
if (-not (Test-RepositoryAccess)) { exit 1 }
if (-not (Test-WorkflowExists)) { exit 1 }

# Step 2: Check environment setup
$secretsValid = Test-EnvironmentSecrets

# Step 3: Show current workflow status
Get-WorkflowRuns

# Step 4: Interactive testing
if ($TestWorkflow -or $TriggerManualDeploy) {
    Write-Host "`n🧪 Interactive Testing Options:" -ForegroundColor Yellow
    
    if ($TriggerManualDeploy) {
        Start-ManualWorkflow -Environment $Environment
    } else {
        $choice = Read-Host "`nSelect test option:`n1. Trigger manual deployment`n2. Test branch-based deployment`n3. View recent runs only`nEnter choice (1-3)"
        
        switch ($choice) {
            "1" {
                $env = Read-Host "Enter environment (development/staging/production) [$Environment]"
                if ([string]::IsNullOrWhiteSpace($env)) { $env = $Environment }
                Start-ManualWorkflow -Environment $env
            }
            "2" {
                if ($secretsValid) {
                    Test-BranchBasedDeployment
                } else {
                    Write-Error "Environment secrets not properly configured. Please run setup first."
                }
            }
            "3" {
                Get-WorkflowRuns -Limit 10
            }
            default {
                Write-Info "No test selected"
            }
        }
    }
}

if ($TestBranchDeploy) {
    if ($secretsValid) {
        Test-BranchBasedDeployment
    } else {
        Write-Error "Environment secrets not properly configured. Please run setup first."
    }
}

# Step 5: Show helpful information
Show-DeploymentUrls

Write-Host "`n✅ Deployment verification complete!" -ForegroundColor Green
Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Check workflow runs: https://github.com/KaranGupta05/terraform_auth0/actions" -ForegroundColor White
Write-Host "2. Monitor deployment logs in real-time" -ForegroundColor White
Write-Host "3. Verify Auth0 tenant changes after successful deployment" -ForegroundColor White

# Usage examples
Write-Host "`n💡 Usage Examples:" -ForegroundColor Blue
Write-Host "  .\test-deployment.ps1 -TestWorkflow" -ForegroundColor Gray
Write-Host "  .\test-deployment.ps1 -TriggerManualDeploy -Environment development" -ForegroundColor Gray
Write-Host "  .\test-deployment.ps1 -TestBranchDeploy" -ForegroundColor Gray