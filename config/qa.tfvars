
# Tenant Configuration
tenant_friendly_name = "cdw"
tenant_support_email = "support@cdw.com"

environment = "qa"

# SMTP configuration for email provider
smtp_host  = "smtp.yourprovider.com"
smtp_port  = 587
smtp_user  = "your-smtp-username"
smtp_pass  = "your-smtp-password"
smtp_secure = true

# Action Configuration - set to false if action already exists
create_login_action = false

# Resource Configuration - set to false if resources already exist
create_resource_server = false
create_admin_role = false
create_user_role = false

# Optional Features - set to true only if properly configured
create_email_templates = false
create_log_stream = false
enable_enhanced_breach_detection = false
enable_breach_detection = false

# Email Provider Configuration for QA Environment
email_provider_settings = {
  manage               = true
  name                 = "custom"
  default_from_address = "noreply@qa.your-domain.com"
  enabled              = true
  credentials          = {}
  
  custom_action = {
    name = "custom-email-provider-qa"
    runtime = "node18"
    deploy = true
    code = <<-EOT
    /**
     * Custom Email Provider Handler for Auth0 - QA Environment
     * Production-ready configuration with proper error handling
     */
    exports.onExecuteCustomEmailProvider = async (event, api) => {
      const axios = require('axios');
      const nodemailer = require('nodemailer');
      
      console.log('🔧 QA Custom Email Provider triggered');
      console.log('📧 Email Type:', event.email_data.type);
      console.log('👤 User:', event.user.email);
      console.log('🏷️ Template:', event.email_data.template);
      
      // QA Environment uses SendGrid by default
      const EMAIL_SERVICE = event.secrets.EMAIL_SERVICE || 'SENDGRID';
      const ENVIRONMENT = 'qa';
      
      try {
        let emailResult;
        
        switch (EMAIL_SERVICE.toUpperCase()) {
          case 'SENDGRID':
            emailResult = await sendWithSendGrid(event);
            break;
          case 'MAILGUN':
            emailResult = await sendWithMailgun(event);
            break;
          case 'SMTP':
          default:
            emailResult = await sendWithSMTP(event);
            break;
        }
        
        console.log('✅ QA Email sent successfully:', emailResult);
        
        // Log to QA monitoring
        await logEmailDelivery(event, emailResult, 'success', ENVIRONMENT);
        
      } catch (error) {
        console.error('❌ QA Email sending failed:', error.message);
        
        await logEmailDelivery(event, null, 'failed', ENVIRONMENT, error.message);
        
        // QA should have stricter error handling than dev
        console.log('🔄 QA: Attempting SMTP fallback...');
        try {
          const fallbackResult = await sendWithSMTP(event);
          console.log('✅ QA Fallback email sent:', fallbackResult);
        } catch (fallbackError) {
          console.error('❌ QA Fallback failed:', fallbackError.message);
          // In QA, we might want to fail the flow to catch issues
          api.access.deny('email_delivery_failed', 'QA: Email delivery failed after retry');
        }
      }
      
      return;
    };
    
    // Reuse the same helper functions from dev
    async function sendWithSendGrid(event) {
      const SENDGRID_API_KEY = event.secrets.SENDGRID_API_KEY;
      
      if (!SENDGRID_API_KEY) {
        throw new Error('SendGrid API key not configured for QA');
      }
      
      const payload = {
        personalizations: [{
          to: [{ email: event.email_data.to }],
          subject: '[QA] ' + event.email_data.subject
        }],
        from: { email: event.email_data.from },
        content: [
          { type: 'text/plain', value: event.email_data.text_body || '' },
          { type: 'text/html', value: event.email_data.html_body || '' }
        ]
      };
      
      const response = await axios.post('https://api.sendgrid.com/v3/mail/send', payload, {
        headers: {
          'Authorization': 'Bearer ' + SENDGRID_API_KEY,
          'Content-Type': 'application/json'
        }
      });
      
      return { service: 'SendGrid-QA', messageId: response.headers['x-message-id'] };
    }
    
    async function sendWithMailgun(event) {
      const MAILGUN_API_KEY = event.secrets.MAILGUN_API_KEY;
      const MAILGUN_DOMAIN = event.secrets.MAILGUN_DOMAIN;
      
      if (!MAILGUN_API_KEY || !MAILGUN_DOMAIN) {
        throw new Error('Mailgun credentials not configured for QA');
      }
      
      const formData = new URLSearchParams();
      formData.append('from', event.email_data.from);
      formData.append('to', event.email_data.to);
      formData.append('subject', '[QA] ' + event.email_data.subject);
      formData.append('text', event.email_data.text_body || '');
      formData.append('html', event.email_data.html_body || '');
      
      const response = await axios.post(
        'https://api.mailgun.net/v3/' + MAILGUN_DOMAIN + '/messages',
        formData,
        {
          auth: {
            username: 'api',
            password: MAILGUN_API_KEY
          }
        }
      );
      
      return { service: 'Mailgun-QA', messageId: response.data.id };
    }
    
    async function sendWithSMTP(event) {
      const SMTP_HOST = event.secrets.SMTP_HOST || 'smtp.gmail.com';
      const SMTP_PORT = parseInt(event.secrets.SMTP_PORT) || 587;
      const SMTP_USER = event.secrets.SMTP_USER;
      const SMTP_PASS = event.secrets.SMTP_PASS;
      
      if (!SMTP_USER || !SMTP_PASS) {
        throw new Error('SMTP credentials not configured for QA');
      }
      
      const transporter = nodemailer.createTransporter({
        host: SMTP_HOST,
        port: SMTP_PORT,
        secure: SMTP_PORT === 465,
        auth: {
          user: SMTP_USER,
          pass: SMTP_PASS
        }
      });
      
      const mailOptions = {
        from: event.email_data.from,
        to: event.email_data.to,
        subject: '[QA] ' + event.email_data.subject,
        text: event.email_data.text_body,
        html: event.email_data.html_body
      };
      
      const result = await transporter.sendMail(mailOptions);
      return { service: 'SMTP-QA', messageId: result.messageId };
    }
    
    async function logEmailDelivery(event, result, status, environment, error = null) {
      const logData = {
        timestamp: new Date().toISOString(),
        environment: environment,
        email_type: event.email_data.type,
        template: event.email_data.template,
        recipient: event.email_data.to,
        status: status,
        service: result?.service || 'unknown',
        messageId: result?.messageId || null,
        error: error
      };
      
      console.log('📊 QA Email Delivery Log:', JSON.stringify(logData, null, 2));
      
      // Send to QA monitoring webhook
      const QA_LOG_WEBHOOK = event.secrets.QA_LOG_WEBHOOK_URL;
      if (QA_LOG_WEBHOOK) {
        try {
          await axios.post(QA_LOG_WEBHOOK, logData, {
            timeout: 5000,
            headers: { 'Content-Type': 'application/json' }
          });
        } catch (logError) {
          console.error('⚠️ QA logging webhook failed:', logError.message);
        }
      }
    }
    EOT
  }
}
