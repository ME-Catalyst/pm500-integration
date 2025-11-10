# PM500 Integration Style Guidelines

These conventions ensure configuration and automation assets carry the same
documentation quality introduced in this update. Apply them whenever adding or
modifying files in this repository.

## Global expectations

- **Header blocks** – Every runnable script, infrastructure definition, or sample
  configuration must begin with a short header describing the file name,
  summary, usage, and dependencies. Use the comment syntax of the target
  language (e.g., `#` for YAML and shell, `//` for JavaScript).
- **Update scope** – When editing a file, review the header to keep it accurate
  (inputs, outputs, dependencies).
- **Secrets** – Mark placeholder credentials as such and remind contributors to
  replace them with secure values before production use.

## YAML (CloudFormation, Docker Compose, etc.)

- Start files with a `# -----` delimited block that includes:
  - `File:` the relative path or descriptive name.
  - `Summary:` what the configuration provisions.
  - `Usage:` the primary command(s) or workflow.
  - `Depends:` external services, CLI tools, or providers required.
- Inline comments should clarify non-obvious defaults, parameter meanings, or
  integration points with other services.

## JSON (Node-RED flows, samples)

- JSON does not support comments. Use descriptive metadata fields instead:
  - For Node-RED flows, populate the tab's `info` property with usage and
    dependencies, and add dedicated `comment` nodes where appropriate.
  - For sample payloads, add a `_documentation` or similar field when extra
    context is required (ensure consuming code ignores it).
- Function node `func` bodies should contain JavaScript comments that explain
  inputs, outputs, and transformation logic.

## JavaScript (Node-RED function nodes, supporting scripts)

- Begin scripts with the standard header block using `//` comments.
- Inside functions that transform or parse device data, prefer block comments
  (`/* ... */`) or single-line `//` notes to explain protocol-specific offsets
  and expected message shapes.
- Document any external modules (`require`) or Node-RED libraries in the header
  before using them.

By following these guidelines, contributors can quickly understand how to run a
workflow, what dependencies they must satisfy, and how changes affect related
systems.
