terraform {
  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"
    }
  }
}

resource "auth0_log_stream" "this" {
  # If 'manage' is true, loop over the 'streams' map.
  for_each = var.settings.manage ? var.settings.streams : {}

  # --- Top-level Arguments ---
  name        = each.value.name
  type        = each.value.type
  status      = each.value.status
  start_from  = each.value.start_from
  is_priority = each.value.is_priority
  filters     = each.value.filters # This argument accepts the list of objects directly

  # --- Sink (Required Block) ---
  dynamic "sink" {
    # The 'sink' object is required, so we iterate over a list of one
    for_each = [each.value.sink]
    content {
      aws_account_id                  = sink.value.aws_account_id
      aws_region                      = sink.value.aws_region
      azure_region                    = sink.value.azure_region
      azure_resource_group            = sink.value.azure_resource_group
      azure_subscription_id           = sink.value.azure_subscription_id
      datadog_api_key                 = sink.value.datadog_api_key
      datadog_region                  = sink.value.datadog_region
      http_authorization              = sink.value.http_authorization
      http_content_format             = sink.value.http_content_format
      http_content_type               = sink.value.http_content_type
      http_custom_headers             = sink.value.http_custom_headers
      http_endpoint                   = sink.value.http_endpoint
      mixpanel_project_id             = sink.value.mixpanel_project_id
      mixpanel_region                 = sink.value.mixpanel_region
      mixpanel_service_account_password = sink.value.mixpanel_service_account_password
      mixpanel_service_account_username = sink.value.mixpanel_service_account_username
      segment_write_key               = sink.value.segment_write_key
      splunk_domain                   = sink.value.splunk_domain
      splunk_port                     = sink.value.splunk_port
      splunk_secure                   = sink.value.splunk_secure
      splunk_token                    = sink.value.splunk_token
      sumo_source_address             = sink.value.sumo_source_address
    }
  }

  # --- PII Config (Optional Block) ---
  dynamic "pii_config" {
    for_each = each.value.pii_config == null ? [] : [each.value.pii_config]
    content {
      log_fields = pii_config.value.log_fields
      algorithm  = pii_config.value.algorithm
      method     = pii_config.value.method
    }
  }

  # --- Logical Validation ---
  lifecycle {
    precondition {
      condition = contains([
        "eventbridge", "eventgrid", "http", "datadog", "splunk", "sumo", "mixpanel", "segment"
      ], each.value.type)
      error_message = "Invalid 'type' for ${each.key}. Must be one of: eventbridge, eventgrid, http, datadog, splunk, sumo, mixpanel, segment."
    }
  }
}