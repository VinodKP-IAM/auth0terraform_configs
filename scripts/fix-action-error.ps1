# Quick Fix for Auth0 Action Error
# This script helps fix the "add-user-metadata" action not found error

param(
    [switch]$TestPlan = $false,
    [switch]$CommitChanges = $false
)

Write-Host "🔧 Auth0 Action Error Fix" -ForegroundColor Blue
Write-Host "Issue: Action 'add-user-metadata' not found during deployment" -ForegroundColor Yellow

Write-Host "`n📋 Changes Applied:" -ForegroundColor Green
Write-Host "✅ Removed problematic data source for non-existent action" -ForegroundColor White
Write-Host "✅ Updated logic to use skip_existing_action variable" -ForegroundColor White  
Write-Host "✅ Set skip_existing_action = true in config/dev.tfvars" -ForegroundColor White

if ($TestPlan) {
    Write-Host "`n🧪 Testing Terraform Plan..." -ForegroundColor Cyan
    
    # Test the configuration
    terraform init -upgrade
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Terraform initialized successfully" -ForegroundColor Green
        
        terraform validate
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Configuration is valid" -ForegroundColor Green
            
            Write-Host "`nRunning plan for development environment..." -ForegroundColor Cyan
            terraform plan -var-file="config/dev.tfvars"
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Plan completed successfully - Action error should be resolved!" -ForegroundColor Green
            } else {
                Write-Host "❌ Plan failed - Check output above for details" -ForegroundColor Red
            }
        } else {
            Write-Host "❌ Configuration validation failed" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Terraform initialization failed" -ForegroundColor Red
    }
}

if ($CommitChanges) {
    Write-Host "`n📦 Committing Changes..." -ForegroundColor Cyan
    
    git add main.tf config/dev.tfvars
    git commit -m "fix: resolve Auth0 action 'add-user-metadata' not found error

- Remove problematic data source lookup for non-existent action
- Update action creation logic to use skip_existing_action variable
- Set skip_existing_action = true in config/dev.tfvars to prevent errors
- This allows deployment to proceed without action-related failures"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Changes committed successfully" -ForegroundColor Green
        
        Write-Host "`nPushing to development branch..." -ForegroundColor Cyan
        git push origin development
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Changes pushed - This will trigger a new deployment" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to push changes" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Failed to commit changes" -ForegroundColor Red
    }
}

Write-Host "`n📋 What This Fix Does:" -ForegroundColor Blue
Write-Host "• Prevents Terraform from looking for an action that doesn't exist" -ForegroundColor White
Write-Host "• Uses the skip_existing_action variable to control action creation" -ForegroundColor White
Write-Host "• Allows the deployment to proceed without action-related errors" -ForegroundColor White
Write-Host "• You can later set skip_existing_action = false to create actions" -ForegroundColor White

Write-Host "`n🎯 Next Steps:" -ForegroundColor Green  
Write-Host "1. Run: .\fix-action-error.ps1 -TestPlan  # Test the fix locally" -ForegroundColor Gray
Write-Host "2. Run: .\fix-action-error.ps1 -CommitChanges  # Commit and push fix" -ForegroundColor Gray
Write-Host "3. Monitor: GitHub Actions for successful deployment" -ForegroundColor Gray
Write-Host "4. Optional: Set skip_existing_action = false later to create actions" -ForegroundColor Gray

Write-Host "`n💡 Alternative Approach:" -ForegroundColor Yellow
Write-Host "If you want to create the action, you can:" -ForegroundColor White
Write-Host "• Set skip_existing_action = false in config/dev.tfvars" -ForegroundColor Gray
Write-Host "• The action will be created during the next deployment" -ForegroundColor Gray
Write-Host "• This adds user metadata to login flows automatically" -ForegroundColor Gray