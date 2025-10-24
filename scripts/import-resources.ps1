# Script to import existing Auth0 resources into Terraform state
param(
    [Parameter(Mandatory=$true)]
    [string]$Auth0Domain,
    
    [Parameter(Mandatory=$true)]
    [string]$ClientId,
    
    [Parameter(Mandatory=$true)]
    [string]$ClientSecret
)

Write-Host "🔍 Starting Auth0 resource import process..."

# First, get Auth0 Management API token
$body = @{
    client_id = $ClientId
    client_secret = $ClientSecret
    audience = "https://$Auth0Domain/api/v2/"
    grant_type = "client_credentials"
} | ConvertTo-Json

$tokenResponse = Invoke-RestMethod -Method Post -Uri "https://$Auth0Domain/oauth/token" -Body $body -ContentType "application/json"
$token = $tokenResponse.access_token

$headers = @{
    Authorization = "Bearer $token"
    'Content-Type' = 'application/json'
}

# Import Actions
Write-Host "⚙️ Importing Actions..."
try {
    $actions = Invoke-RestMethod -Method Get -Uri "https://$Auth0Domain/api/v2/actions" -Headers $headers
    foreach ($action in $actions.actions) {
        if ($action.name -eq "Add User Metadata - Dev") {
            Write-Host "Importing action: $($action.name)"
            $output = terraform import "module.my_actions.auth0_action.this[`"post_login_action`"]" $action.id 2>&1
            Write-Host $output
        }
        elseif ($action.name -eq "User Registration Validation - Dev") {
            Write-Host "Importing action: $($action.name)"
            $output = terraform import "module.my_actions.auth0_action.this[`"pre_user_registration_action`"]" $action.id 2>&1
            Write-Host $output
        }
    }
} catch {
    Write-Host "Error importing actions: $_"
}

# Import Resource Servers
Write-Host "🌐 Importing Resource Servers..."
try {
    $resourceServers = Invoke-RestMethod -Method Get -Uri "https://$Auth0Domain/api/v2/resource-servers" -Headers $headers
    foreach ($server in $resourceServers) {
        if ($server.identifier -eq "https://api.my-dev-company.com") {
            Write-Host "Importing resource server: $($server.name)"
            $output = terraform import "module.my_resource_servers.auth0_resource_server.this[`"my_main_api`"]" $server.id 2>&1
            Write-Host $output
        }
    }
} catch {
    Write-Host "Error importing resource servers: $_"
}

# Import Roles
Write-Host "👥 Importing Roles..."
try {
    $roles = Invoke-RestMethod -Method Get -Uri "https://$Auth0Domain/api/v2/roles" -Headers $headers
    foreach ($role in $roles) {
        if ($role.name -eq "Administrator") {
            Write-Host "Importing role: $($role.name)"
            $output = terraform import "module.my_roles.auth0_role.this[`"admin`"]" $role.id 2>&1
            Write-Host $output
        }
        elseif ($role.name -eq "Standard User") {
            Write-Host "Importing role: $($role.name)"
            $output = terraform import "module.my_roles.auth0_role.this[`"user`"]" $role.id 2>&1
            Write-Host $output
        }
    }
} catch {
    Write-Host "Error importing roles: $_"
}

Write-Host "✅ Import process completed!"
Write-Host "You can now run terraform plan to verify the state matches the Auth0 tenant."