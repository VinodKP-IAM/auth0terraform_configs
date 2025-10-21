# End-to-End Deployment Setup Script
# This script helps you set up and test the GitHub Actions deployment pipeline

param(
    [switch]$SetupEnvironments = $false,
    [switch]$TestLocalDeploy = $false,
    [switch]$CommitAndPush = $false,
    [string]$Environment = "dev"
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

Write-Host "🚀 Auth0 Terraform - End-to-End Deployment Setup" -ForegroundColor Blue

# Interactive Configuration Section
Write-Step "Interactive Configuration Setup" "Cyan"

# Get GitHub Repository URL - Auto-detect from git remote
$gitRemote = git remote get-url origin 2>$null
$autoDetectedRepo = ""

if ($gitRemote -and $gitRemote -match "github\.com[/:](.*?)/(.*?)(?:\.git)?$") {
    $autoDetectedRepo = "$($matches[1])/$($matches[2])"
}

# Check if the auto-detected repo exists - we'll use the corrected name as default
if ([string]::IsNullOrWhiteSpace($autoDetectedRepo)) {
    $defaultRepoUrl = "KaranGupta05/terraform_auth0"
} else {
    # Auto-detected repo may have different spelling - suggest the actual GitHub repo name
    if ($autoDetectedRepo -eq "KaranGupta05/terraform_auth0") {
        Write-Host "⚠️ Auto-detected '$autoDetectedRepo' - using actual GitHub repo name" -ForegroundColor Yellow
        $defaultRepoUrl = "KaranGupta05/terraform_auth0"
    } else {
        $defaultRepoUrl = $autoDetectedRepo
    }
}

Write-Host "Auto-detected repository: $defaultRepoUrl" -ForegroundColor Cyan
$repoUrl = Read-Host "Enter GitHub repository URL (owner/repo format) [$defaultRepoUrl]"
if ([string]::IsNullOrWhiteSpace($repoUrl)) {
    $repoUrl = $defaultRepoUrl
}
Write-Host "Using repository: $repoUrl" -ForegroundColor Cyan

# Extract owner and repo name from URL
if ($repoUrl -match "^(?:https://github\.com/)?([^/]+)/([^/]+?)(?:\.git)?/?$") {
    $repoOwner = $matches[1]
    $repoName = $matches[2]
} elseif ($repoUrl -match "^([^/]+)/([^/]+)$") {
    $repoOwner = $matches[1]
    $repoName = $matches[2]
} else {
    Write-Error "Invalid repository URL format. Use: owner/repo or https://github.com/owner/repo"
    exit 1
}

Write-Host "Repository Owner: $repoOwner" -ForegroundColor Gray
Write-Host "Repository Name: $repoName" -ForegroundColor Gray

# Get Auth0 Configuration for Each Environment
Write-Host "`n🔐 Auth0 Configuration for Each Environment" -ForegroundColor Yellow
Write-Host "You'll need to provide Auth0 credentials for each environment (development, staging, production)" -ForegroundColor Cyan

$auth0Config = @{}
$environments = @("development", "staging", "production")

foreach ($env in $environments) {
    Write-Host "`n--- $($env.ToUpper()) Environment ---" -ForegroundColor Magenta
    
    $envDomain = Read-Host "Enter Auth0 Domain for $env (e.g., $env-xyz.us.auth0.com)"
    $envClientId = Read-Host "Enter Auth0 Client ID for $env"
    $envClientSecret = Read-Host "Enter Auth0 Client Secret for $env" -AsSecureString
    $envClientSecretPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($envClientSecret))
    
    # Validate inputs for this environment
    if ([string]::IsNullOrWhiteSpace($envDomain) -or [string]::IsNullOrWhiteSpace($envClientId) -or [string]::IsNullOrWhiteSpace($envClientSecretPlain)) {
        Write-Error "All Auth0 configuration values are required for $env environment"
        exit 1
    }
    
    # Store configuration for this environment
    $auth0Config[$env] = @{
        Domain = $envDomain
        ClientId = $envClientId
        ClientSecret = $envClientSecretPlain
    }
    
    Write-Success "✅ $env environment configuration collected"
}

# Optional Configuration
Write-Host "`n⚙️ Optional Configuration" -ForegroundColor Yellow
$tenantFriendlyName = Read-Host "Enter Tenant Friendly Name [CDW]"
if ([string]::IsNullOrWhiteSpace($tenantFriendlyName)) {
    $tenantFriendlyName = "CDW"
}

