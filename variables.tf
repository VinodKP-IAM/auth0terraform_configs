# --- Provider Credentials ---
variable "auth0_domain" {
  description = "Your Auth0 tenant domain"
  type        = string
  sensitive   = true
}

variable "auth0_client_id" {
  description = "Your Auth0 Management API client ID"
  type        = string
  sensitive   = true
}

variable "auth0_client_secret" {
  description = "Your Auth0 Management API client secret"
  type        = string
  sensitive   = true
}

# --- Module Settings ---

# This ONE variable is all we need to accept the settings
# block from the .tfvars file.
variable "tenant_settings" {
  description = "A map of all settings for the Auth0 tenant module."
  
  # This tells Terraform the exact keys and types to expect.
  type = object({
    # We use optional() to mean the user doesn't have to provide every key.
    # We can also set defaults here.
    manage              = optional(bool, false)
    friendly_name       = optional(string) # It's now enforced as a string!
    session_lifetime    = optional(number) # Enforced as a number!
    support_email       = optional(string)
    picture_url         = optional(string)
    allowed_logout_urls = optional(list(string))
  })
  
  # The default is an empty object so the user can omit it entirely.
  default = {}
}

variable "prompt_settings" {
  description = "A map of all settings for the Auth0 prompts module."

  # This "shape" must match the module's variable shape
  type = object({
    manage                       = optional(bool, false)
    universal_login_experience = optional(string, "new")
    identifier_first           = optional(bool, true)
    webauthn_platform_first_factor = optional(bool, false)
  })

  default = {}
}

variable "attack_protection_settings" {
  description = "A map of all settings for Auth0 Attack Protection."
  type = object({
    manage = optional(bool, false)

    suspicious_ip_throttling = optional(object({
      enabled = bool
      allowlist = optional(list(string))
      shields = optional(list(string))
      pre_login = optional(object({
        max_attempts = optional(number)
        rate         = optional(number)
      }))
      pre_user_registration = optional(object({
        max_attempts = optional(number)
        rate         = optional(number)
      }))
    }))

    brute_force_protection = optional(object({
      enabled      = bool
      allowlist    = optional(list(string))
      max_attempts = optional(number)
      mode         = optional(string)
      shields      = optional(list(string))
    }))

    breached_password_detection = optional(object({
      enabled                      = bool
      admin_notification_frequency = optional(list(string))
      method                       = optional(string)
      shields                      = optional(list(string))
      pre_change_password = optional(object({
        shields = optional(list(string))
      }))
      pre_user_registration = optional(object({
        shields = optional(list(string))
      }))
    }))
  })
  default = {}
}

variable "branding_settings" {
  description = "A map of all settings for Auth0 Branding."
  type = object({
    manage      = optional(bool, false)
    logo_url    = optional(string)
    favicon_url = optional(string)
    
    colors = optional(object({
      primary         = optional(string)
      page_background = optional(string)
    }))

    font = optional(object({
      url = string
    }))

    universal_login = optional(object({
      body = string
    }))
  })
  default = {}
}

variable "email_provider_settings" {
  description = "A map of all settings for Auth0 Email Provider."
  type = object({
    manage               = optional(bool, false)
    name                 = optional(string)
    default_from_address = optional(string)
    enabled              = optional(bool)

    credentials = optional(object({
      access_key_id     = optional(string)
      secret_access_key = optional(string)
      region            = optional(string)
      api_key           = optional(string)
      azure_cs_connection_string = optional(string)
      domain = optional(string)
      ms365_client_id     = optional(string)
      ms365_client_secret = optional(string)
      ms365_tenant_id     = optional(string)
      smtp_host = optional(string)
      smtp_port = optional(number)
      smtp_user = optional(string)
      smtp_pass = optional(string)
    }))

    provider_settings = optional(object({
      headers = optional(object({
        x_mc_view_content_link  = optional(string)
        x_ses_configuration_set = optional(string)
      }))
      message = optional(object({
        configuration_set_name = optional(string)
        view_content_link      = optional(bool)
      }))
    }))
  })
  default = {}
}

variable "email_templates_settings" {
  description = "A map of all settings for Auth0 Email Templates."

  type = object({
    manage    = optional(bool, false)
    templates = optional(map(object({
      template                  = string
      body                      = string
      from                      = string
      subject                   = string
      syntax                    = string
      enabled                   = bool
      include_email_in_redirect = optional(bool)
      result_url                = optional(string)
      url_lifetime_in_seconds   = optional(number)
    })), {})
  })
  
  default = {}
}