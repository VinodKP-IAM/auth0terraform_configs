variable "settings" {
  description = "A map of all settings for Auth0 Log Streams."
  type = object({
    manage = optional(bool, false)
    
    # 'streams' is a map where each key is a logical name (e.g., "my_http_stream")
    streams = optional(map(object({
      # --- Required ---
      name = string
      type = string
      sink = object({
        # --- Sink arguments (all optional) ---
        # AWS EventBridge
        aws_account_id = optional(string)
        aws_region     = optional(string)
        # Azure EventGrid
        azure_region          = optional(string)
        azure_resource_group  = optional(string)
        azure_subscription_id = optional(string)
        # Datadog
        datadog_api_key = optional(string)
        datadog_region  = optional(string)
        # HTTP
        http_authorization  = optional(string)
        http_content_format = optional(string)
        http_content_type   = optional(string)
        http_custom_headers = optional(list(object({
          header = string
          value  = string
        })))
        http_endpoint = optional(string)
        # Mixpanel
        mixpanel_project_id             = optional(string)
        mixpanel_region                 = optional(string)
        mixpanel_service_account_password = optional(string)
        mixpanel_service_account_username = optional(string)
        # Segment
        segment_write_key = optional(string)
        # Splunk
        splunk_domain = optional(string)
        splunk_port   = optional(string)
        splunk_secure = optional(bool)
        splunk_token  = optional(string)
        # Sumo Logic
        sumo_source_address = optional(string)
      }) # 'sink' block is required

      # --- Optional ---
      status     = optional(string)
      start_from = optional(string)
      is_priority = optional(bool)
      
      filters = optional(list(object({
        type = string
        name = string
      })))

      pii_config = optional(object({
        log_fields = list(string) # Required if pii_config is present
        algorithm  = optional(string)
        method     = optional(string)
      }))
    })), {})
  })
  default = {}
}