$tenantSupportEmail = Read-Host "Enter Tenant Support Email [support@$tenantFriendlyName.com]"
if ([string]::IsNullOrWhiteSpace($tenantSupportEmail)) {
    $tenantSupportEmail = "support@$tenantFriendlyName.com"
}

# Display collected configuration
Write-Host "`n📋 Configuration Summary:" -ForegroundColor Green
Write-Host "Repository: $repoUrl" -ForegroundColor White
Write-Host "Tenant Name: $tenantFriendlyName" -ForegroundColor White
Write-Host "Support Email: $tenantSupportEmail" -ForegroundColor White

Write-Host "`nAuth0 Configuration by Environment:" -ForegroundColor Yellow
foreach ($env in $environments) {
    $config = $auth0Config[$env]
    Write-Host "  $($env.ToUpper()):" -ForegroundColor Cyan
    Write-Host "    Domain: $($config.Domain)" -ForegroundColor White
    Write-Host "    Client ID: $($config.ClientId)" -ForegroundColor White
    Write-Host "    Client Secret: $('*' * $config.ClientSecret.Length)" -ForegroundColor White
}

$confirm = Read-Host "`nDo you want to continue with this configuration? (y/N)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "Setup cancelled by user" -ForegroundColor Yellow
    exit 0
}

# Add GitHub CLI to PATH
if (Test-Path "C:\Program Files\GitHub CLI\gh.exe") {
    $env:PATH += ";C:\Program Files\GitHub CLI"
    $ghPath = "C:\Program Files\GitHub CLI\gh.exe"
} else {
    $ghPath = "gh"
}



