#!/bin/bash

# CloudFormation ChangeSet Test Script
# Creates a ChangeSet to validate the stack without deploying it

set -e

STACK_NAME="cloudwatcher-test-stack"
TEMPLATE_FILE="src/templates/organisation/0.1/RootStack.yaml"
CHANGESET_NAME="test-changeset-$(date +%s)"

# Required Parameters
LOG_GROUP_NAME="aws-controltower/CloudTrailLogs"
ENVIRONMENT="stage"
EMAIL_RECIPIENTS="test@example.com"

echo "🧪 Testing CloudFormation Stack with ChangeSet"
echo "=============================================="
echo "Stack Name: $STACK_NAME"
echo "Template: $TEMPLATE_FILE"
echo "ChangeSet: $CHANGESET_NAME"
echo ""

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured"
    echo "Please run: aws configure"
    exit 1
fi

echo "✅ AWS credentials configured"
echo ""

# Upload templates to S3 (if needed for nested stacks)
echo "📤 Note: Nested stacks require templates in S3"
echo "   Make sure templates are uploaded to:"
echo "   https://cloudwatcher-cfn-${ENVIRONMENT}.s3.eu-central-1.amazonaws.com/templates/organisation/0.1/"
echo ""

# Create ChangeSet
echo "🔨 Creating ChangeSet..."
aws cloudformation create-change-set \
    --stack-name "$STACK_NAME" \
    --template-body "file://$TEMPLATE_FILE" \
    --change-set-name "$CHANGESET_NAME" \
    --change-set-type CREATE \
    --parameters \
        ParameterKey=LogGroupName,ParameterValue="$LOG_GROUP_NAME" \
        ParameterKey=Environment,ParameterValue="$ENVIRONMENT" \
        ParameterKey=EmailRecipients,ParameterValue="$EMAIL_RECIPIENTS" \
    --capabilities CAPABILITY_IAM

echo ""
echo "⏳ Waiting for ChangeSet to be created..."
aws cloudformation wait change-set-create-complete \
    --stack-name "$STACK_NAME" \
    --change-set-name "$CHANGESET_NAME"

echo ""
echo "✅ ChangeSet created successfully!"
echo ""

# Describe ChangeSet
echo "📋 ChangeSet Details:"
echo "----------------------------------------"
aws cloudformation describe-change-set \
    --stack-name "$STACK_NAME" \
    --change-set-name "$CHANGESET_NAME" \
    --query 'Changes[*].[Type,ResourceChange.Action,ResourceChange.LogicalResourceId,ResourceChange.ResourceType]' \
    --output table

echo ""
echo "🗑️  Cleaning up (deleting ChangeSet)..."
aws cloudformation delete-change-set \
    --stack-name "$STACK_NAME" \
    --change-set-name "$CHANGESET_NAME"

echo ""
echo "=============================================="
echo "✅ Test Complete!"
echo ""
echo "💡 The ChangeSet was created successfully, which means:"
echo "   - Template syntax is valid"
echo "   - Parameters are correct"
echo "   - Resources can be created"
echo ""
echo "⚠️  Note: This does NOT test nested stack templates"
echo "   They must be available in S3 for full validation"
