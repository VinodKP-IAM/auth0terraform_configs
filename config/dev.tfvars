


# --- Module Settings ---
# This one block controls the entire tenant module.
# To add a new setting (e.g., picture_url), you just add a new line here.
tenant_settings = {
  manage              = true
  friendly_name       = "ITCyberSec Solutions"  # Match existing tenant name
  session_lifetime    = 168  # Match existing setting
  support_email       = "vinodkumar.kp05@gmail.com"  # Match existing setting
  allowed_logout_urls = ["http://localhost:3000/logout"]
}

prompt_settings = {
  manage                       = true
  universal_login_experience = "new"
  identifier_first           = true
}

attack_protection_settings = {
  manage = false  # Disabled - requires paid subscription

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
    admin_notification_frequency = ["immediately"]
  }

  breached_password_detection = {
    enabled = false  # Disabled - requires paid subscription
    method  = "standard"
    shields = ["admin_notification", "block"]
  }
}

# Auth0 branding - Disabled for free tier
branding_settings = {
  manage   = false  # Disabled - requires paid subscription
  logo_url = "https://www.shutterstock.com/shutterstock/photos/2174926871/display_1500/stock-vector-circle-line-simple-design-logo-blue-format-jpg-png-eps-2174926871.jpg"
  colors = {
    primary         = "#1A53E0"
    page_background = "#F4F6F8"
  }
}

email_provider_settings = {
  manage               = true
  name                 = "custom"
  default_from_address = "noreply@my-dev-domain.com"
  enabled              = true
  credentials          = {}
  
  # Temporarily disable custom action to work around Auth0 limitation
  custom_action = null
}
# Custom action code will be added separately after resolving the limitation

# This map defines all the email templates we want to manage.
# The keys "welcome" and "reset" are just logical names.
email_templates_settings = {
  
  manage = false
  
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

resource_servers_settings = {
  manage = true
  servers = {
    "my_main_api" = {
      name                 = "My Main API (Dev)"
      identifier           = "https://api.my-dev-company.com"
      signing_alg          = "RS256"
      allow_offline_access = true
      token_lifetime       = 7200
      skip_consent_for_verifiable_first_party_clients = true
    }
  }
}
log_streams_settings = {
  manage = false  # Temporarily disabled due to free tier limitations
  streams = {}
}

roles_settings = {
  manage = true
  roles = {
    "admin" = {
      name        = "Administrator"
      description = "Full access for system admins (DEV)"
    }
    
    "user" = {
      name        = "Standard User"
      description = "Standard read-only access for users (DEV)"
    }
  }
}


clients_settings = {
  manage = false  # Temporarily disabled due to free tier limitations
  clients = {}
}

guardian_settings = {
  manage = false  # Disabled - deprecated feature with insufficient privileges
  policy = "never" # Enforce MFA for all logins

  # Enable basic factors
  email         = true
  otp           = true
  recovery_code = true

  # Example: Enable Phone (using Auth0 provider)
  phone = {
    enabled       = true
    provider      = "auth0" # Use Auth0's built-in SMS/Voice
    message_types = ["sms"] # Allow SMS only
  }
  
  # Example: Enable WebAuthn Platform (like Windows Hello, Touch ID)
  webauthn_platform = {
     enabled = true
  }
  
  # Example: Enable WebAuthn Roaming (like YubiKeys)
  webauthn_roaming = {
     enabled = true
     user_verification = "preferred" # Ask for PIN/Biometric if key supports it
  }

  # Note: To enable Duo or Push, you would add their respective blocks here
  # duo = { ... }
  # push = { ... }
}

actions_settings = {
  manage = true
  actions = {
    "post_login_action" = {
      name = "Add User Metadata - Dev"
      runtime = "node18"
      deploy = true
      code = <<-EOT
      /**
       * Handler that will be called during the execution of a PostLogin flow.
       *
       * @param {Event} event - Details about the request and the user.
       * @param {PostLoginAPI} api - Interface whose methods can change the behavior of the login.
       */
      exports.onExecutePostLogin = async (event, api) => {
        // Development environment - add metadata for tracking
        console.log('Post-login action triggered for user:', event.user.email);
        
        // Add last login timestamp
        api.user.setAppMetadata('last_login_dev', new Date().toISOString());
        
        // Add login count (increment or initialize)
        const currentCount = event.user.app_metadata?.login_count_dev || 0;
        api.user.setAppMetadata('login_count_dev', currentCount + 1);
        
        // Add environment info
        api.user.setAppMetadata('environment', 'development');
        
        // Log for debugging
        console.log('Updated user metadata:', {
          last_login_dev: new Date().toISOString(),
          login_count_dev: currentCount + 1,
          environment: 'development'
        });
      };
      EOT
      
      supported_triggers = {
        id = "post-login"
        version = "v3"
      }
    }
    
    "pre_user_registration_action" = {
      name = "User Registration Validation - Dev"
      runtime = "node18"
      deploy = true
      code = <<-EOT
      /**
       * Handler that will be called during the execution of a PreUserRegistration flow.
       *
       * @param {Event} event - Details about the context and user that is attempting to register.
       * @param {PreUserRegistrationAPI} api - Interface whose methods can change the behavior of the registration.
       */
      exports.onExecutePreUserRegistration = async (event, api) => {
        console.log('Pre-registration action triggered for:', event.user.email);
        
        // Development environment validations
        const email = event.user.email;
        
        // Block test/spam emails in development
        const blockedDomains = ['test.com', 'spam.com', 'fake.com'];
        const emailDomain = email.split('@')[1];
        
        if (blockedDomains.includes(emailDomain)) {
          console.log('Blocking registration for domain:', emailDomain);
          api.access.deny('registration_blocked', 'This email domain is not allowed in development');
          return;
        }
        
        // Add registration metadata
        api.user.setAppMetadata('registered_in_dev', true);
        api.user.setAppMetadata('registration_timestamp', new Date().toISOString());
        
        console.log('Registration approved for:', email);
      };
      EOT
      
      supported_triggers = {
        id = "pre-user-registration"
        version = "v2"
      }
    }

    # SMS action disabled due to runtime version compatibility issues
    # Uncomment and configure if needed when subscription supports it
  }
}