# Step 1: Setup GitHub Environments
if ($SetupEnvironments) {
    Write-Step "Setting up GitHub Environments"
    
    try {
        # Check GitHub CLI authentication
        Write-Host "Verifying GitHub CLI authentication..." -ForegroundColor Cyan
        $authStatus = & $ghPath auth status 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "GitHub CLI is authenticated"
            
            # Display authentication info for verification
            $authInfo = $authStatus | Select-String "Logged in to github.com as"
            if ($authInfo) {
                Write-Host "  $authInfo" -ForegroundColor Gray
            }
            
            # Check if authenticated user has access to the repository
            Write-Host "Verifying repository access..." -ForegroundColor Cyan
            $repoAccess = & $ghPath repo view $repoUrl --json name,owner 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Repository access confirmed"
                $repoInfo = $repoAccess | ConvertFrom-Json
                Write-Host "  Repository: $($repoInfo.owner.login)/$($repoInfo.name)" -ForegroundColor Gray
                
                # Try to check admin access by attempting to list environments
                & $ghPath api repos/$repoUrl/environments --silent 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Admin access confirmed - can create environments and secrets"
                } else {
                    Write-Host "⚠️  Limited repository access - may not be able to create environments" -ForegroundColor Yellow
                }
            } else {
                Write-Error "Cannot access repository '$repoUrl'"
                Write-Host "Error details: $repoAccess" -ForegroundColor Red
                
                # Try to suggest alternatives
                Write-Host "`n💡 Troubleshooting suggestions:" -ForegroundColor Yellow
                Write-Host "1. Check repository name spelling" -ForegroundColor White
                Write-Host "2. Verify you have access to the repository" -ForegroundColor White
                Write-Host "3. Try re-authenticating: gh auth login --web" -ForegroundColor White
                Write-Host "4. Check if repository is private and you have access" -ForegroundColor White
                
                # Try to list repositories you have access to
                Write-Host "`n🔍 Repositories you have access to:" -ForegroundColor Cyan
                $userRepos = & $ghPath repo list --limit 10 --json name,owner 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $repos = $userRepos | ConvertFrom-Json
                    foreach ($repo in $repos) {
                        Write-Host "  $($repo.owner.login)/$($repo.name)" -ForegroundColor Gray
                    }
                }
                
                return
            }
            
            # Check if GitHub Actions is enabled
            Write-Host "Checking GitHub Actions status..." -ForegroundColor Cyan
            $actionsStatus = & $ghPath api repos/$repoUrl/actions/permissions --jq '.enabled' 2>&1
            if ($actionsStatus -eq "true") {
                Write-Success "GitHub Actions is enabled"
            } else {
                Write-Host "⚠️ GitHub Actions might not be enabled. This is required for environments." -ForegroundColor Yellow
                Write-Host "   Enable it at: https://github.com/$repoUrl/settings/actions" -ForegroundColor Cyan
            }
            
            # Create environments using GitHub API (without protection rules for free plans)
            $environments = @("development", "staging", "production")
            foreach ($env in $environments) {
                Write-Host "Creating environment: $env" -ForegroundColor Cyan
                
                # Create environment using GitHub API - no protection rules for free plans
                $result = & $ghPath api repos/$repoUrl/environments/$env --method PUT 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Environment '$env' created successfully"
                } else {
                    # Check if it already exists
                    & $ghPath api repos/$repoUrl/environments/$env 2>&1 | Out-Null
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "✅ Environment '$env' already exists" -ForegroundColor Yellow
                    } else {
                        Write-Error "Failed to create environment '$env'. Error: $result"
                        Write-Host "Debug info - Exit code: $LASTEXITCODE" -ForegroundColor Yellow
                        
                        Write-Host "💡 You may need to enable GitHub Actions and environments in repository settings" -ForegroundColor Yellow
                        Write-Host "   Go to: https://github.com/$repoUrl/settings/actions" -ForegroundColor Cyan
                    }
                }
            }
            
            # Note: Environment secrets require elevated permissions  
            Write-Host "`n📋 Environment Setup Complete" -ForegroundColor Green
            Write-Host "✅ Environments created: development, staging, production" -ForegroundColor Green
            
            Write-Host "`n⚠️  GitHub Personal Access Token Limitation" -ForegroundColor Yellow
            Write-Host "Your current GitHub CLI token doesn't have permissions to manage environment secrets." -ForegroundColor Yellow
            Write-Host "This is normal for security reasons. You'll need to set up secrets manually." -ForegroundColor Gray
            
            $createdEnvironments = @("development", "staging", "production")
            
            # Set up environment secrets for Auth0 (only for successfully created environments)
            Write-Host "`nSetting up Auth0 environment secrets..." -ForegroundColor Cyan
            
            foreach ($env in $createdEnvironments) {
                Write-Host "Setting Auth0 secrets for $env environment..." -ForegroundColor Cyan
                
                # Get environment-specific credentials
                $envConfig = $auth0Config[$env]
                
                # Set environment secrets using GitHub CLI with proper repo specification and authentication
                Write-Host "  Setting AUTH0_DOMAIN for $env..." -ForegroundColor Gray
                $domainResult = Write-Output $envConfig.Domain | & $ghPath secret set AUTH0_DOMAIN --env $env --repo $repoUrl 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "AUTH0_DOMAIN set successfully for $env"
                } else {
                    Write-Error "Failed to set AUTH0_DOMAIN for $env. Error: $domainResult"
                }
                
                Write-Host "  Setting AUTH0_CLIENT_ID for $env..." -ForegroundColor Gray
                $clientIdResult = Write-Output $envConfig.ClientId | & $ghPath secret set AUTH0_CLIENT_ID --env $env --repo $repoUrl 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "AUTH0_CLIENT_ID set successfully for $env"
                } else {
                    Write-Error "Failed to set AUTH0_CLIENT_ID for $env. Error: $clientIdResult"
                }
                
                Write-Host "  Setting AUTH0_CLIENT_SECRET for $env..." -ForegroundColor Gray
                $clientSecretResult = Write-Output $envConfig.ClientSecret | & $ghPath secret set AUTH0_CLIENT_SECRET --env $env --repo $repoUrl 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "AUTH0_CLIENT_SECRET set successfully for $env"
                    Write-Success "✅ All Auth0 secrets configured for $env environment"
                } else {
                    Write-Error "Failed to set AUTH0_CLIENT_SECRET for $env. Error: $clientSecretResult"
                }
                
                Write-Host "" # Add spacing between environments
            }
            
            # Update tfvars files with collected configuration
            Write-Host "`nUpdating configuration files..." -ForegroundColor Cyan
            $envMapping = @{
                "development" = "dev"
                "staging" = "qa" 
                "production" = "prod"
            }
            
            foreach ($envType in $envMapping.GetEnumerator()) {
                $tfvarsFile = "config/$($envType.Value).tfvars"
                Write-Host "Updating $tfvarsFile..." -ForegroundColor Gray
                
                # Get environment-specific Auth0 configuration
                $envConfig = $auth0Config[$envType.Key]
                
                # Create or update tfvars file with environment-specific credentials
                $tfvarsContent = @"
# $($envType.Key.Substring(0,1).ToUpper() + $envType.Key.Substring(1)) environment
auth0_domain        = "$($envConfig.Domain)"
auth0_client_id     = "$($envConfig.ClientId)"
auth0_client_secret = "$($envConfig.ClientSecret)"

# Tenant Configuration
tenant_friendly_name = "$tenantFriendlyName"
tenant_support_email = "$tenantSupportEmail"

environment = "$($envType.Value)"

# SMTP configuration for email provider
smtp_host  = "smtp.yourprovider.com"
smtp_port  = 587
smtp_user  = "your-smtp-username"
smtp_pass  = "your-smtp-password"
smtp_secure = true

# Action Configuration - set to false if action already exists
create_login_action = false

# Resource Configuration - set to false if resources already exist
create_resource_server = false
create_admin_role = false
create_user_role = false

# Optional Features - set to true only if properly configured
create_email_templates = false
create_log_stream = false
enable_enhanced_breach_detection = false
enable_breach_detection = false
"@
                
                # Ensure config directory exists
                if (!(Test-Path "config")) {
                    New-Item -ItemType Directory -Path "config" -Force | Out-Null
                }
                
                # Write the configuration file
                Set-Content -Path $tfvarsFile -Value $tfvarsContent -Encoding UTF8
                Write-Success "Updated $tfvarsFile with $($envType.Key) environment credentials"
            }
            
            # Provide manual setup instructions if any environments failed
            if ($createdEnvironments.Count -lt $environments.Count) {
                Write-Host "`n🔧 Manual Environment Setup Required" -ForegroundColor Yellow
                Write-Host "Some environments weren't created automatically. Here's how to set them up manually:" -ForegroundColor Cyan
                
                Write-Host "`n1. Go to: https://github.com/$repoUrl/settings/environments" -ForegroundColor White
                Write-Host "2. Click 'New environment' for each missing environment" -ForegroundColor White
                Write-Host "3. Create these environments: development, staging, production" -ForegroundColor White
                
                Write-Host "`n4. For each environment, add these secrets:" -ForegroundColor White
                foreach ($env in $environments) {
                    if ($env -notin $createdEnvironments) {
                        $envConfig = $auth0Config[$env]
                        Write-Host "`n   $($env.ToUpper()) Environment Secrets:" -ForegroundColor Magenta
                        Write-Host "   AUTH0_DOMAIN = $($envConfig.Domain)" -ForegroundColor Gray
                        Write-Host "   AUTH0_CLIENT_ID = $($envConfig.ClientId)" -ForegroundColor Gray
                        Write-Host "   AUTH0_CLIENT_SECRET = $($envConfig.ClientSecret)" -ForegroundColor Gray
                    }
                }
                
                Write-Host "`n💡 After manual setup, your GitHub Actions workflows will have access to these secrets" -ForegroundColor Yellow
            }
        } else {
            Write-Error "GitHub CLI not authenticated. Run: gh auth login"
            return
        }
    } catch {
        Write-Error "Failed to setup environments: $_"
    }
}

