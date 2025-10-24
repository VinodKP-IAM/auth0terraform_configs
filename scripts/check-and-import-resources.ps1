param(
    [string]$Auth0Domain,
    [string]$Auth0ClientId,
    [string]$Auth0ClientSecret
)

# Function to get Auth0 access token
function Get-Auth0Token {
    $body = @{
        client_id = $Auth0ClientId
        client_secret = $Auth0ClientSecret
        audience = "https://$Auth0Domain/api/v2/"
        grant_type = "client_credentials"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "https://$Auth0Domain/oauth/token" -Method Post -Body $body -ContentType "application/json"
    return $response.access_token
}

# Get Auth0 token
$token = Get-Auth0Token
$headers = @{
    Authorization = "Bearer $token"
}

Write-Host "🔍 Checking for existing Auth0 resources..."

# Check for existing clients
$clients = Invoke-RestMethod -Uri "https://$Auth0Domain/api/v2/clients" -Headers $headers -Method Get
foreach ($client in $clients) {
    $resourceId = "auth0_client.${($client.name -replace '[^a-zA-Z0-9]','_').ToLower()}"
    Write-Host "Checking client: $($client.name)"
    
    # Check if resource exists in state
    $stateCheck = terraform state list | Select-String -Pattern $resourceId
    if (!$stateCheck) {
        Write-Host "Importing client: $($client.name)"
        terraform import "$resourceId" "$($client.client_id)"
    }
}

# Check for existing resource servers
$resourceServers = Invoke-RestMethod -Uri "https://$Auth0Domain/api/v2/resource-servers" -Headers $headers -Method Get
foreach ($server in $resourceServers) {
    $resourceId = "auth0_resource_server.${($server.name -replace '[^a-zA-Z0-9]','_').ToLower()}"
    Write-Host "Checking resource server: $($server.name)"
    
    $stateCheck = terraform state list | Select-String -Pattern $resourceId
    if (!$stateCheck) {
        Write-Host "Importing resource server: $($server.name)"
        terraform import "$resourceId" "$($server.id)"
    }
}

# Check for existing roles
$roles = Invoke-RestMethod -Uri "https://$Auth0Domain/api/v2/roles" -Headers $headers -Method Get
foreach ($role in $roles) {
    $resourceId = "auth0_role.${($role.name -replace '[^a-zA-Z0-9]','_').ToLower()}"
    Write-Host "Checking role: $($role.name)"
    
    $stateCheck = terraform state list | Select-String -Pattern $resourceId
    if (!$stateCheck) {
        Write-Host "Importing role: $($role.name)"
        terraform import "$resourceId" "$($role.id)"
    }
}

# Check for existing custom actions
$actions = Invoke-RestMethod -Uri "https://$Auth0Domain/api/v2/actions" -Headers $headers -Method Get
foreach ($action in $actions.actions) {
    $resourceId = "auth0_action.${($action.name -replace '[^a-zA-Z0-9]','_').ToLower()}"
    Write-Host "Checking action: $($action.name)"
    
    $stateCheck = terraform state list | Select-String -Pattern $resourceId
    if (!$stateCheck) {
        Write-Host "Importing action: $($action.name)"
        terraform import "$resourceId" "$($action.id)"
    }
}

Write-Host "✅ Resource check and import completed"