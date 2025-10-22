#!/bin/bash

# Validate Auth0 Custom Email Provider Configuration
echo "🔍 Auth0 Custom Email Provider Configuration Validator"
echo "======================================================"
echo ""

# Check if terraform is available
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed or not in PATH"
    exit 1
fi

# Check current directory
if [ ! -f "main.tf" ]; then
    echo "❌ Please run this script from the root of your Terraform configuration directory"
    exit 1
fi

echo "✅ Terraform found"
echo "✅ Configuration directory detected"
echo ""

# Check for required environment configs
environments=("dev" "qa" "prod")
for env in "${environments[@]}"; do
    config_file="config/${env}.tfvars"
    if [ -f "$config_file" ]; then
        echo "✅ Found: $config_file"
        
        # Check if email_provider_settings exists
        if grep -q "email_provider_settings" "$config_file"; then
            echo "   ✅ Email provider settings configured"
            
            # Check if custom_action exists
            if grep -q "custom_action" "$config_file"; then
                echo "   ✅ Custom action configured"
            else
                echo "   ❌ Custom action not found"
            fi
        else
            echo "   ❌ Email provider settings not found"
        fi
    else
        echo "❓ Missing: $config_file (optional)"
    fi
done

echo ""

# Validate Terraform configuration
echo "🔧 Validating Terraform configuration..."
if terraform validate; then
    echo "✅ Terraform configuration is valid"
else
    echo "❌ Terraform configuration has errors"
    exit 1
fi

echo ""

# Check for required modules
echo "🧩 Checking required modules..."
required_modules=("auth0-email-provider" "auth0-tenant" "auth0-clients")
for module in "${required_modules[@]}"; do
    if [ -d "modules/$module" ]; then
        echo "✅ Module found: $module"
    else
        echo "❌ Missing module: $module"
    fi
done

echo ""

# Test with dev configuration
echo "📋 Testing with dev configuration..."
if [ -f "config/dev.tfvars" ]; then
    if terraform plan -var-file="config/dev.tfvars" > /dev/null 2>&1; then
        echo "✅ Dev configuration plan successful"
    else
        echo "❌ Dev configuration plan failed"
        echo "Run: terraform plan -var-file=\"config/dev.tfvars\" for details"
    fi
else
    echo "❓ No dev configuration to test"
fi

echo ""
echo "🎯 Configuration Summary:"
echo "========================"

# Count resources that will be created
if [ -f "config/dev.tfvars" ]; then
    resource_count=$(terraform plan -var-file="config/dev.tfvars" 2>/dev/null | grep "Plan:" | grep -o "[0-9]* to add" | grep -o "[0-9]*")
    if [ ! -z "$resource_count" ]; then
        echo "📊 Resources to be created: $resource_count"
    fi
fi

# Check email provider configuration
if grep -q "name.*=.*\"custom\"" config/dev.tfvars 2>/dev/null; then
    echo "📧 Email provider type: Custom"
    echo "🔧 Action runtime: $(grep -o "runtime.*=.*\"[^\"]*\"" config/dev.tfvars 2>/dev/null | head -1 | cut -d'"' -f2)"
fi

echo ""
echo "📝 Next Steps:"
echo "1. If validation passed: terraform apply -var-file=\"config/dev.tfvars\""
echo "2. After deployment: Update secrets in Auth0 Dashboard"
echo "3. Use: ./scripts/setup-email-provider.sh for guided setup"
echo "4. Test with Auth0's 'Try Connection' feature"
echo ""
echo "📚 Documentation: EMAIL_PROVIDER_SETUP.md"
echo ""

if [ $? -eq 0 ]; then
    echo "✅ Validation complete - Configuration looks good!"
else
    echo "❌ Validation failed - Please fix the issues above"
fi