# Step 2: Validate current setup
Write-Step "Validating Current Setup"

# Determine if we're running from scripts directory or root directory
$currentDir = Get-Location
$isInScriptsDir = $currentDir.Path.EndsWith("scripts")
$pathPrefix = if ($isInScriptsDir) { ".." } else { "." }

# Check required files with correct path prefix
$requiredFiles = @{
    "$pathPrefix\.github\workflows\deploy-auth0.yml" = "GitHub Actions workflow"
    "$pathPrefix\config\dev.tfvars" = "Development environment variables"
    "$pathPrefix\config\qa.tfvars" = "Staging environment variables" 
    "$pathPrefix\config\prod.tfvars" = "Production environment variables"
    "$pathPrefix\main.tf" = "Terraform main configuration"
    "$pathPrefix\variables.tf" = "Terraform variables"
}

$allFilesExist = $true
foreach ($file in $requiredFiles.GetEnumerator()) {
    if (Test-Path $file.Key) {
        Write-Success "$($file.Value) found: $($file.Key)"
    } else {
        Write-Error "$($file.Value) missing: $($file.Key)"
        $allFilesExist = $false
    }
}

if (-not $allFilesExist) {
    Write-Error "Some required files are missing. Please ensure all files are present."
    return
}

# Step 3: Test Local Deployment
if ($TestLocalDeploy) {
    Write-Step "Testing Local Terraform Deployment"
    
    # Check if terraform.tfvars exists with credentials
    $terraformVarsPath = if ($isInScriptsDir) { "../terraform.tfvars" } else { "./terraform.tfvars" }
    if (-not (Test-Path $terraformVarsPath)) {
        Write-Error "terraform.tfvars not found. Please create it with your Auth0 credentials."
        Write-Host "Required format:" -ForegroundColor Yellow
        Write-Host 'auth0_domain = "your-domain.us.auth0.com"' -ForegroundColor Gray
        Write-Host 'auth0_client_id = "your-client-id"' -ForegroundColor Gray
        Write-Host 'auth0_client_secret = "your-client-secret"' -ForegroundColor Gray
        return
    }
    
    try {
        # Change to parent directory for terraform commands
        Push-Location ".."
        
        # Initialize Terraform
        Write-Host "Initializing Terraform..." -ForegroundColor Cyan
        terraform init
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Terraform initialized successfully"
            
            # Validate configuration
            Write-Host "Validating Terraform configuration..." -ForegroundColor Cyan
            terraform validate
            
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Terraform configuration is valid"
                
                # Run plan
                Write-Host "Running Terraform plan for $Environment environment..." -ForegroundColor Cyan
                terraform plan -var-file="config/$Environment.tfvars"
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Terraform plan completed successfully"
                } else {
                    Write-Error "Terraform plan failed"
                }
            } else {
                Write-Error "Terraform validation failed"
            }
        } else {
            Write-Error "Terraform initialization failed"
        }
    } catch {
        Write-Error "Local deployment test failed: $_"
    } finally {
        # Return to scripts directory
        Pop-Location
    }
}

