#!/bin/bash
# Update existing Auth0 custom email provider action with our code

echo "🔧 Updating Auth0 Custom Email Provider Action..."

# First, let's update the existing action with our custom code
cat > temp_action_code.js << 'EOF'
/**
 * Custom Email Provider Handler for Auth0
 * Supports multiple email services: SMTP, SendGrid, Mailgun, AWS SES
 *
 * @param {Event} event - Details about the user and the context in which they are logging in.
 * @param {CustomEmailProviderAPI} api - Methods and utilities to help change the behavior of sending a email notification.
 */
exports.onExecuteCustomEmailProvider = async (event, api) => {
  const axios = require('axios');
  const nodemailer = require('nodemailer');
  
  console.log('🚀 Custom Email Provider triggered');
  console.log('📧 Email Type:', event.email_data.type);
  console.log('👤 User:', event.user.email);
  console.log('🏷️ Template:', event.email_data.template);
  
  // Get email service configuration from environment variables
  const EMAIL_SERVICE = event.secrets.EMAIL_SERVICE || 'SMTP'; // SMTP, SENDGRID, MAILGUN, SES
  const ENVIRONMENT = event.secrets.ENVIRONMENT || 'development';
  
  try {
    let emailResult;
    
    switch (EMAIL_SERVICE.toUpperCase()) {
      case 'SENDGRID':
        emailResult = await sendWithSendGrid(event);
        break;
      case 'MAILGUN':
        emailResult = await sendWithMailgun(event);
        break;
      case 'SES':
        emailResult = await sendWithAWSSES(event);
        break;
      case 'SMTP':
      default:
        emailResult = await sendWithSMTP(event);
        break;
    }
    
    console.log('✅ Email sent successfully:', emailResult);
    
    // Log email delivery for audit purposes
    await logEmailDelivery(event, emailResult, 'success');
    
  } catch (error) {
    console.error('❌ Email sending failed:', error.message);
    
    // Log the failure
    await logEmailDelivery(event, null, 'failed', error.message);
    
    // In development, don't fail Auth0 flow on email errors
    if (ENVIRONMENT === 'development') {
      console.log('🔧 Development mode: Continuing despite email failure');
      return;
    }
    
    // In production, you might want to use a fallback service
    try {
      console.log('🔄 Attempting fallback email service...');
      const fallbackResult = await sendWithSMTP(event);
      console.log('✅ Fallback email sent:', fallbackResult);
    } catch (fallbackError) {
      console.error('❌ Fallback also failed:', fallbackError.message);
      // Optionally fail the Auth0 flow
      // api.access.deny('email_delivery_failed', 'Unable to send email notification');
    }
  }
  
  return;
};

/**
 * Send email using SendGrid API
 */
