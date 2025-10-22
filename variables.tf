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

variable "resource_servers_settings" {
  description = "A map of all settings for Auth0 Resource Servers."
  type = object({
    manage = optional(bool, false)
    servers = optional(map(object({
      identifier                                      = string
      name                                            = optional(string)
      allow_offline_access                            = optional(bool)
      consent_policy                                  = optional(string)
      enforce_policies                                = optional(bool)
      signing_alg                                     = optional(string)
      signing_secret                                  = optional(string)
      skip_consent_for_verifiable_first_party_clients = optional(bool)
      token_dialect                                   = optional(string)
      token_lifetime                                  = optional(number)
      token_lifetime_for_web                          = optional(number)
      verification_location                           = optional(string)
      authorization_details = optional(list(object({
        disable = optional(bool)
        type    = optional(string)
      })))
      proof_of_possession = optional(object({
        disable   = optional(bool)
        mechanism = optional(string)
        required  = optional(bool)
      }))
      subject_type_authorization = optional(object({
        client = optional(object({
          policy = optional(string)
        }))
        user = optional(object({
          policy = optional(string)
        }))
      }))
      token_encryption = optional(object({
        disable = optional(bool)
        format  = optional(string)
        encryption_key = optional(object({
          algorithm = string
          pem       = string
          kid       = optional(string)
          name      = optional(string)
        }))
      }))
    })), {})
  })
  default = {}
}

variable "log_streams_settings" {
  description = "A map of all settings for Auth0 Log Streams."
  type = object({
    manage  = optional(bool, false)
    streams = optional(map(object({
      name       = string
      type       = string
      sink = object({
        aws_account_id                  = optional(string)
        aws_region                      = optional(string)
        azure_region                    = optional(string)
        azure_resource_group            = optional(string)
        azure_subscription_id           = optional(string)
        datadog_api_key                 = optional(string)
        datadog_region                  = optional(string)
        http_authorization              = optional(string)
        http_content_format             = optional(string)
        http_content_type               = optional(string)
        http_custom_headers             = optional(list(object({ header = string, value = string })))
        http_endpoint                   = optional(string)
        mixpanel_project_id             = optional(string)
        mixpanel_region                 = optional(string)
        mixpanel_service_account_password = optional(string)
        mixpanel_service_account_username = optional(string)
        segment_write_key               = optional(string)
        splunk_domain                   = optional(string)
        splunk_port                     = optional(string)
        splunk_secure                   = optional(bool)
        splunk_token                    = optional(string)
        sumo_source_address             = optional(string)
      })
      status      = optional(string)
      start_from  = optional(string)
      is_priority = optional(bool)
      filters     = optional(list(object({ type = string, name = string })))
      pii_config = optional(object({
        log_fields = list(string)
        algorithm  = optional(string)
        method     = optional(string)
      }))
    })), {})
  })
  default = {}
}

variable "roles_settings" {
  description = "A map of all settings for Auth0 Roles."

  type = object({
    manage = optional(bool, false)
    roles = optional(map(object({
      name        = string
      description = optional(string)
    })), {})
  })
  
  default = {}
}

variable "actions_settings" {
  description = "A map of all settings for Auth0 Actions."

  type = object({
    manage = optional(bool, false)
    actions = optional(map(object({
      name = string
      code = string
      supported_triggers = object({
        id      = string
        version = string
      })
      deploy       = optional(bool)
      runtime      = optional(string)
      dependencies = optional(list(object({
        name    = string
        version = string
      })))
      secrets = optional(list(object({
        name  = string
        value = string
      })))
    })), {})
  })
  
  default = {}
}

