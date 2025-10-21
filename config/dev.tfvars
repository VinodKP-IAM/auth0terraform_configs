


# --- Module Settings ---
# This one block controls the entire tenant module.
# To add a new setting (e.g., picture_url), you just add a new line here.
tenant_settings = {
  manage              = false
  friendly_name       = "My DEV Tenant (Managed by TF)"
  session_lifetime    = 24
  support_email       = "dev-support@mycompany.com"
  allowed_logout_urls = ["http://localhost:3000/logout"]
  # picture_url         = "https://my-company.com/logo.png" # Example if you wanted to add this
}

prompt_settings = {
  manage                       = false
  universal_login_experience = "new"
  identifier_first           = true
}

attack_protection_settings = {
  manage = true

  brute_force_protection = {
    enabled      = true
    mode         = "count_per_identifier_and_ip"
    max_attempts = 10
    shields      = ["block", "user_notification"]
  }

  suspicious_ip_throttling = {
    enabled = true
    shields = ["admin_notification", "block"]
    pre_login = {
      max_attempts = 100
      rate         = 864000
    }
  }

  breached_password_detection = {
    enabled = true
    method  = "standard"
    shields = ["admin_notification", "block"]
  }
}

# Auth0 branding
branding_settings = {
  manage   = true
  logo_url = "https://www.shutterstock.com/shutterstock/photos/2174926871/display_1500/stock-vector-circle-line-simple-design-logo-blue-format-jpg-png-eps-2174926871.jpg"
  colors = {
    primary         = "#1A53E0"
    page_background = "#F4F6F8"
  }
}

# email provider
email_provider_settings = {
  manage               = true
  name                 = "smtp"
  default_from_address = "noreply@my-dev-domain.com"
  enabled              = true

  credentials = {
    smtp_host = "smtp.mailtrap.io"
    smtp_port = 2525
    smtp_user = "your-smtp-user"
    smtp_pass = "your-smtp-password"
  }
}

# This map defines all the email templates we want to manage.
# The keys "welcome" and "reset" are just logical names.
email_templates_settings = {
  
  manage = true
  
  templates = {
    welcome = {
      template = "welcome_email"
      body     = "<html><body><h1>Welcome to My DEV App!</h1></body></html>"
      from     = "welcome@my-dev-domain.com"
      subject  = "Welcome to DEV"
      syntax   = "liquid"
      enabled  = true
    }

    reset = {
      template = "reset_email"
      body     = "<html><body><h1>Reset Your Password</h1><p>Click <a href=\"{{ url }}\">here</a> to reset.</p></body></html>"
      from     = "support@my-dev-domain.com"
      subject  = "DEV Password Reset"
      syntax   = "liquid"
      enabled  = true
      url_lifetime_in_seconds = 3600
    }
  }
}