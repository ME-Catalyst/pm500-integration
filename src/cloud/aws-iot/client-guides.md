# AWS IoT Client Integration Notes

These guidelines help Node-RED and CODESYS clients connect to AWS IoT Core using Transport Layer Security (TLS) with least-privilege policies and disciplined certificate management.

## TLS Setup Checklist

1. **Download the Amazon Root CA** for your region (e.g., `AmazonRootCA1.pem`) from the [official AWS trust store](https://www.amazontrust.com/repository/).
2. **Provision a device certificate** using the Terraform, CloudFormation, or CLI snippets in this directory. Store the private key in a hardware security module (HSM) or encrypted secrets manager.
3. **Rotate certificates** regularly and disable/revoke old certificates via `UpdateCertificate` or `DeleteCertificate` when retired.
4. **Enforce least privilege** by limiting policies to specific client IDs (`iot:Connect`) and explicit topic ARNs for publish/subscribe permissions.
5. **Deploy certificates securely** to clients: use encrypted configuration bundles, OS key stores, or HSMs. Never check certificates into source control.
6. **Verify TLS configuration** by testing MQTT connections with `aws iot describe-endpoint` to obtain the ATS endpoint (port 8883) and validating that the client certificate common name (CN) matches the intended thing name.

## Node-RED Client

- Use the **MQTT in/out** nodes with `Use TLS` enabled.
- Provide the following files in the TLS configuration:
  - CA Certificate: `AmazonRootCA1.pem`
  - Client Certificate: `<thing-name>-certificate.pem`
  - Private Key: `<thing-name>-private.key`
- Set the **server** to `<endpoint>.amazonaws.com` (from `describe-endpoint`) on port `8883`.
- Client ID should match the IoT Thing name to align with the restrictive `iot:Connect` policy.
- Recommended topic structure:
  - Publish telemetry: `pm500/<thing-name>/telemetry`
  - Subscribe for commands: `pm500/<thing-name>/commands`
- Enable persistent sessions only if required; otherwise, disable to minimize retained state.
- Monitor the Node-RED logs for TLS renegotiation errors and immediately rotate certificates if suspicious activity occurs.

## CODESYS Client

- Install the AWS Root CA and device certificate into the **CODESYS TLS configuration** (e.g., using the CODESYS Certificate Manager).
- Configure the MQTT client library (e.g., `CmpMQTT`) to use TLS with mutual authentication:
  - Endpoint: `<endpoint>.amazonaws.com`
  - Port: `8883`
  - Client ID: `<thing-name>`
  - Certificate Chain: Root CA + device certificate + private key
- Topic conventions align with Node-RED for interoperability:
  - Publish control state: `pm500/<thing-name>/status`
  - Subscribe for control commands: `pm500/<thing-name>/commands`
- Ensure the device user running the runtime has file-system access only to the certificate store directory and that backups are encrypted.
- Use **offline certificate rotation**: preload new certificates, switch references during maintenance, and immediately deactivate superseded certificates in AWS IoT.

## Operational Hardening

- Maintain an inventory of issued certificates, creation timestamps, and rotation schedules.
- Automate **certificate health checks** using AWS IoT Device Defender or custom Lambda audits to find inactive or over-privileged policies.
- Enforce IAM least privilege for operators: separate roles for provisioning vs. runtime operations.
- Log every provisioning action via CloudTrail and review for anomalies.
- Test connectivity after certificate rotation from both Node-RED and CODESYS clients using test topics in a non-production account before promoting to production.

