$ErrorActionPreference = "Continue"

# Auth0 credentials
$auth0Domain = "dev-itcybersecsol.us.auth0.com"
$auth0ClientId = "gycltQmas25np3y8Yqeb8BAfNnbmS1dZ"
$auth0ClientSecret = "LPosB67x_-O0u2qvRYCedEES-NQRb8AIlYqcuKw_etO9VAroSw-eRgUwj4giH_DF"

# Get Auth0 Management API token
$tokenResponse = Invoke-RestMethod -Method Post -Uri "https://$auth0Domain/oauth/token" -Body (@{
    client_id = $auth0ClientId
    client_secret = $auth0ClientSecret
    audience = "https://$auth0Domain/api/v2/"
    grant_type = "client_credentials"
} | ConvertTo-Json) -ContentType "application/json"

$token = $tokenResponse.access_token

Write-Host "✅ Got Auth0 Management API token"

# Helper function for Auth0 API calls
function Invoke-Auth0Api {
    param (
        [string]$Endpoint,
        [string]$Method = "Get"
    )
    
    $headers = @{
        Authorization = "Bearer $token"
    }
    
    $response = Invoke-RestMethod -Method $Method -Uri "https://$auth0Domain/api/v2/$Endpoint" -Headers $headers
    return $response
}

# Step 1: Clean up any existing state
Write-Host "🧹 Cleaning up existing state..."
Remove-Item -Path terraform.tfstate* -ErrorAction SilentlyContinue
terraform init

# Step 2: Create initial state file
Write-Host "📝 Creating initial state file..."
@"
{
    "version": 4,
    "terraform_version": "1.5.7",
    "serial": 1,
    "lineage": "$(New-Guid)",
    "outputs": {},
    "resources": []
}
"@ | Set-Content -Path terraform.tfstate

# Step 3: Import existing resources
Write-Host "📥 Importing existing resources..."

# Import roles
Write-Host "`n👥 Importing roles..."
$roles = Invoke-Auth0Api -Endpoint "roles"
foreach ($role in $roles) {
    Write-Host "Processing role: $($role.name)"
    if ($role.name -eq "Administrator") {
        Write-Host "Importing Administrator role..."
        terraform import "module.my_roles.auth0_role.this[`"admin`"]" $role.id
    }
    elseif ($role.name -eq "Standard User") {
        Write-Host "Importing Standard User role..."
        terraform import "module.my_roles.auth0_role.this[`"user`"]" $role.id
    }
}

# Import resource servers
Write-Host "`n🌐 Importing resource servers..."
$resourceServers = Invoke-Auth0Api -Endpoint "resource-servers"
foreach ($server in $resourceServers) {
    if ($server.identifier -eq "https://api.my-dev-company.com") {
        Write-Host "Importing My Main API (Dev)..."
        terraform import "module.my_resource_servers.auth0_resource_server.this[`"my_main_api`"]" $server.id
    }
}

# Import actions
Write-Host "`n⚡ Importing actions..."
$actions = Invoke-Auth0Api -Endpoint "actions"
foreach ($action in $actions) {
    if ($action.name -eq "Add User Metadata - Dev") {
        Write-Host "Importing post-login action..."
        terraform import "module.my_actions.auth0_action.this[`"post_login_action`"]" $action.id
    }
    elseif ($action.name -eq "User Registration Validation - Dev") {
        Write-Host "Importing pre-registration action..."
        terraform import "module.my_actions.auth0_action.this[`"pre_user_registration_action`"]" $action.id
    }
}

# Import tenant settings
Write-Host "`n⚙️ Importing tenant settings..."
terraform import "module.my_tenant_settings.auth0_tenant.this[0]" $auth0Domain

Write-Host "`n✅ Import process completed!"
Write-Host "Running terraform plan to verify state..."
terraform plan -var-file="config/dev.tfvars"