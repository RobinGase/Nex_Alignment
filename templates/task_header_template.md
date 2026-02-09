# Task Header Template

Use this template at the start of every agent task to capture essential information. Completing the header improves deterministic policy evaluation, traceability, and review quality.

```md
## Task Name
Provide a short descriptive name.

## Primary Use-Case Profile
Declare one profile from `profiles/use_case_profiles.yaml`.

## Secondary Use-Case Profiles
Declare zero to two additional profiles, or `none`.

## Operation Tags
List operation tags (for example: `frontend`, `database_schema`, `currency_transfer`, `model_training`).

## Profile Justification
Explain why selected profile(s) match the intended work.

## Profile Override References
List applicable override IDs from `templates/use_case_override_request_template.md`, or `none`.

## Risk Class
Specify the risk class (0-4) according to `core/risk_classification.md`.

## Autonomy Tier
Specify the autonomy tier (`A0`-`A4`) according to `core/agent_autonomy_and_human_oversight.md`.

## Goal
Describe the objective of the task in one or two sentences. Include the problem you are solving and the desired outcome.

## Context and Stakeholders
List stakeholders and describe the context (system environment, user roles, external systems). Capture assumptions about the operational environment, resources, and constraints.

## Requirements
List functional and non-functional requirements derived from stakeholder needs and hazard controls (`core/requirements_management.md`). Each requirement should have a unique identifier.

## Dataset and Model Information
If the task involves training, fine-tuning, or deploying an AI model, specify:

- **Datasets used:** Names, version identifiers, provenance, and bias notes.
- **Model version:** Architecture and version identifier.
- **Evaluation datasets:** Datasets used for testing, drift monitoring, and alignment checks.

## Hazard Analysis Summary
For Class 3-4 tasks, summarize identified hazards, severity, and planned controls (`safety/safety_and_assurance.md`). Reference hazard log entries.

## Plan and Algorithm
Outline the approach the agent will take to accomplish the task. Include high-level algorithms or step-by-step procedures. Reference architecture and modules involved (`core/architecture_design.md`).

## Acceptance Criteria
Define measurable criteria that determine completion and acceptance. These criteria are used for testing and review.

## Review and Approval
Record who will perform verification and approval (builder, verifier, approver) and scheduled review dates (`safety/testing_and_verification.md`).

## Additional Notes
Include related tasks, known issues, or relevant documentation.
```

Profile selection guidance:

1. Profile declaration is mandatory for Class 2-4 tasks.
2. Profile declaration is strongly recommended for Class 0-1 tasks.
3. Composite profile selection uses `highest-safety-wins`.

Update this header whenever requirements, hazards, assumptions, or profile selections change.

