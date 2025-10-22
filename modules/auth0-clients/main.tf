terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
}

resource "auth0_client" "this" {
  # If 'manage' is true, loop over the 'clients' map.
  for_each = var.settings.manage ? var.settings.clients : {}

  # --- Required Arguments ---
  name = each.value.name

  # --- Optional Top-Level Arguments ---
  description                                          = each.value.description
  app_type                                             = each.value.app_type
  compliance_level                                     = each.value.compliance_level
  logo_uri                                             = each.value.logo_uri
  is_first_party                                       = each.value.is_first_party
  oidc_conformant                                      = each.value.oidc_conformant
  callbacks                                            = each.value.callbacks
  allowed_origins                                      = each.value.allowed_origins
  web_origins                                          = each.value.web_origins
  allowed_logout_urls                                  = each.value.allowed_logout_urls
  grant_types                                          = each.value.grant_types
  allowed_clients                                      = each.value.allowed_clients
  client_aliases                                       = each.value.client_aliases
  is_token_endpoint_ip_header_trusted                  = each.value.is_token_endpoint_ip_header_trusted
  custom_login_page_on                                 = each.value.custom_login_page_on
  custom_login_page                                    = each.value.custom_login_page
  form_template                                        = each.value.form_template
  initiate_login_uri                                   = each.value.initiate_login_uri
  oidc_backchannel_logout_urls                         = each.value.oidc_backchannel_logout_urls # Deprecated
  client_metadata                                      = each.value.client_metadata
  sso                                                  = each.value.sso
  sso_disabled                                         = each.value.sso_disabled
  cross_origin_auth                                    = each.value.cross_origin_auth
  cross_origin_loc                                     = each.value.cross_origin_loc
  require_proof_of_possession                          = each.value.require_proof_of_possession
  skip_non_verifiable_callback_uri_confirmation_prompt = each.value.skip_non_verifiable_callback_uri_confirmation_prompt
  require_pushed_authorization_requests              = each.value.require_pushed_authorization_requests
  resource_server_identifier                           = each.value.resource_server_identifier
  organization_usage                                   = each.value.organization_usage
  organization_require_behavior                        = each.value.organization_require_behavior
  encryption_key                                       = each.value.encryption_key

  # --- Optional Nested Blocks (Max 1) ---
  dynamic "jwt_configuration" {
    for_each = each.value.jwt_configuration == null ? [] : [each.value.jwt_configuration]
    content {
      lifetime_in_seconds = jwt_configuration.value.lifetime_in_seconds
      secret_encoded      = jwt_configuration.value.secret_encoded
      alg                 = jwt_configuration.value.alg
      scopes              = jwt_configuration.value.scopes
    }
  }

  dynamic "refresh_token" {
    for_each = each.value.refresh_token == null ? [] : [each.value.refresh_token]
    content {
      rotation_type               = refresh_token.value.rotation_type
      expiration_type             = refresh_token.value.expiration_type
      leeway                      = refresh_token.value.leeway
      token_lifetime              = refresh_token.value.token_lifetime
      idle_token_lifetime         = refresh_token.value.idle_token_lifetime
      infinite_token_lifetime     = refresh_token.value.infinite_token_lifetime
      infinite_idle_token_lifetime = refresh_token.value.infinite_idle_token_lifetime
      dynamic "policies" {
          for_each = refresh_token.value.policies == null ? [] : refresh_token.value.policies
          content {
             audience = policies.value.audience
             scope = policies.value.scope
          }
      }
    }
  }

  dynamic "mobile" {
    for_each = each.value.mobile == null ? [] : [each.value.mobile]
    content {
      dynamic "android" {
        for_each = mobile.value.android == null ? [] : [mobile.value.android]
        content {
          app_package_name         = android.value.app_package_name
          sha256_cert_fingerprints = android.value.sha256_cert_fingerprints
        }
      }
      dynamic "ios" {
        for_each = mobile.value.ios == null ? [] : [mobile.value.ios]
        content {
          team_id               = ios.value.team_id
          app_bundle_identifier = ios.value.app_bundle_identifier
        }
      }
    }
  }

  dynamic "native_social_login" {
    for_each = each.value.native_social_login == null ? [] : [each.value.native_social_login]
    content {
      dynamic "apple" {
        for_each = native_social_login.value.apple == null ? [] : [native_social_login.value.apple]
        content { enabled = apple.value.enabled }
      }
       dynamic "facebook" {
        for_each = native_social_login.value.facebook == null ? [] : [native_social_login.value.facebook]
        content { enabled = facebook.value.enabled }
      }
       dynamic "google" {
        for_each = native_social_login.value.google == null ? [] : [native_social_login.value.google]
        content { enabled = google.value.enabled }
      }
    }
  }

  dynamic "oidc_logout" {
    for_each = each.value.oidc_logout == null ? [] : [each.value.oidc_logout]
    content {
      backchannel_logout_urls = oidc_logout.value.backchannel_logout_urls
      dynamic "backchannel_logout_initiators" {
          for_each = oidc_logout.value.backchannel_logout_initiators == null ? [] : [oidc_logout.value.backchannel_logout_initiators]
          content {
             mode = backchannel_logout_initiators.value.mode
             selected_initiators = backchannel_logout_initiators.value.selected_initiators
          }
      }
    }
  }

  dynamic "default_organization" {
    for_each = each.value.default_organization == null ? [] : [each.value.default_organization]
    content {
       disable = default_organization.value.disable
       flows = default_organization.value.flows
       organization_id = default_organization.value.organization_id
    }
  }
  
  dynamic "session_transfer" {
    for_each = each.value.session_transfer == null ? [] : [each.value.session_transfer]
    content {
        allow_refresh_token = session_transfer.value.allow_refresh_token
        allowed_authentication_methods = session_transfer.value.allowed_authentication_methods
        can_create_session_transfer_token = session_transfer.value.can_create_session_transfer_token
        enforce_cascade_revocation = session_transfer.value.enforce_cascade_revocation
        enforce_device_binding = session_transfer.value.enforce_device_binding
        enforce_online_refresh_tokens = session_transfer.value.enforce_online_refresh_tokens
    }
  }

  dynamic "token_exchange" {
    for_each = each.value.token_exchange == null ? [] : [each.value.token_exchange]
    content {
       allow_any_profile_of_type = token_exchange.value.allow_any_profile_of_type
    }
  }

  dynamic "token_quota" {
    for_each = each.value.token_quota == null ? [] : [each.value.token_quota]
    content {
       dynamic "client_credentials" {
          for_each = token_quota.value.client_credentials == null ? [] : [token_quota.value.client_credentials]
          content {
             enforce = client_credentials.value.enforce
             per_day = client_credentials.value.per_day
             per_hour = client_credentials.value.per_hour
          }
       }
    }
  }

  # --- Addons Block ---
  dynamic "addons" {
    for_each = each.value.addons == null ? [] : [each.value.addons]
    content {
      # Simple Addons
      dynamic "box" {
        for_each = addons.value.box == null ? [] : [addons.value.box]
        content {}
      }
      dynamic "cloudbees" {
        for_each = addons.value.cloudbees == null ? [] : [addons.value.cloudbees]
        content {}
      }
      dynamic "concur" {
        for_each = addons.value.concur == null ? [] : [addons.value.concur]
        content {}
      }
      dynamic "dropbox" {
        for_each = addons.value.dropbox == null ? [] : [addons.value.dropbox]
        content {}
      }
      dynamic "wsfed" {
        for_each = addons.value.wsfed == null ? [] : [addons.value.wsfed]
        content {}
      }

      # Addons with specific fields
      dynamic "aws" {
        for_each = addons.value.aws == null ? [] : [addons.value.aws]
        content {
          principal           = aws.value.principal
          role                = aws.value.role
          lifetime_in_seconds = aws.value.lifetime_in_seconds
        }
      }
      dynamic "azure_blob" {
        for_each = addons.value.azure_blob == null ? [] : [addons.value.azure_blob]
        content {
          account_name       = azure_blob.value.account_name
          storage_access_key = azure_blob.value.storage_access_key
          signed_identifier  = azure_blob.value.signed_identifier
          expiration         = azure_blob.value.expiration
          blob_name          = azure_blob.value.blob_name
          blob_read          = azure_blob.value.blob_read
          blob_write         = azure_blob.value.blob_write
          blob_delete        = azure_blob.value.blob_delete
          container_name     = azure_blob.value.container_name
          container_read     = azure_blob.value.container_read
          container_write    = azure_blob.value.container_write
          container_delete   = azure_blob.value.container_delete
          container_list     = azure_blob.value.container_list
        }
      }
      dynamic "azure_sb" {
        for_each = addons.value.azure_sb == null ? [] : [addons.value.azure_sb]
        content {
          namespace    = azure_sb.value.namespace
          sas_key_name = azure_sb.value.sas_key_name
          sas_key      = azure_sb.value.sas_key
          entity_path  = azure_sb.value.entity_path
          expiration   = azure_sb.value.expiration
        }
      }
      dynamic "echosign" {
        for_each = addons.value.echosign == null ? [] : [addons.value.echosign]
        content { domain = echosign.value.domain }
      }
      dynamic "egnyte" {
        for_each = addons.value.egnyte == null ? [] : [addons.value.egnyte]
        content { domain = egnyte.value.domain }
      }
      dynamic "firebase" {
        for_each = addons.value.firebase == null ? [] : [addons.value.firebase]
        content {
          secret              = firebase.value.secret
          lifetime_in_seconds = firebase.value.lifetime_in_seconds
          private_key         = firebase.value.private_key
          client_email        = firebase.value.client_email
          private_key_id      = firebase.value.private_key_id
        }
      }
      dynamic "layer" {
        for_each = addons.value.layer == null ? [] : [addons.value.layer]
        content {
          provider_id = layer.value.provider_id
          key_id      = layer.value.key_id
          private_key = layer.value.private_key
          principal   = layer.value.principal
          expiration  = layer.value.expiration
        }
      }
      dynamic "mscrm" {
        for_each = addons.value.mscrm == null ? [] : [addons.value.mscrm]
        content { url = mscrm.value.url }
      }
      dynamic "newrelic" {
        for_each = addons.value.newrelic == null ? [] : [addons.value.newrelic]
        content { account = newrelic.value.account }
      }
      dynamic "office365" {
        for_each = addons.value.office365 == null ? [] : [addons.value.office365]
        content {
          domain     = office365.value.domain
          connection = office365.value.connection
        }
      }
      dynamic "rms" {
        for_each = addons.value.rms == null ? [] : [addons.value.rms]
        content { url = rms.value.url }
      }
      dynamic "salesforce" {
        for_each = addons.value.salesforce == null ? [] : [addons.value.salesforce]
        content { entity_id = salesforce.value.entity_id }
      }
      dynamic "salesforce_api" {
        for_each = addons.value.salesforce_api == null ? [] : [addons.value.salesforce_api]
        content {
          client_id             = salesforce_api.value.client_id
          principal             = salesforce_api.value.principal
          community_name        = salesforce_api.value.community_name
          community_url_section = salesforce_api.value.community_url_section
        }
      }
      dynamic "salesforce_sandbox_api" {
        for_each = addons.value.salesforce_sandbox_api == null ? [] : [addons.value.salesforce_sandbox_api]
        content {
          client_id             = salesforce_sandbox_api.value.client_id
          principal             = salesforce_sandbox_api.value.principal
          community_name        = salesforce_sandbox_api.value.community_name
          community_url_section = salesforce_sandbox_api.value.community_url_section
        }
      }
      dynamic "samlp" {
        for_each = addons.value.samlp == null ? [] : [addons.value.samlp]
        content {
          audience                        = samlp.value.audience
          issuer                          = samlp.value.issuer
          mappings                        = samlp.value.mappings
          create_upn_claim                = samlp.value.create_upn_claim
          passthrough_claims_with_no_mapping = samlp.value.passthrough_claims_with_no_mapping
          map_unknown_claims_as_is        = samlp.value.map_unknown_claims_as_is
          map_identities                  = samlp.value.map_identities
          signature_algorithm             = samlp.value.signature_algorithm
          digest_algorithm                = samlp.value.digest_algorithm
          authn_context_class_ref         = samlp.value.authn_context_class_ref
          name_identifier_format          = samlp.value.name_identifier_format
          name_identifier_probes          = samlp.value.name_identifier_probes
          lifetime_in_seconds             = samlp.value.lifetime_in_seconds
          sign_response                   = samlp.value.sign_response
          typed_attributes                = samlp.value.typed_attributes
          include_attribute_name_format   = samlp.value.include_attribute_name_format
          signing_cert                    = samlp.value.signing_cert
          destination                     = samlp.value.destination
          recipient                       = samlp.value.recipient
          binding                         = samlp.value.binding
          flexible_mappings               = samlp.value.flexible_mappings
          dynamic "logout" {
            for_each = samlp.value.logout == null ? [] : [samlp.value.logout]
            content {
              callback    = logout.value.callback
              slo_enabled = logout.value.slo_enabled
            }
          }
        }
      }
      dynamic "sap_api" {
        for_each = addons.value.sap_api == null ? [] : [addons.value.sap_api]
        content {
          token_endpoint_url   = sap_api.value.token_endpoint_url
          client_id            = sap_api.value.client_id
          name_identifier_format = sap_api.value.name_identifier_format
          username_attribute   = sap_api.value.username_attribute
          service_password     = sap_api.value.service_password
          scope                = sap_api.value.scope
        }
      }
      dynamic "sentry" {
        for_each = addons.value.sentry == null ? [] : [addons.value.sentry]
        content {
          org_slug = sentry.value.org_slug
          base_url = sentry.value.base_url
        }
      }
      dynamic "sharepoint" {
        for_each = addons.value.sharepoint == null ? [] : [addons.value.sharepoint]
        content {
          url          = sharepoint.value.url
          external_url = sharepoint.value.external_url
        }
      }
      dynamic "slack" {
        for_each = addons.value.slack == null ? [] : [addons.value.slack]
        content { team = slack.value.team }
      }
      dynamic "springcm" {
        for_each = addons.value.springcm == null ? [] : [addons.value.springcm]
        content { acs_url = springcm.value.acs_url }
      }
      dynamic "sso_integration" {
        for_each = addons.value.sso_integration == null ? [] : [addons.value.sso_integration]
        content {
          name    = sso_integration.value.name
          version = sso_integration.value.version
        }
      }
      dynamic "wams" {
        for_each = addons.value.wams == null ? [] : [addons.value.wams]
        content { master_key = wams.value.master_key }
      }
      dynamic "zendesk" {
        for_each = addons.value.zendesk == null ? [] : [addons.value.zendesk]
        content { account_name = zendesk.value.account_name }
      }
      dynamic "zoom" {
        for_each = addons.value.zoom == null ? [] : [addons.value.zoom]
        content { account = zoom.value.account }
      }
    } # End addons content
  } # End addons dynamic block
}