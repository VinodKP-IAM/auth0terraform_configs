# Get Auth0 Management API Token
$auth0Domain = $env:AUTH0_DOMAIN
$auth0ClientId = $env:AUTH0_CLIENT_ID
$auth0ClientSecret = $env:AUTH0_CLIENT_SECRET

$body = @{
    client_id = $auth0ClientId
    client_secret = $auth0ClientSecret
    audience = "https://$auth0Domain/api/v2/"
    grant_type = "client_credentials"
} | ConvertTo-Json

$tokenResponse = Invoke-RestMethod -Method Post -Uri "https://$auth0Domain/oauth/token" -Body $body -ContentType "application/json"
$accessToken = $tokenResponse.access_token

Write-Host "Auth0 API Token obtained successfully"

# Helper function to make Auth0 API calls
function Invoke-Auth0Api {
    param (
        [string]$Endpoint,
        [string]$Method = "Get"
    )
    
    $headers = @{
        Authorization = "Bearer $accessToken"
    }
    
    $response = Invoke-RestMethod -Method $Method -Uri "https://$auth0Domain/api/v2/$Endpoint" -Headers $headers
    return $response
}

Write-Host "🔍 Starting Auth0 resource import process..."

# Import Actions
Write-Host "`n📝 Importing Actions..."
$actions = Invoke-Auth0Api -Endpoint "actions"
foreach ($action in $actions) {
    Write-Host "Found action: $($action.name)"
    if ($action.name -eq "User Registration Validation - Dev") {
        Write-Host "Importing pre_user_registration_action..."
        terraform import 'module.my_actions.auth0_action.this["pre_user_registration_action"]' $action.id
    }
    elseif ($action.name -eq "Add User Metadata - Dev") {
        Write-Host "Importing post_login_action..."
        terraform import 'module.my_actions.auth0_action.this["post_login_action"]' $action.id
    }
}

# Import Resource Servers
Write-Host "`n🌐 Importing Resource Servers..."
$resourceServers = Invoke-Auth0Api -Endpoint "resource-servers"
foreach ($server in $resourceServers) {
    Write-Host "Found resource server: $($server.name)"
    if ($server.identifier -eq "https://api.my-dev-company.com") {
        Write-Host "Importing my_main_api resource server..."
        terraform import 'module.my_resource_servers.auth0_resource_server.this["my_main_api"]' $server.id
    }
}

# Import Roles
Write-Host "`n👥 Importing Roles..."
$roles = Invoke-Auth0Api -Endpoint "roles"
foreach ($role in $roles) {
    Write-Host "Found role: $($role.name)"
    if ($role.name -eq "Administrator") {
        Write-Host "Importing admin role..."
        terraform import 'module.my_roles.auth0_role.this["admin"]' $role.id
    }
    elseif ($role.name -eq "Standard User") {
        Write-Host "Importing user role..."
        terraform import 'module.my_roles.auth0_role.this["user"]' $role.id
    }
}

# Import Log Streams
Write-Host "`n📊 Importing Log Streams..."
$logStreams = Invoke-Auth0Api -Endpoint "log-streams"
foreach ($stream in $logStreams) {
    Write-Host "Found log stream: $($stream.name)"
    if ($stream.name -eq "Dev HTTP Webhook") {
        Write-Host "Importing dev_webhook log stream..."
        terraform import 'module.my_log_streams.auth0_log_stream.this["dev_webhook"]' $stream.id
    }
}

# Import Clients
Write-Host "`n🔑 Importing Clients..."
$clients = Invoke-Auth0Api -Endpoint "clients"
foreach ($client in $clients) {
    Write-Host "Found client: $($client.name)"
    if ($client.name -eq "My SPA Application (Dev)") {
        Write-Host "Importing my_spa_app client..."
        terraform import 'module.my_clients.auth0_client.this["my_spa_app"]' $client.client_id
    }
    elseif ($client.name -eq "My Backend M2M Client (Dev)") {
        Write-Host "Importing my_backend_m2m client..."
        terraform import 'module.my_clients.auth0_client.this["my_backend_m2m"]' $client.client_id
    }
}

# Import Tenant Settings
Write-Host "`n⚙️ Importing Tenant Settings..."
$tenant = Invoke-Auth0Api -Endpoint "tenants/settings"
terraform import 'module.my_tenant_settings.auth0_tenant.this[0]' $auth0Domain

Write-Host "`n✅ Import process completed!"
Write-Host "Run 'terraform plan' to verify the state matches the Auth0 tenant."