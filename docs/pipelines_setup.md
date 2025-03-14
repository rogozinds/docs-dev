# Configuraiton of GITLAB running in ECS

1. check tofu/ecs_runner.tofu for configuration
Steps:

2. Runner configuraiton is setup like this part of tofu
```
```

3. add the following to your gitlab.yaml



NOTES:
- Normally, AWS IAM controls access to AWS resources (like S3, DynamoDB, ECR, etc.), but IAM itself does not natively understand Kubernetes identities (ServiceAccounts).
That's where OIDC (OpenID Connect) from EKS comes in.
