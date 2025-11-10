terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "thing_name" {
  type        = string
  description = "Name of the IoT thing to provision."
}

variable "policy_name" {
  type        = string
  description = "Name for the IoT policy with least-privilege MQTT access."
}

variable "allowed_topics" {
  type        = list(string)
  description = "List of MQTT topics the device may publish/subscribe to."
}

resource "aws_iot_thing" "device" {
  name = var.thing_name
}

# Create a minimal policy allowing only specific publish/subscribe topics
resource "aws_iot_policy" "device_policy" {
  name   = var.policy_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["iot:Connect"]
        Resource = "arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:client/${var.thing_name}"
      },
      {
        Effect = "Allow"
        Action = ["iot:Publish", "iot:Subscribe", "iot:Receive"]
        Resource = [for topic in var.allowed_topics : "arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/${topic}"]
      }
    ]
  })
}

# Create a certificate and private key that Terraform stores in state; prefer
# issuing through AWS IoT Fleet Provisioning or AWS Private CA for production.
resource "aws_iot_certificate" "device_cert" {
  active = true
}

resource "aws_iot_thing_principal_attachment" "device_attach" {
  thing     = aws_iot_thing.device.name
  principal = aws_iot_certificate.device_cert.arn
}

resource "aws_iot_policy_attachment" "device_policy_attach" {
  policy = aws_iot_policy.device_policy.name
  target = aws_iot_certificate.device_cert.arn
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

output "certificate_pem" {
  value       = aws_iot_certificate.device_cert.certificate_pem
  description = "X.509 certificate for the device. Store securely and rotate regularly."
  sensitive   = true
}

output "private_key" {
  value       = aws_iot_certificate.device_cert.private_key
  description = "Private key corresponding to the certificate. Protect with HSM or secrets manager."
  sensitive   = true
}

output "certificate_arn" {
  value       = aws_iot_certificate.device_cert.arn
  description = "ARN of the active certificate."
}

