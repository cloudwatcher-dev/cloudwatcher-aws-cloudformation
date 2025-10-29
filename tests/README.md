# CloudFormation Stack Testing Guide

## Overview

This document describes how to test the RootStack and substacks.

## Prerequisites

```bash
# Install AWS CLI (if not already installed)
brew install awscli

# Configure AWS credentials
aws configure

# Install testing tools
pip install cfn-lint yamllint taskcat
```

## Test Methods

### 1. Syntax Validation with cfn-lint (Recommended for local tests)

**Fast, local, no AWS connection required**

```bash
./tests/validate-templates.sh
```

What is tested:
- ✅ YAML syntax
- ✅ CloudFormation syntax
- ✅ Parameter definitions
- ✅ Resource types
- ✅ Best practices

### 2. ChangeSet Test (Recommended for integration)

**Tests stack creation without actual deployment**

```bash
./tests/test-changeset.sh
```

What is tested:
- ✅ Template is deployable
- ✅ Parameters are correct
- ✅ IAM permissions are sufficient
- ✅ Resources can be created
- ⚠️ Nested stacks must be available in S3

**Important:** Before testing, substack templates must be uploaded to S3:

```bash
# For stage environment
aws s3 sync src/templates/organisation/0.1/ \
  s3://cloudwatcher-cfn-stage/templates/organisation/0.1/ \
  --exclude "*.sh"

# For prod environment
aws s3 sync src/templates/organisation/0.1/ \
  s3://cloudwatcher-cfn-prod/templates/organisation/0.1/ \
  --exclude "*.sh"
```

### 3. TaskCat (Full integration test)

**Creates actual stacks in AWS and deletes them afterwards**

```bash
# Install TaskCat
pip install taskcat

# Run test
taskcat test run

# Show test results
taskcat test list
```

What is tested:
- ✅ Complete stack creation
- ✅ All nested stacks
- ✅ Resource dependencies
- ✅ Outputs
- ✅ Automatic cleanup

### 4. Manual Validation

```bash
# Validate single template
aws cloudformation validate-template \
  --template-body file://src/templates/organisation/0.1/RootStack.yaml

# Validate all templates
for template in src/templates/organisation/0.1/*.yaml; do
  echo "Validating: $template"
  aws cloudformation validate-template --template-body "file://$template"
done
```

## Create Test Stack (without affecting production)

```bash
# Create stack with test parameters
aws cloudformation create-stack \
  --stack-name cloudwatcher-test \
  --template-body file://src/templates/organisation/0.1/RootStack.yaml \
  --parameters \
    ParameterKey=LogGroupName,ParameterValue=test-log-group \
    ParameterKey=Environment,ParameterValue=stage \
    ParameterKey=EmailRecipients,ParameterValue=test@example.com \
  --capabilities CAPABILITY_IAM

# Monitor stack status
aws cloudformation wait stack-create-complete \
  --stack-name cloudwatcher-test

# Delete stack after test
aws cloudformation delete-stack \
  --stack-name cloudwatcher-test
```

## Common Issues

### Issue: "Template format error: YAML not well-formed"
**Solution:** Check YAML syntax with `yamllint`

### Issue: "Nested stack templates not found in S3"
**Solution:** Upload templates to S3 (see above)

### Issue: "Invalid security token"
**Solution:** Configure AWS credentials with `aws configure`

### Issue: "Parameter validation failed"
**Solution:** Check all required parameters:
- LogGroupName
- Environment
- EmailRecipients

## CI/CD Integration

The GitHub Actions pipeline (`.github/workflows/stage.yml`) includes:

1. **Syntax Validation** - Validates templates with cfn-lint before deployment
2. **Deploy Infrastructure** - Deploys the S3 bucket infrastructure
3. **Upload Templates** - Syncs CloudFormation templates to S3
4. **Integration Test** - Creates a ChangeSet to validate the complete stack (including nested stacks)

This ensures that:
- Templates are syntactically correct before deployment
- Nested stack templates are available in S3 before testing
- The complete stack can be deployed without errors

## Recommended Workflow

1. **Local development:** Make changes to templates
2. **Syntax check:** Run `./tests/validate-templates.sh`
3. **S3 upload:** Upload templates to S3
4. **Integration test:** Run `./tests/test-changeset.sh`
5. **Deployment:** Create/update stack in AWS

## Additional Resources

- [AWS CloudFormation Best Practices](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/best-practices.html)
- [cfn-lint Documentation](https://github.com/aws-cloudformation/cfn-lint)
- [TaskCat Documentation](https://github.com/aws-ia/taskcat)
