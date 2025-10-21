variable "settings" {
  description = "A map of all settings for Auth0 Email Provider."
  type = object({
    manage               = optional(bool, false)
    name                 = optional(string)
    default_from_address = optional(string)
    enabled              = optional(bool)

    credentials = optional(object({
      # AWS SES
      access_key_id     = optional(string)
      secret_access_key = optional(string)
      region            = optional(string) # Also used by Mailgun, SparkPost

      # SendGrid, Mandrill, Mailgun, SparkPost
      api_key = optional(string)
      
      # Azure CS
      azure_cs_connection_string = optional(string)

      # Mandrill
      domain = optional(string)

      # MS365
      ms365_client_id     = optional(string)
      ms365_client_secret = optional(string)
      ms365_tenant_id     = optional(string)
      
      # SMTP
      smtp_host = optional(string)
      smtp_port = optional(number)
      smtp_user = optional(string)
      smtp_pass = optional(string)
    }))

    # This 'provider_settings' object corresponds to the
    # 'settings' block in the resource documentation
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