variable "clients_settings" {
  description = "A map of all settings for Auth0 Clients (Applications)."
  # Note: This type definition is identical to the one in the module's variables.tf
  type = object({
    manage = optional(bool, false)
    clients = optional(map(object({
      name                                            = string
      description                                          = optional(string)
      app_type                                             = optional(string)
      compliance_level                                     = optional(string)
      logo_uri                                             = optional(string)
      is_first_party                                       = optional(bool)
      oidc_conformant                                      = optional(bool)
      callbacks                                            = optional(list(string))
      allowed_origins                                      = optional(list(string))
      web_origins                                          = optional(list(string))
      allowed_logout_urls                                  = optional(list(string))
      grant_types                                          = optional(list(string))
      allowed_clients                                      = optional(list(string))
      client_aliases                                       = optional(list(string))
      is_token_endpoint_ip_header_trusted                  = optional(bool)
      custom_login_page_on                                 = optional(bool)
      custom_login_page                                    = optional(string)
      form_template                                        = optional(string)
      initiate_login_uri                                   = optional(string)
      oidc_backchannel_logout_urls                         = optional(set(string))
      client_metadata                                      = optional(map(string))
      sso                                                  = optional(bool)
      sso_disabled                                         = optional(bool)
      cross_origin_auth                                    = optional(bool)
      cross_origin_loc                                     = optional(string)
      require_proof_of_possession                          = optional(bool)
      skip_non_verifiable_callback_uri_confirmation_prompt = optional(bool)
      require_pushed_authorization_requests              = optional(bool)
      resource_server_identifier                           = optional(string)
      organization_usage                                   = optional(string)
      organization_require_behavior                        = optional(string)
      encryption_key                                       = optional(map(string))
      jwt_configuration = optional(object({
        lifetime_in_seconds = optional(number)
        secret_encoded      = optional(bool)
        alg                 = optional(string)
        scopes              = optional(map(string))
      }))
      refresh_token = optional(object({
        rotation_type               = string
        expiration_type             = string
        leeway                      = optional(number)
        token_lifetime              = optional(number)
        idle_token_lifetime         = optional(number)
        infinite_token_lifetime     = optional(bool)
        infinite_idle_token_lifetime = optional(bool)
        policies = optional(set(object({
          audience = string
          scope    = list(string)
        })))
      }))
      mobile = optional(object({
        android = optional(object({
          app_package_name         = optional(string)
          sha256_cert_fingerprints = optional(list(string))
        }))
        ios = optional(object({
          team_id               = optional(string)
          app_bundle_identifier = optional(string)
        }))
      }))
      native_social_login = optional(object({
         apple = optional(object({ enabled = optional(bool) }))
         facebook = optional(object({ enabled = optional(bool) }))
         google = optional(object({ enabled = optional(bool) }))
      }))
      oidc_logout = optional(object({
        backchannel_logout_urls = set(string)
        backchannel_logout_initiators = optional(object({
          mode = string
          selected_initiators = optional(set(string))
        }))
      }))
      default_organization = optional(object({
         disable = optional(bool)
         flows = optional(list(string))
         organization_id = optional(string)
      }))
      session_transfer = optional(object({
        allow_refresh_token             = optional(bool)
        allowed_authentication_methods  = optional(set(string))
        can_create_session_transfer_token = optional(bool)
        enforce_cascade_revocation      = optional(bool)
        enforce_device_binding          = optional(string)
        enforce_online_refresh_tokens   = optional(bool)
      }))
      token_exchange = optional(object({
        allow_any_profile_of_type = list(string)
      }))
      token_quota = optional(object({
        client_credentials = object({
           enforce = optional(bool)
           per_day = optional(number)
           per_hour = optional(number)
        })
      }))
      addons = optional(object({
        box       = optional(object({}))
        cloudbees = optional(object({}))
        concur    = optional(object({}))
        dropbox   = optional(object({}))
        wsfed     = optional(object({}))
        aws = optional(object({ principal = optional(string), role = optional(string), lifetime_in_seconds = optional(number) }))
        azure_blob = optional(object({ account_name = optional(string), storage_access_key = optional(string), signed_identifier = optional(string), expiration = optional(number), blob_name = optional(string), blob_read = optional(bool), blob_write = optional(bool), blob_delete = optional(bool), container_name = optional(string), container_read = optional(bool), container_write = optional(bool), container_delete = optional(bool), container_list = optional(bool) }))
        azure_sb = optional(object({ namespace = optional(string), sas_key_name = optional(string), sas_key = optional(string), entity_path = optional(string), expiration = optional(number) }))
        echosign = optional(object({ domain = optional(string) }))
        egnyte   = optional(object({ domain = optional(string) }))
        firebase = optional(object({ secret = optional(string), lifetime_in_seconds = optional(number), private_key = optional(string), client_email = optional(string), private_key_id = optional(string) }))
        layer = optional(object({ provider_id = string, key_id = string, private_key = string, principal = optional(string), expiration = optional(number) }))
        mscrm    = optional(object({ url = optional(string) }))
        newrelic = optional(object({ account = optional(string) }))
        office365 = optional(object({ domain = optional(string), connection = optional(string) }))
        rms      = optional(object({ url = optional(string) }))
        salesforce = optional(object({ entity_id = optional(string) }))
        salesforce_api = optional(object({ client_id = optional(string), principal = optional(string), community_name = optional(string), community_url_section = optional(string) }))
        salesforce_sandbox_api = optional(object({ client_id = optional(string), principal = optional(string), community_name = optional(string), community_url_section = optional(string) }))
        samlp = optional(object({ audience = optional(string), issuer = optional(string), mappings = optional(map(string)), create_upn_claim = optional(bool), passthrough_claims_with_no_mapping = optional(bool), map_unknown_claims_as_is = optional(bool), map_identities = optional(bool), signature_algorithm = optional(string), digest_algorithm = optional(string), authn_context_class_ref = optional(string), name_identifier_format = optional(string), name_identifier_probes = optional(list(string)), lifetime_in_seconds = optional(number), sign_response = optional(bool), typed_attributes = optional(bool), include_attribute_name_format = optional(bool), signing_cert = optional(string), destination = optional(string), recipient = optional(string), binding = optional(string), flexible_mappings = optional(string), logout = optional(object({ callback = optional(string), slo_enabled = optional(bool) })) }))
        sap_api = optional(object({ token_endpoint_url = optional(string), client_id = optional(string), name_identifier_format = optional(string), username_attribute = optional(string), service_password = optional(string), scope = optional(string) }))
        sentry   = optional(object({ org_slug = optional(string), base_url = optional(string) }))
        sharepoint = optional(object({ url = optional(string), external_url = optional(list(string)) }))
        slack    = optional(object({ team = optional(string) }))
        springcm = optional(object({ acs_url = optional(string) }))
        sso_integration = optional(object({ name = optional(string), version = optional(string) }))
        wams     = optional(object({ master_key = optional(string) }))
        zendesk  = optional(object({ account_name = optional(string) }))
        zoom     = optional(object({ account = optional(string) }))
      }))
    })), {})
  })
  default = {}
}


