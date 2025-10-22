variable "settings" {
  description = "A map of all settings for Auth0 Clients (Applications)."
  type = object({
    manage = optional(bool, false)
    # 'clients' is a map where each key is a logical name (e.g., "my_spa_app")
    clients = optional(map(object({
      # --- Required ---
      name = string

      # --- Optional Top-Level ---
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
      oidc_backchannel_logout_urls                         = optional(set(string)) # Deprecated but included
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
      encryption_key                                       = optional(map(string)) # WS-Fed specific

      # --- Optional Nested Blocks (Max 1) ---
      jwt_configuration = optional(object({
        lifetime_in_seconds = optional(number)
        secret_encoded      = optional(bool)
        alg                 = optional(string)
        scopes              = optional(map(string))
      }))

      refresh_token = optional(object({
        rotation_type               = string # Required if block present
        expiration_type             = string # Required if block present
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
        backchannel_logout_urls = set(string) # Required if block present
        backchannel_logout_initiators = optional(object({
          mode = string # Required if nested block present
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
        allow_any_profile_of_type = list(string) # Required if block present
      }))

      token_quota = optional(object({
        client_credentials = object({ # Required if block present
           enforce = optional(bool)
           per_day = optional(number)
           per_hour = optional(number)
        })
      }))
      
      # --- Addons Block (Very Complex) ---
      addons = optional(object({
        # Simple Addons (just indicators)
        box       = optional(object({}))
        cloudbees = optional(object({}))
        concur    = optional(object({}))
        dropbox   = optional(object({}))
        wsfed     = optional(object({}))

        # Addons with specific fields
        aws = optional(object({
          principal           = optional(string)
          role                = optional(string)
          lifetime_in_seconds = optional(number)
        }))
        azure_blob = optional(object({
          account_name       = optional(string)
          storage_access_key = optional(string)
          signed_identifier  = optional(string)
          expiration         = optional(number)
          blob_name          = optional(string)
          blob_read          = optional(bool)
          blob_write         = optional(bool)
          blob_delete        = optional(bool)
          container_name     = optional(string)
          container_read     = optional(bool)
          container_write    = optional(bool)
          container_delete   = optional(bool)
          container_list     = optional(bool)
        }))
        azure_sb = optional(object({
          namespace    = optional(string)
          sas_key_name = optional(string)
          sas_key      = optional(string)
          entity_path  = optional(string)
          expiration   = optional(number)
        }))
        echosign = optional(object({ domain = optional(string) }))
        egnyte   = optional(object({ domain = optional(string) }))
        firebase = optional(object({
          secret              = optional(string) # SDK v2
          lifetime_in_seconds = optional(number) # SDK v3+
          private_key         = optional(string) # SDK v3+
          client_email        = optional(string) # SDK v3+
          private_key_id      = optional(string) # SDK v3+
        }))
        layer = optional(object({
          provider_id = string # Required
          key_id      = string # Required
          private_key = string # Required
          principal   = optional(string)
          expiration  = optional(number)
        }))
        mscrm    = optional(object({ url = optional(string) }))
        newrelic = optional(object({ account = optional(string) }))
        office365 = optional(object({
          domain     = optional(string)
          connection = optional(string)
        }))
        rms      = optional(object({ url = optional(string) }))
        salesforce = optional(object({ entity_id = optional(string) }))
        salesforce_api = optional(object({
          client_id             = optional(string)
          principal             = optional(string)
          community_name        = optional(string)
          community_url_section = optional(string)
        }))
        salesforce_sandbox_api = optional(object({
          client_id             = optional(string)
          principal             = optional(string)
          community_name        = optional(string)
          community_url_section = optional(string)
        }))
        samlp = optional(object({
          audience                        = optional(string)
          issuer                          = optional(string)
          mappings                        = optional(map(string))
          create_upn_claim                = optional(bool)
          passthrough_claims_with_no_mapping = optional(bool)
          map_unknown_claims_as_is        = optional(bool)
          map_identities                  = optional(bool)
          signature_algorithm             = optional(string)
          digest_algorithm                = optional(string)
          authn_context_class_ref         = optional(string)
          name_identifier_format          = optional(string)
          name_identifier_probes          = optional(list(string))
          lifetime_in_seconds             = optional(number)
          sign_response                   = optional(bool)
          typed_attributes                = optional(bool)
          include_attribute_name_format   = optional(bool)
          signing_cert                    = optional(string)
          destination                     = optional(string)
          recipient                       = optional(string)
          binding                         = optional(string)
          flexible_mappings               = optional(string)
          logout = optional(object({
            callback    = optional(string)
            slo_enabled = optional(bool)
          }))
        }))
        sap_api = optional(object({
          token_endpoint_url   = optional(string)
          client_id            = optional(string)
          name_identifier_format = optional(string)
          username_attribute   = optional(string)
          service_password     = optional(string)
          scope                = optional(string)
        }))
        sentry   = optional(object({ org_slug = optional(string), base_url = optional(string) }))
        sharepoint = optional(object({ url = optional(string), external_url = optional(list(string)) }))
        slack    = optional(object({ team = optional(string) }))
        springcm = optional(object({ acs_url = optional(string) }))
        sso_integration = optional(object({ name = optional(string), version = optional(string) }))
        wams     = optional(object({ master_key = optional(string) }))
        zendesk  = optional(object({ account_name = optional(string) }))
        zoom     = optional(object({ account = optional(string) }))
      })) # End addons
    })), {}) # End clients map
  }) # End settings object
  default = {}
}