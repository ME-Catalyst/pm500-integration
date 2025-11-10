#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Script: register_thing.sh
# Summary: Automates creation of a PM500 IoT Thing, certificates, and a
#          least-privilege MQTT policy using the AWS CLI.
# Usage:   Run `THING_NAME=<name> POLICY_NAME=<name> ./register_thing.sh`
#          to create artifacts in ./certs (override via OUTPUT_DIR).
# Depends: awscli v2, jq, and credentials permitted to call IoT APIs including
#          CreateThing, CreateKeysAndCertificate, CreatePolicy, AttachPolicy,
#          AttachThingPrincipal, and DescribeEndpoint.
# -----------------------------------------------------------------------------

THING_NAME=${THING_NAME:-pm500-demo-thing}
POLICY_NAME=${POLICY_NAME:-pm500-demo-policy}
ALLOWED_TOPICS=${ALLOWED_TOPICS:-"pm500/${THING_NAME}/commands pm500/${THING_NAME}/telemetry"}
OUTPUT_DIR=${OUTPUT_DIR:-certs}

mkdir -p "${OUTPUT_DIR}"

# Create (or ensure existence of) the IoT thing
aws iot create-thing --thing-name "${THING_NAME}" >/dev/null || echo "Thing ${THING_NAME} already exists"

# Create certificate and keys; output files are named after the thing
CERT_JSON=$(aws iot create-keys-and-certificate --set-as-active)

echo "${CERT_JSON}" | jq -r '.certificatePem' > "${OUTPUT_DIR}/${THING_NAME}-certificate.pem"
echo "${CERT_JSON}" | jq -r '.keyPair.PrivateKey' > "${OUTPUT_DIR}/${THING_NAME}-private.key"
echo "${CERT_JSON}" | jq -r '.keyPair.PublicKey' > "${OUTPUT_DIR}/${THING_NAME}-public.key"
echo "${CERT_JSON}" | jq -r '.certificateArn' > "${OUTPUT_DIR}/${THING_NAME}-certificate.arn"

chmod 600 "${OUTPUT_DIR}/${THING_NAME}-private.key"

# Create a least-privilege policy if it does not exist
cat > "${OUTPUT_DIR}/${POLICY_NAME}.json" <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["iot:Connect"],
      "Resource": "arn:aws:iot:$(aws configure get region):$(aws sts get-caller-identity --query Account --output text):client/${THING_NAME}"
    },
    {
      "Effect": "Allow",
      "Action": ["iot:Publish", "iot:Subscribe", "iot:Receive"],
      "Resource": [
$(for topic in ${ALLOWED_TOPICS}; do echo "        \"arn:aws:iot:$(aws configure get region):$(aws sts get-caller-identity --query Account --output text):topic/${topic}\","; done)
      ]
    }
  ]
}
POLICY

aws iot create-policy \
  --policy-name "${POLICY_NAME}" \
  --policy-document "file://${OUTPUT_DIR}/${POLICY_NAME}.json" >/dev/null || echo "Policy ${POLICY_NAME} already exists"

CERT_ARN=$(cat "${OUTPUT_DIR}/${THING_NAME}-certificate.arn")

aws iot attach-policy --policy-name "${POLICY_NAME}" --target "${CERT_ARN}"
aws iot attach-thing-principal --thing-name "${THING_NAME}" --principal "${CERT_ARN}"

ENDPOINT=$(aws iot describe-endpoint --endpoint-type iot:Data-ATS --query endpointAddress --output text)

cat <<SUMMARY
Provisioning complete.
  Thing Name: ${THING_NAME}
  Policy Name: ${POLICY_NAME}
  Certificate Files: ${OUTPUT_DIR}/${THING_NAME}-certificate.pem, ${OUTPUT_DIR}/${THING_NAME}-private.key
  IoT Data ATS Endpoint: ${ENDPOINT}

Store the private key securely, enforce rotation, and disable the certificate if compromised.
SUMMARY

