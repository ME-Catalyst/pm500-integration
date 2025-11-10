# AWS IoT Provisioning Snippets

This folder contains example infrastructure-as-code snippets and AWS CLI scripts for provisioning AWS IoT Core resources used by the PM500 integration lab. They are intentionally scoped for **least privilege** and assume you will tailor resource names, regions, and certificate handling to your deployment.

## Contents

| File | Description |
| --- | --- |
| `terraform-iot-core.tf` | Terraform snippet that provisions an IoT Thing, certificate, and scoped policy. |
| `cloudformation-iot-core.yaml` | CloudFormation template demonstrating the same resources. |
| `register_thing.sh` | AWS CLI script that registers a thing, creates a certificate, and attaches the policy. |
| `client-guides.md` | TLS setup guidance plus Node-RED and CODESYS topic conventions. |

> **Security note:** Rotate certificates frequently, store private keys in a secure secret manager or hardware security module (HSM), and restrict IAM permissions on provisioning automation to the minimum needed (IoT:CreateThing, IoT:CreatePolicy, IoT:AttachPolicy, IoT:AttachThingPrincipal, and certificate operations).

