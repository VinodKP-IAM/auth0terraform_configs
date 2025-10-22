terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
}

# Configure the Auth0 Provider
provider "auth0" {
  domain        = var.auth0_domain
  client_id     = var.auth0_client_id
  client_secret = var.auth0_client_secret
}

# --- Call the Tenant Module ---
# This passes the entire settings map from the .tfvars
# file directly into the module.
module "my_tenant_settings" {
  source = "./modules/auth0-tenant"
  
  settings = var.tenant_settings
}

module "my_prompts" {
  source = "./modules/auth0-prompt"

  # Pass the entire settings object to the module
  settings = var.prompt_settings
}

module "my_attack_protection" {
  source = "./modules/auth0-attack-protection"

  # Pass the entire settings object to the module
  settings = var.attack_protection_settings
}

module "my_branding" {
  source = "./modules/auth0-branding"

  # Pass the entire settings object to the module
  settings = var.branding_settings
}

# Email Provider Module - Temporarily disabled due to Auth0 limitation
# module "my_email_provider" {
#   source = "./modules/auth0-email-provider"
#
#   # Pass the entire settings object to the module
#   settings = var.email_provider_settings
# }

module "my_email_templates" {
  source = "./modules/auth0-email-templates"

  # Pass the entire settings object to the module
  settings = var.email_templates_settings
}

module "my_resource_servers" {
  source = "./modules/auth0-resource-servers"

  # Pass the entire settings object to the module
  settings = var.resource_servers_settings
}

module "my_log_streams" {
  source = "./modules/auth0-log-streams"

  # Pass the entire settings object to the module
  settings = var.log_streams_settings
}

module "my_roles" {
  source = "./modules/auth0-roles"

  # Pass the entire settings object to the module
  settings = var.roles_settings
}

module "my_actions" {
  source = "./modules/auth0-actions"

  # Pass the entire settings object to the module
  settings = var.actions_settings
}

module "my_clients" {
  source = "./modules/auth0-clients"

  # Pass the entire settings object to the module
  settings = var.clients_settings
}

module "my_guardian" {
  source = "./modules/auth0-guardian"

  # Pass the entire settings object to the module
  settings = var.guardian_settings
}

# Output tenant information for visibility
output "tenant_info" {
  description = "Information about the Auth0 tenant being managed"
  value = {
    domain      = var.auth0_domain
    client_id   = var.auth0_client_id
    friendly_name = try(var.tenant_settings.friendly_name, "Not specified")
  }
  sensitive = true
}

output "tenant_domain_only" {
  description = "Auth0 tenant domain (non-sensitive)"
  value = var.auth0_domain
  sensitive = true
}