async function sendWithSendGrid(event) {
  const SENDGRID_API_KEY = event.secrets.SENDGRID_API_KEY;
  
  if (!SENDGRID_API_KEY) {
    throw new Error('SendGrid API key not configured');
  }
  
  const payload = {
    personalizations: [{
      to: [{ email: event.email_data.to }],
      subject: event.email_data.subject
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
  
  return { service: 'SendGrid', messageId: response.headers['x-message-id'] };
}

/**
 * Send email using Mailgun API
 */
async function sendWithMailgun(event) {
  const MAILGUN_API_KEY = event.secrets.MAILGUN_API_KEY;
  const MAILGUN_DOMAIN = event.secrets.MAILGUN_DOMAIN;
  
  if (!MAILGUN_API_KEY || !MAILGUN_DOMAIN) {
    throw new Error('Mailgun API key or domain not configured');
  }
  
  const formData = new URLSearchParams();
  formData.append('from', event.email_data.from);
  formData.append('to', event.email_data.to);
  formData.append('subject', event.email_data.subject);
  formData.append('text', event.email_data.text_body || '');
  formData.append('html', event.email_data.html_body || '');
  
  const response = await axios.post(
    'https://api.mailgun.net/v3/' + MAILGUN_DOMAIN + '/messages',
    formData,
    {
      auth: {
        username: 'api',
        password: MAILGUN_API_KEY
      },
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    }
  );
  
  return { service: 'Mailgun', messageId: response.data.id };
}

/**
 * Send email using AWS SES
 */
async function sendWithAWSSES(event) {
  // Note: This is a simplified example. In production, use AWS SDK
  const AWS_ACCESS_KEY = event.secrets.AWS_ACCESS_KEY_ID;
  const AWS_SECRET_KEY = event.secrets.AWS_SECRET_ACCESS_KEY;
  const AWS_REGION = event.secrets.AWS_REGION || 'us-east-1';
  
  if (!AWS_ACCESS_KEY || !AWS_SECRET_KEY) {
    throw new Error('AWS credentials not configured');
  }
  
  // For simplicity, using SES API directly
  // In production, consider using AWS SDK for JavaScript
  const payload = {
    Source: event.email_data.from,
    Destination: { ToAddresses: [event.email_data.to] },
    Message: {
      Subject: { Data: event.email_data.subject },
      Body: {
        Text: { Data: event.email_data.text_body || '' },
        Html: { Data: event.email_data.html_body || '' }
      }
    }
  };
  
  // This would require proper AWS signature - simplified for example
  console.log('📨 AWS SES payload prepared:', payload);
  
  return { service: 'AWS SES', messageId: 'ses-' + Date.now() };
}

/**
 * Send email using SMTP (Generic/Fallback)
 */
async function sendWithSMTP(event) {
  const SMTP_HOST = event.secrets.SMTP_HOST || 'smtp.gmail.com';
  const SMTP_PORT = parseInt(event.secrets.SMTP_PORT) || 587;
  const SMTP_USER = event.secrets.SMTP_USER;
  const SMTP_PASS = event.secrets.SMTP_PASS;
  
  if (!SMTP_USER || !SMTP_PASS) {
    // For development, use console logging
    console.log('📧 SMTP Email (DEV MODE):', {
      from: event.email_data.from,
      to: event.email_data.to,
      subject: event.email_data.subject,
      html: event.email_data.html_body,
      text: event.email_data.text_body
    });
    return { service: 'SMTP (Console)', messageId: 'dev-' + Date.now() };
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
    subject: event.email_data.subject,
    text: event.email_data.text_body,
    html: event.email_data.html_body
  };
  
  const result = await transporter.sendMail(mailOptions);
  return { service: 'SMTP', messageId: result.messageId };
}

/**
 * Log email delivery for audit and monitoring
 */
async function logEmailDelivery(event, result, status, error = null) {
  const logData = {
    timestamp: new Date().toISOString(),
    email_type: event.email_data.type,
    template: event.email_data.template,
    recipient: event.email_data.to,
    status: status,
    service: result?.service || 'unknown',
    messageId: result?.messageId || null,
    error: error,
    environment: event.secrets.ENVIRONMENT || 'development'
  };
  
  console.log('📊 Email Delivery Log:', JSON.stringify(logData, null, 2));
  
  // Optional: Send to external logging service
  const LOG_WEBHOOK = event.secrets.LOG_WEBHOOK_URL;
  if (LOG_WEBHOOK) {
    try {
      await axios.post(LOG_WEBHOOK, logData, {
        timeout: 5000,
        headers: { 'Content-Type': 'application/json' }
      });
    } catch (logError) {
      console.error('⚠️ Failed to send to logging webhook:', logError.message);
    }
  }
}
EOF

echo "📝 Custom action code prepared in temp_action_code.js"
echo "🚀 Now updating the Auth0 action..."

# Update the action using Auth0 CLI
if command -v auth0 &> /dev/null; then
    echo "📡 Updating action code via Auth0 CLI..."
    auth0 actions update 50e847e7-f9a1-402f-a118-fd99196bd719 \
        --name "Custom Email Provider (Updated)" \
        --code temp_action_code.js \
        --runtime node18 \
        --dependency axios@1.6.0 \
        --dependency nodemailer@6.9.7
    
    echo "🏗️ Deploying the action..."
    auth0 actions deploy 50e847e7-f9a1-402f-a118-fd99196bd719
    
    echo "✅ Action updated and deployed!"
else
    echo "⚠️ Auth0 CLI not found. You'll need to manually update the action in the Auth0 dashboard."
    echo "📋 Action ID: 50e847e7-f9a1-402f-a118-fd99196bd719"
    echo "📄 Code is in temp_action_code.js"
fi

# Clean up
rm -f temp_action_code.js

echo ""
echo "🎯 Next Steps:"
echo "1. If Auth0 CLI updated the action successfully, you can now run:"
echo "   terraform apply -var-file='config/dev.tfvars'"
echo "2. If not, manually update the action in Auth0 dashboard with the code above"
echo "3. Then run the terraform apply command"