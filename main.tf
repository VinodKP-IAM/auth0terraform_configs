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

module "my_email_provider" {
  source = "./modules/auth0-email-provider"

  # Pass the entire settings object to the module
  settings = var.email_provider_settings
}

module "my_email_templates" {
  source = "./modules/auth0-email-templates"

  # Pass the entire settings object to the module
  settings = var.email_templates_settings
}