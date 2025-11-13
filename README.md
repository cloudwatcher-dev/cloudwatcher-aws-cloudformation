# Cloudwatcher AWS CloudFormation Templates

Open-source CloudFormation templates for monitoring AWS Organizations with CloudWatch alarms and automated email notifications.

## 🎯 What is Cloudwatcher?

Cloudwatcher is an AWS security monitoring solution that automatically detects and alerts on suspicious activities in your AWS Organization. It monitors CloudTrail logs for security-relevant events and sends formatted email notifications when alarms are triggered.


## 🚨 Deployed Alarms

- **Access Denied** - Failed authorization attempts
- **GetCallerIdentity** - Identity verification calls
- **AttachUserPolicy** - Policy attachment to users
- **Authenticate** - SSO authentication events
- **CreateUser** - New IAM user creation
- **DeleteUser** - IAM user deletion
- **IAMUserActivity** - General IAM user activity monitoring

## 🚀 How to Deploy

### Prerequisites

- AWS Organization with CloudTrail enabled
- **Must be deployed in the root account** of your AWS Organization
- CloudTrail logs sent to CloudWatch Log Group (by default, events flow into the `aws-controltower/CloudTrailLogs` log group)
- Email addresses for receiving alerts

### Deploy via AWS Console

#### Quick Launch (Recommended)

Click the button below to launch the stack with pre-configured parameters:

[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/quickcreate?templateURL=https%3A%2F%2Fcloudwatcher-cloudformation-prod.s3.eu-central-1.amazonaws.com%2Ftemplates%2Forganisation%2F0.1%2FRootStack.yaml&stackName=CLOUDWATCHER&param_EmailRecipient=&param_EnableCreateUserAlarm=true&param_EnableGetCallerIdentityAlarm=true&param_EnableAccessDeniedAlarm=true&param_EnableAuthenticateAlarm=true&param_EnableAttachUserPolicyAlarm=true&param_LogGroupName=aws-controltower%2FCloudTrailLogs&param_EnableDeleteUserAlarm=true&param_EnableIAMUserActivityAlarm=true)

Or use this direct link:
```
https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/quickcreate?templateURL=https%3A%2F%2Fcloudwatcher-cloudformation-prod.s3.eu-central-1.amazonaws.com%2Ftemplates%2Forganisation%2F0.1%2FRootStack.yaml&stackName=CLOUDWATCHER&param_EmailRecipient=&param_EnableCreateUserAlarm=true&param_EnableGetCallerIdentityAlarm=true&param_EnableAccessDeniedAlarm=true&param_EnableAuthenticateAlarm=true&param_EnableAttachUserPolicyAlarm=true&param_LogGroupName=aws-controltower%2FCloudTrailLogs&param_EnableDeleteUserAlarm=true&param_EnableIAMUserActivityAlarm=true
```

#### Manual Deployment

Template URL:
```
https://cloudwatcher-cloudformation-prod.s3.eu-central-1.amazonaws.com/templates/organisation/0.1/RootStack.yaml
```

### Parameters

#### Required Parameters
| Parameter | Description | Default |
|-----------|-------------|---------|
| `EmailRecipient` | Email address for notifications | Required |

#### Optional Parameters
| Parameter | Description | Default |
|-----------|-------------|---------|
| `LogGroupName` | CloudWatch Log Group name | `aws-controltower/CloudTrailLogs` |
| `EnableAccessDeniedAlarm` | Enable Access Denied alarm | `true` |
| `EnableGetCallerIdentityAlarm` | Enable GetCallerIdentity alarm | `true` |
| `EnableAttachUserPolicyAlarm` | Enable AttachUserPolicy alarm | `true` |
| `EnableAuthenticateAlarm` | Enable Authenticate alarm | `true` |
| `EnableCreateUserAlarm` | Enable CreateUser alarm | `true` |
| `EnableDeleteUserAlarm` | Enable DeleteUser alarm | `true` |
| `EnableIAMUserActivityAlarm` | Enable IAMUserActivity alarm | `true` |


## ⚙️ How does it work

### Root Stack (`RootStack.yaml`)

Main orchestration template that deploys:

1. **CloudWatch Alarms Stack** - Metric filters and alarms for security events
2. **Forwarding Lambda Stack** - Processes alarms and sends email notifications

### Architecture

```
CloudTrail Logs
    ↓
CloudWatch Log Group
    ↓
Metric Filters
    ↓
CloudWatch Alarms
    ↓
Lambda Function (Forwarding)
    ↓
SNS Topic
    ↓
Email Recipients
```

## 📧 Email Notifications

When an alarm triggers, you'll receive an email with:

```
═══════════════════════════════════════════════════════════
🚨 CloudWatch Alarm: iam:AccessDeniedAlarm
═══════════════════════════════════════════════════════════

Status:     OK → ALARM
Timestamp:  2025-10-29 22:15:30 UTC
Account:    Production Account (123456789012)

────────────────────────────────────────────────────────────
📋 CloudWatch Log Entries (3 found)
────────────────────────────────────────────────────────────

[1] 2025-10-29 22:15:28 UTC
    Event:      DeleteUser
    User:       AIDAI3EXAMPLE
    Source IP:  203.0.113.42
    Error:      AccessDenied

[2] 2025-10-29 22:15:29 UTC
    Event:      AttachUserPolicy
    User:       AIDAI3EXAMPLE
    Source IP:  203.0.113.42
    Error:      AccessDenied

────────────────────────────────────────────────────────────
Generated by Cloudwatcher
═══════════════════════════════════════════════════════════
```

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test your changes with `./tests/validate-templates.sh`
4. Submit a pull request

## 📝 License

This project is open source and available under the MIT License.

### Email Confirmation

After deployment, the email recipient will receive a confirmation email from AWS SNS. **You must confirm the subscription** to receive alerts.

**Note:** To add additional email recipients, subscribe them manually to the SNS topic `Cloudwatcher-AlarmNotifications` via the AWS SNS Console.

### Costs

This solution uses:
- AWS Lambda (minimal cost, mostly free tier eligible)
- CloudWatch Logs (depends on log volume)
- CloudWatch Alarms (first 10 alarms free, then $0.10/alarm/month)
- SNS (first 1,000 emails free, then $2/100,000 emails)

### Security

- Templates are publicly readable in S3 (required for CloudFormation)
- No sensitive data is stored in templates
- Lambda execution role has minimal required permissions
- All resources are encrypted at rest

## 📞 Support

For questions or issues:
- Open a GitHub Issue
- Check existing documentation in `/tests/README.md`
- Review CloudFormation events for deployment errors

---

**Made with ❤️ for AWS security monitoring**