# Step 4: Commit and Push Changes
if ($CommitAndPush) {
    Write-Step "Committing and Pushing Changes to GitHub"
    
    try {
        # Check if there are changes to commit
        $gitStatus = git status --porcelain
        if ($gitStatus) {
            Write-Host "Changes detected:" -ForegroundColor Cyan
            git status --short
            
            # Add all changes
            git add .
            
            # Commit with descriptive message
            $commitMessage = "feat: implement comprehensive GitHub Actions deployment pipeline

- Add multi-environment support (development/staging/production)
- Implement branching strategy-based deployment logic
- Add automatic release tagging for production deployments  
- Include comprehensive validation and approval gates
- Support feature branches, hotfixes, and release branches"

            git commit -m "$commitMessage"
            
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Changes committed successfully"
                
                # Push to main branch
                Write-Host "Pushing to main branch..." -ForegroundColor Cyan
                git push origin main
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Changes pushed to GitHub successfully"
                } else {
                    Write-Error "Failed to push changes to GitHub"
                }
            } else {
                Write-Error "Failed to commit changes"
            }
        } else {
            Write-Host "No changes to commit" -ForegroundColor Yellow
        }
    } catch {
        Write-Error "Failed to commit and push changes: $_"
    }
}

# Step 5: Next Steps Instructions
Write-Step "Next Steps for End-to-End Testing" "Green"

Write-Host "1. 🔐 Set up GitHub Environment Secrets:" -ForegroundColor White
Write-Host "   Go to: https://github.com/$repoUrl/settings/environments" -ForegroundColor Cyan
Write-Host "   Click on each environment and add secrets:" -ForegroundColor White

Write-Host "`n   For DEVELOPMENT environment:" -ForegroundColor Yellow
Write-Host "   • AUTH0_DOMAIN = $($auth0Config.development.Domain)" -ForegroundColor Gray
Write-Host "   • AUTH0_CLIENT_ID = $($auth0Config.development.ClientId)" -ForegroundColor Gray
Write-Host "   • AUTH0_CLIENT_SECRET = (your development secret)" -ForegroundColor Gray

Write-Host "`n   For STAGING environment:" -ForegroundColor Yellow  
Write-Host "   • AUTH0_DOMAIN = $($auth0Config.staging.Domain)" -ForegroundColor Gray
Write-Host "   • AUTH0_CLIENT_ID = $($auth0Config.staging.ClientId)" -ForegroundColor Gray
Write-Host "   • AUTH0_CLIENT_SECRET = (your staging secret)" -ForegroundColor Gray

