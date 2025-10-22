


# --- Module Settings ---
# This one block controls the entire tenant module.
# To add a new setting (e.g., picture_url), you just add a new line here.
tenant_settings = {
  manage              = true
  friendly_name       = "My DEV Tenant (Managed by TF)"
  session_lifetime         = 72
  maximum_session_lifetime = 168
  support_email       = "dev-support@mycompany.com"
  allowed_logout_urls = ["http://localhost:3000/logout"]
  # picture_url         = "https://my-company.com/logo.png" # Example if you wanted to add this
}

prompt_settings = {
  manage                       = true
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
    admin_notification_frequency = ["immediately"]
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

email_provider_settings = {
  manage               = false
  name                 = "custom"
  default_from_address = "noreply@my-dev-domain.com"
  enabled              = true
  credentials          = {}
  
  custom_action = {
    name = "custom-email-provider-dev"
    runtime = "node18"
    deploy = true
    code = <<-EOT
    /**
     * Handler to be executed while sending an email notification.
     *
     * @param {Event} event - Details about the user and the context in which they are logging in.
     * @param {CustomEmailProviderAPI} api - Methods and utilities to help change the behavior of sending a email notification.
     */
    exports.onExecuteCustomEmailProvider = async (event, api) => {
      // Development environment custom email logic
      console.log('DEV: Sending email notification');
      console.log('User:', event.user.email);
      console.log('Email type:', event.email_data.type);
      
      // Example: Log email data for debugging in dev
      console.log('Email data:', JSON.stringify(event.email_data, null, 2));
      
      // TODO: Implement your custom email service integration here
      // For development, you might want to:
      // 1. Send emails to a test service like Mailtrap
      // 2. Log email content to console
      // 3. Use a development SMTP server
      
      // Example implementation (replace with your service):
      /*
      const nodemailer = require('nodemailer');
      
      const transporter = nodemailer.createTransporter({
        host: 'smtp.mailtrap.io',
        port: 587,
        auth: {
          user: process.env.MAILTRAP_USER,
          pass: process.env.MAILTRAP_PASS
        }
      });
      
      await transporter.sendMail({
        from: event.email_data.from,
        to: event.email_data.to,
        subject: event.email_data.subject,
        html: event.email_data.html_body,
        text: event.email_data.text_body
      });
      */
      
      return;
    };
    EOT
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

resource_servers_settings = {
  manage = true
  
  # The 'servers' map lets you define as many APIs as you want.
  # "my_main_api" is just a logical name for Terraform.
  servers = {
    "my_main_api" = {
      name                 = "My Main API (Dev)"
      identifier           = "https://api.my-dev-company.com"
      signing_alg          = "RS256"
      allow_offline_access = true
      token_lifetime       = 7200 # 2 hours
      skip_consent_for_verifiable_first_party_clients = true
    }
    
    # You could add another API here if you wanted
    # "my_second_api" = {
    #   name       = "My Second API (Dev)"
    #   identifier = "https://api2.my-dev-company.com"
    #   ...
    # }
  }
}

log_streams_settings = {
  manage = true
  
  streams = {
    "dev_webhook" = {
      name   = "Dev HTTP Webhook"
      type   = "http"
      status = "active"
      
      sink = {
        http_endpoint       = "https://my-dev-webhook.site/logs"
        http_content_format = "JSONARRAY"
        http_content_type   = "application/json"
      }
      
      filters = [
        {
          type = "category"
          name = "auth.login.fail"
        },
        {
          type = "category"
          name = "auth.signup.fail"
        }
      ]
    }
  }
}

roles_settings = {
  
  manage = true
  
  # The 'roles' map lets you define as many roles as you want.
  # "admin" and "user" are just the logical keys for Terraform.
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
  
  manage = true
  
  # The 'clients' map defines your applications.
  clients = {
    "my_spa_app" = {
      name            = "My SPA Application (Dev)"
      description     = "Primary single-page application for Dev"
      app_type        = "spa"
      callbacks       = ["http://localhost:3000/callback"]
      allowed_origins = ["http://localhost:3000"]
      web_origins     = ["http://localhost:3000"]
      allowed_logout_urls = ["http://localhost:3000"]
      grant_types     = ["authorization_code", "refresh_token"]
      oidc_conformant = true
      is_first_party  = true
      
      jwt_configuration = {
        alg                 = "RS256"
        lifetime_in_seconds = 3600 # 1 hour
        secret_encoded      = false
      }
      
      refresh_token = {
        rotation_type   = "rotating"
        expiration_type = "expiring"
        token_lifetime  = 2592000 # 30 days
      }
    }

    "my_backend_m2m" = {
      name        = "My Backend M2M Client (Dev)"
      description = "Machine-to-machine client for backend services"
      app_type    = "non_interactive"
      grant_types = ["client_credentials"]
      
      # Example: Allow this M2M client to call the API we defined earlier
      # allowed_clients = [ module.my_resource_servers.auth0_resource_server.this["my_main_api"].client_id ] 
      # Note: To use module outputs like this, you'd need to define outputs in the resource server module.
    }
  }
}

guardian_settings = {
  manage = false
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
    
    "send_phone_message_action" = {
      name = "Custom SMS Provider - Dev"
      runtime = "node18"
      deploy = true
      code = <<-EOT
      /**
       * Handler that will be called during the execution of a SendPhoneMessage flow.
       *
       * @param {Event} event - Details about the request and the phone message.
       * @param {SendPhoneMessageAPI} api - Interface whose methods can change the behavior of sending a phone message.
       */
      exports.onExecuteSendPhoneMessage = async (event, api) => {
        console.log('Custom SMS action triggered');
        console.log('Phone number:', event.message_options.recipient);
        console.log('Message type:', event.message_options.message_type);
        
        // Development: Log the message instead of sending
        console.log('SMS Message Content:', event.message_options.text);
        
        // In development, we might want to use a test SMS service
        // Uncomment and modify for your SMS provider:
        /*
        const axios = require('axios');
        
        try {
          await axios.post('https://api.twilio.com/2010-04-01/Accounts/YOUR_ACCOUNT/Messages.json', {
            To: event.message_options.recipient,
            From: process.env.TWILIO_PHONE_NUMBER,
            Body: event.message_options.text
          }, {
            auth: {
              username: process.env.TWILIO_ACCOUNT_SID,
              password: process.env.TWILIO_AUTH_TOKEN
            }
          });
        } catch (error) {
          console.error('SMS sending failed:', error);
        }
        */
        
        console.log('SMS logged successfully (dev mode)');
      };
      EOT
      
      supported_triggers = {
        id = "send-phone-message"
        version = "v1"
      }
      
      dependencies = [
        {
          name = "axios"
          version = "0.21.1"
        }
      ]
      
      secrets = [
        {
          name = "TWILIO_ACCOUNT_SID"
          value = "your-twilio-account-sid"
        },
        {
          name = "TWILIO_AUTH_TOKEN"
          value = "your-twilio-auth-token"
        },
        {
          name = "TWILIO_PHONE_NUMBER"
          value = "+1234567890"
        }
      ]
    }
  }
}