terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
}

resource "auth0_resource_server" "this" {
  # If 'manage' is true, loop over the 'servers' map.
  # If 'manage' is false, loop over an empty map.
  for_each = var.settings.manage ? var.settings.servers : {}

  # --- Top-level Arguments ---
  identifier = each.value.identifier
  name       = each.value.name
  # ... (all other optional top-level arguments)
  allow_offline_access                            = each.value.allow_offline_access
  consent_policy                                  = each.value.consent_policy
  enforce_policies                                = each.value.enforce_policies
  signing_alg                                     = each.value.signing_alg
  signing_secret                                  = each.value.signing_secret
  skip_consent_for_verifiable_first_party_clients = each.value.skip_consent_for_verifiable_first_party_clients
  token_dialect                                   = each.value.token_dialect
  token_lifetime                                  = each.value.token_lifetime
  token_lifetime_for_web                          = each.value.token_lifetime_for_web
  verification_location                           = each.value.verification_location

  # --- Dynamic Blocks ---
  dynamic "authorization_details" {
    # This is a list, so we iterate over it
    for_each = each.value.authorization_details == null ? [] : each.value.authorization_details
    content {
      disable = authorization_details.value.disable
      type    = authorization_details.value.type
    }
  }

  dynamic "proof_of_possession" {
    # This is a single object (Max: 1), so we iterate over a list of one
    for_each = each.value.proof_of_possession == null ? [] : [each.value.proof_of_possession]
    content {
      disable   = proof_of_possession.value.disable
      mechanism = proof_of_possession.value.mechanism
      required  = proof_of_possession.value.required
    }
  }

  dynamic "subject_type_authorization" {
    for_each = each.value.subject_type_authorization == null ? [] : [each.value.subject_type_authorization]
    content {
      dynamic "client" {
        for_each = subject_type_authorization.value.client == null ? [] : [subject_type_authorization.value.client]
        content {
          policy = client.value.policy
        }
      }
      dynamic "user" {
        for_each = subject_type_authorization.value.user == null ? [] : [subject_type_authorization.value.user]
        content {
          policy = user.value.policy
        }
      }
    }
  }

  dynamic "token_encryption" {
    for_each = each.value.token_encryption == null ? [] : [each.value.token_encryption]
    content {
      disable = token_encryption.value.disable
      format  = token_encryption.value.format
      dynamic "encryption_key" {
        for_each = token_encryption.value.encryption_key == null ? [] : [token_encryption.value.encryption_key]
        content {
          algorithm = encryption_key.value.algorithm
          pem       = encryption_key.value.pem
          kid       = encryption_key.value.kid
          name      = encryption_key.value.name
        }
      }
    }
  }

  # --- Logical Validation ---
  lifecycle {
    precondition {
      condition     = each.value.signing_alg == null ? true : contains(["HS256", "RS256", "PS256"], each.value.signing_alg)
      error_message = "Invalid 'signing_alg' for ${each.key}. Must be one of: HS256, RS256, PS256."
    }
    precondition {
      condition     = (each.value.signing_alg == "HS256") ? each.value.signing_secret != null : true
      error_message = "When 'signing_alg' is 'HS256', 'signing_secret' is required for ${each.key}."
    }
  }
}