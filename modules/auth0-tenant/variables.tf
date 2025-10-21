# This single variable accepts the entire settings map
# from the root main.tf file.
variable "settings" {
  description = "A map of all settings for the tenant."
  
  # This "shape" must match the object in the root variables.tf
  type = object({
    manage              = optional(bool, false)
    friendly_name       = optional(string)
    session_lifetime    = optional(number)
    support_email       = optional(string)
    picture_url         = optional(string)
    allowed_logout_urls = optional(list(string))
  })
  
  default = {}
}