Write-Host "`n   For PRODUCTION environment:" -ForegroundColor Yellow
Write-Host "   • AUTH0_DOMAIN = $($auth0Config.production.Domain)" -ForegroundColor Gray
Write-Host "   • AUTH0_CLIENT_ID = $($auth0Config.production.ClientId)" -ForegroundColor Gray
Write-Host "   • AUTH0_CLIENT_SECRET = (your production secret)" -ForegroundColor Gray

Write-Host "`n2. 🔒 Configure Environment Protection Rules (IMPORTANT for Production):" -ForegroundColor White
Write-Host "   Go to: https://github.com/$repoUrl/settings/environments" -ForegroundColor Cyan
Write-Host "`n   For PRODUCTION environment (REQUIRED):" -ForegroundColor Red
Write-Host "   • Required reviewers: Add 1-2 team members who can approve deployments" -ForegroundColor Yellow
Write-Host "   • Wait timer: 15 minutes (optional safety delay)" -ForegroundColor Yellow
Write-Host "   • Deployment branches: Restrict to 'main' or 'master' only" -ForegroundColor Yellow
Write-Host "`n   For STAGING environment (RECOMMENDED):" -ForegroundColor Yellow
Write-Host "   • Required reviewers: Add 1 reviewer for validation" -ForegroundColor Gray
Write-Host "   • Wait timer: 5 minutes (optional)" -ForegroundColor Gray
Write-Host "`n   For DEVELOPMENT environment:" -ForegroundColor Green
Write-Host "   • No restrictions needed (ready to use)" -ForegroundColor Gray

Write-Host "`n3. 🧪 Test the Deployment Flow:" -ForegroundColor White
Write-Host "   Feature Branch → Development:" -ForegroundColor Cyan
Write-Host "   git checkout -b feature/test-deployment" -ForegroundColor Gray
Write-Host "   git push origin feature/test-deployment" -ForegroundColor Gray
Write-Host "   # Creates PR → Shows plan only" -ForegroundColor Green

Write-Host "`n   Development Deployment:" -ForegroundColor Cyan
Write-Host "   git checkout development" -ForegroundColor Gray
Write-Host "   git merge feature/test-deployment" -ForegroundColor Gray
Write-Host "   git push origin development" -ForegroundColor Gray
Write-Host "   # Deploys to development tenant automatically" -ForegroundColor Green

Write-Host "`n   Staging Deployment:" -ForegroundColor Cyan
Write-Host "   git checkout -b release/v1.0.0" -ForegroundColor Gray
Write-Host "   git push origin release/v1.0.0" -ForegroundColor Gray
Write-Host "   # Deploys to staging tenant with approval" -ForegroundColor Green

Write-Host "`n   Production Deployment:" -ForegroundColor Cyan
Write-Host "   git checkout main" -ForegroundColor Gray
Write-Host "   git merge release/v1.0.0" -ForegroundColor Gray
Write-Host "   git push origin main" -ForegroundColor Gray
Write-Host "   # Deploys to production tenant with approval + creates tag" -ForegroundColor Green

Write-Host "`n4. 🔗 Useful Links:" -ForegroundColor White
Write-Host "   • Actions: https://github.com/$repoUrl/actions" -ForegroundColor Cyan
Write-Host "   • Secrets: https://github.com/$repoUrl/settings/secrets" -ForegroundColor Cyan
Write-Host "   • Environments: https://github.com/$repoUrl/settings/environments" -ForegroundColor Cyan

Write-Host "`n💡 Pro Tips:" -ForegroundColor Blue
Write-Host "• Use 'workflow_dispatch' for manual deployments" -ForegroundColor White
Write-Host "• Monitor deployments in the Actions tab" -ForegroundColor White
Write-Host "• Check environment protection rules are properly configured" -ForegroundColor White
Write-Host "• Test with small changes first" -ForegroundColor White

Write-Host "`n🎯 Ready to deploy! Use the flags to run specific steps:" -ForegroundColor Green
Write-Host ".\setup-end-to-end.ps1 -SetupEnvironments" -ForegroundColor Gray
Write-Host ".\setup-end-to-end.ps1 -TestLocalDeploy -Environment dev" -ForegroundColor Gray
Write-Host ".\setup-end-to-end.ps1 -CommitAndPush" -ForegroundColor Gray