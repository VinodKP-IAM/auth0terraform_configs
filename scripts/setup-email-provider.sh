#!/bin/bash

# Auth0 Custom Email Provider Setup Script
# This script helps you set up the necessary secrets for your custom email provider

echo "🚀 Auth0 Custom Email Provider Setup"
echo "======================================"
echo ""

# Check if required tools are available
if ! command -v curl &> /dev/null; then
    echo "❌ curl is required but not installed."
    exit 1
fi

echo "📋 Available Email Services:"
echo "1. SMTP (Generic - Gmail, Outlook, etc.)"
echo "2. SendGrid"
echo "3. Mailgun"
echo "4. AWS SES"
echo ""

read -p "Choose your email service (1-4): " service_choice

case $service_choice in
    1)
        EMAIL_SERVICE="SMTP"
        echo ""
        echo "📧 SMTP Configuration"
        echo "====================="
        read -p "SMTP Host (e.g., smtp.gmail.com): " SMTP_HOST
        read -p "SMTP Port (e.g., 587): " SMTP_PORT
        read -p "SMTP Username: " SMTP_USER
        read -s -p "SMTP Password: " SMTP_PASS
        echo ""
        ;;
    2)
        EMAIL_SERVICE="SENDGRID"
        echo ""
        echo "📨 SendGrid Configuration"
        echo "========================="
        read -s -p "SendGrid API Key: " SENDGRID_API_KEY
        echo ""
        ;;
    3)
        EMAIL_SERVICE="MAILGUN"
        echo ""
        echo "📮 Mailgun Configuration"
        echo "========================"
        read -s -p "Mailgun API Key: " MAILGUN_API_KEY
        echo ""
        read -p "Mailgun Domain: " MAILGUN_DOMAIN
        ;;
    4)
        EMAIL_SERVICE="SES"
        echo ""
        echo "☁️ AWS SES Configuration"
        echo "========================="
        read -p "AWS Access Key ID: " AWS_ACCESS_KEY_ID
        read -s -p "AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
        echo ""
        read -p "AWS Region (e.g., us-east-1): " AWS_REGION
        ;;
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
read -p "Environment (development/qa/production): " ENVIRONMENT

echo ""
echo "🔧 Configuration Summary"
echo "========================"
echo "Email Service: $EMAIL_SERVICE"
echo "Environment: $ENVIRONMENT"
echo ""

echo "📝 Next Steps:"
echo "1. Go to your Auth0 Dashboard"
echo "2. Navigate to Actions → Library"
echo "3. Find your custom email provider action"
echo "4. Click on the action name"
echo "5. Go to the 'Secrets' tab"
echo "6. Update the following secrets:"
echo ""
echo "   EMAIL_SERVICE = $EMAIL_SERVICE"
echo "   ENVIRONMENT = $ENVIRONMENT"

case $service_choice in
    1)
        echo "   SMTP_HOST = $SMTP_HOST"
        echo "   SMTP_PORT = $SMTP_PORT"
        echo "   SMTP_USER = $SMTP_USER"
        echo "   SMTP_PASS = [your password]"
        ;;
    2)
        echo "   SENDGRID_API_KEY = [your API key]"
        ;;
    3)
        echo "   MAILGUN_API_KEY = [your API key]"
        echo "   MAILGUN_DOMAIN = $MAILGUN_DOMAIN"
        ;;
    4)
        echo "   AWS_ACCESS_KEY_ID = $AWS_ACCESS_KEY_ID"
        echo "   AWS_SECRET_ACCESS_KEY = [your secret key]"
        echo "   AWS_REGION = $AWS_REGION"
        ;;
esac

echo ""
echo "7. Click 'Save' to update the secrets"
echo ""
echo "🧪 Testing:"
echo "- Test with Auth0's 'Try Connection' feature"
echo "- Check the action logs for debugging"
echo "- Monitor email delivery in your service's dashboard"
echo ""
echo "📚 For detailed setup instructions, see: EMAIL_PROVIDER_SETUP.md"
echo ""
echo "✅ Setup complete! Your custom email provider is ready to use."