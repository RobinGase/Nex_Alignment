# Use-Case Profile Override Request Template

Use this template when requesting a temporary profile-layer override. Overrides are reference-only unless promoted through formal change control.

```md
## Override ID
Use a unique identifier (for example, `OVR-2026-001`).

## Task ID
Reference the associated task identifier.

## Requestor
Name and role of the requestor.

## Primary Use-Case Profile
Declared primary profile for the task.

## Secondary Use-Case Profiles
List up to two secondary profiles, or `none`.

## Requested Override Scope
Specify exactly which profile control(s) are being overridden.

## Normative Safety Check
Confirm this override does **not** waive immutable or normative constraints.

## Rationale
Explain why the default profile requirement cannot be met in this context.

## Compensating Controls
List controls that offset risk introduced by the override.

## Risk Impact Assessment
Describe expected impact to safety, compliance, reliability, and operations.

## Approver
Name and role of the approving authority.

## Effective Date
Date/time override becomes active.

## Expiry Date
Date/time override automatically expires.

## Revocation Conditions
Describe conditions that force immediate revocation.

## Evidence References
Link to supporting artifacts, risk records, and telemetry commitments.

## Approval Decision
`approved` or `rejected` with signature metadata.
```

Minimum validity conditions:

1. Compensating controls are populated.
2. Approver is present.
3. Expiry date is present and in the future.
4. Requested scope does not include immutable controls.