variable "guardian_settings" {
  description = "A map of all settings for Auth0 Guardian MFA."
  # Note: This type definition is identical to the one in the module's variables.tf
  type = object({
    manage        = optional(bool, false)
    policy        = optional(string)
    email         = optional(bool)
    otp           = optional(bool)
    recovery_code = optional(bool)
    duo = optional(object({
      enabled         = bool
      integration_key = optional(string)
      secret_key      = optional(string)
      hostname        = optional(string)
    }))
    phone = optional(object({
      enabled       = bool
      provider      = optional(string)
      message_types = optional(list(string))
      options = optional(object({
        from                  = optional(string)
        messaging_service_sid = optional(string)
        sid                   = optional(string)
        auth_token            = optional(string)
        enrollment_message   = optional(string)
        verification_message = optional(string)
      }))
    }))
    push = optional(object({
      enabled  = bool
      provider = optional(string)
      amazon_sns = optional(object({
        aws_access_key_id                 = string
        aws_region                        = string
        aws_secret_access_key             = string
        sns_apns_platform_application_arn = string
        sns_gcm_platform_application_arn  = string
      }))
      custom_app = optional(object({
        app_name        = optional(string)
        apple_app_link  = optional(string)
        google_app_link = optional(string)
      }))
      direct_apns = optional(object({
         bundle_id = string
         p12       = string
         sandbox   = bool
         enabled   = optional(bool)
      }))
      direct_fcm = optional(object({
        server_key = string
      }))
    }))
    webauthn_platform = optional(object({
      enabled                  = bool
      override_relying_party = optional(bool)
      relying_party_identifier = optional(string)
    }))
    webauthn_roaming = optional(object({
      enabled                  = bool
      user_verification        = optional(string)
      override_relying_party = optional(bool)
      relying_party_identifier = optional(string)
    }))
  })
  default = {}
}