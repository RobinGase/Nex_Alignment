# Enforcement and Policy Engine

The **NexGentic Agents Protocol (NAP)** provides guidance on risk classification, requirements management, testing and safety assurance. To achieve consistent compliance in practice, organisations must implement a machine‑enforced policy engine that gates agent actions, verifies artefacts and automates approvals. NASA’s experience shows that formal policies are ineffective if not enforced; humans may bypass process under pressure. This document proposes an enforcement architecture for NAP.

## Goals of enforcement

1. **Prevent unauthorised actions.** Ensure that agents cannot execute tasks beyond their assigned risk class or autonomy tier without appropriate approvals.
2. **Verify evidence and artefacts.** Automatically check that required documents (e.g., task headers, hazard logs, test reports, risk acceptance forms) are complete, signed and traceable.
3. **Automate compliance.** Integrate enforcement into the development and operational workflows via CI/CD pipelines, approval gates and runtime controls.
4. **Provide audit trails.** Record enforcement decisions and evidence for later review, anchored by cryptographic signatures (`safety/evidence_anchor_and_log_integrity.md`).

## Policy engine components

1. **State machine orchestrator.** Implements the NAP state machine (e.g., INIT → PLAN → READ → CHANGE → VERIFY → REVIEW → RELEASE). Transitions between states are only allowed when all required artefacts are present and verified.
2. **Policy definitions.** A set of machine‑readable rules mapping risk classes and autonomy tiers to required artefacts, approvals and constraints. Policies are versioned and controlled via configuration management. **Policy definitions are treated as code:** they must include accompanying **test suites** to validate that rules behave as intended, **compatibility checks** to ensure new policies do not conflict with existing ones and a **rollback mechanism** to revert to a previous policy version when a new policy introduces errors. Apply change control and peer review to policy updates just as you would for source code.
3. **Evidence validator.** Automatically checks traceability matrices (`core/traceability_and_documentation.md`), hazard logs, test reports, signatures (`safety/evidence_anchor_and_log_integrity.md`) and residual risk acceptance forms (`safety/risk_acceptance_and_residuals.md`). Fails the task if evidence is missing or invalid.
4. **Gatekeeper service.** Integrates with CI/CD, deployment systems and runtime environments. It prevents actions (e.g., merging code, deploying models, executing high‑risk operations) until the policy engine confirms compliance. For A2 tasks, it can automatically queue actions for human approval.
5. **Monitoring and alerts.** Logs policy decisions and sends alerts on policy violations, expired risk acceptances or missing approvals. Each escalation or violation must produce a **structured incident artefact** that captures the context (task ID, artefacts involved, risk class, autonomy tier, violated rule, timestamps) and the decision taken. Incident artefacts are immutable records used for root‑cause analysis and audit. Integrate alerts and incident artefacts with operations monitoring for real‑time enforcement feedback.
6. **Audit interface.** Provides auditors and assurance personnel with access to policy engine logs, decisions and evidence. Supports search by traceability IDs and risk class. Ensures that logs are anchored with cryptographic signatures.

## Resilience and fail‑safe operation

Just as hazard controls must include multiple independent controls for critical hazards, the policy engine itself must be resilient to failures, attacks or unexpected conditions. If enforcement fails, unvetted changes could propagate to mission‑critical systems. To ensure reliability:

1. **Distributed enforcement.** Run multiple instances of the policy engine in different failure domains (e.g., separate servers or containers). Use consensus protocols to agree on enforcement decisions. If one instance fails, another continues without losing state.
2. **Fallback modes.** Define safe default actions when the policy engine is unreachable. For example, block high‑risk tasks (Class 3–4) and allow only low‑risk tasks (Class 0–1) to proceed under an approved emergency plan. Document fallback behaviour and test it regularly.
3. **Self‑integrity checks.** Periodically verify the integrity of policy definitions and rule files using digital signatures (`safety/evidence_anchor_and_log_integrity.md`). Audit the engine’s own logs for anomalies and apply fail‑closed principles when tampering is suspected.
4. **Heartbeat and monitoring.** Expose health endpoints and metrics for the policy engine. Operations teams should monitor latency, error rates and decision consistency. Trigger alerts and automatic switchover when anomalies occur.
5. **Graceful degradation.** When enforcement cannot complete all checks (e.g., trace graph service unavailable), the engine should degrade gracefully by tightening restrictions rather than loosening them. For example, require manual approval for tasks that normally would be auto‑approved.

Building resilience into the policy engine ensures that enforcement remains reliable even under adverse conditions, aligning with NASA’s emphasis on redundancy and independent controls.

## Policy conflict resolution

The policy engine often must reconcile rules originating from different sources—organisational policy, NAP safety and assurance requirements, and external regulations. To prevent ambiguous or conflicting enforcement:

1. **Regulatory requirements dominate.** If a regulatory rule (e.g., mandated by law, industry standard or governmental directive) conflicts with NAP or organisational policy, the regulatory requirement must prevail. Regulatory non‑compliance triggers immediate blocking and escalation.
2. **Safety requirements override organisational policy.** If an organisational policy conflicts with a NAP safety requirement (e.g., requesting a lower risk class or skipping an artefact), the safety requirement prevails. The policy engine should either raise the request to the higher standard or block the action.
3. **Merge non‑conflicting rules.** When policies are complementary, the policy engine enforces the union of requirements. For example, if regulatory policy requires encryption and NAP requires provenance logging, both must be satisfied.
4. **Conflict detection and reporting.** Policy definitions must include metadata about their source and precedence. If the policy engine detects an unresolved conflict, it should block the action and generate a structured incident artefact describing the conflict for resolution by governance authorities.

By codifying precedence rules, NAP ensures that safety and legality are never compromised by lower‑priority policies.

## Enforcement workflow

1. **Policy mapping.** When a new task is created, the policy engine reads the task header and maps the risk class and autonomy tier to required artefacts and approvals.
2. **Evidence collection.** As the task progresses, developers upload artefacts to the configuration management system. The evidence validator extracts metadata (IDs, signatures) and updates the trace graph.
3. **Gate checks.** Before transitioning to the next state (e.g., from VERIFY to REVIEW or from REVIEW to RELEASE), the state machine orchestrator requests a policy check. The evidence validator confirms that all required artefacts are present and signed. If any requirement is unmet, it blocks the transition and provides feedback.
4. **Human approvals.** For tasks requiring human approval (e.g., A2 tasks or residual risk acceptance), the gatekeeper service notifies the appropriate approver. The approver reviews evidence via the audit interface and signs digitally. The policy engine records the signature and allows the state transition.
5. **Runtime controls.** For high‑autonomy agents (A3–A4), the gatekeeper service integrates with runtime environments to enforce boundaries and kill‑switches. If the agent attempts an action outside approved parameters—or if a user instruction or tool call would cause a policy violation—the policy engine must override or halt the action and alert operators. User instructions do not supersede safety policies; the engine has ultimate authority to block unsafe behaviour.
6. **Continuous enforcement.** The policy engine runs checks on a schedule or triggered by events (e.g., new commits, model deployments). It tracks expiry of risk acceptance forms and prompts re‑approval when necessary.

## Escalation routing and fallback

Escalations occur when a policy decision cannot be made automatically—either because a required artefact is missing, a conflict exists among policies, or a human approval is required. To prevent indefinite blocking and ensure safe defaults, NAP mandates deterministic routing and timeouts:

1. **Role‑based routing.** Each escalation must identify a primary approver (e.g., project manager, safety officer) and a secondary approver in case the primary approver is unavailable. The policy engine references a routing table in configuration management to determine the escalation path.
2. **Maximum decision latency.** Define a maximum time window for escalation resolution (e.g., 48 hours for Class 2 tasks, 24 hours for Class 3–4). The window may be shorter for tasks with high autonomy tiers. Record the start time of the escalation in the incident artefact.
3. **Automatic fallback outcome.** If the escalation is not resolved within the maximum latency, the policy engine MUST apply the most conservative outcome for the affected task or release:
 * **Block** the action for high‑risk tasks (Class 3–4) or high autonomy (A3–A4).
 * **Pause and requeue** the action for moderate‑risk tasks (Class 2) pending further review.
 * **Auto‑reject** the action if it violates a non‑negotiable safety policy (e.g., missing hazard controls, expired residual risks).
 The fallback decision is logged in the incident artefact and communicated to stakeholders. Subsequent overrides require explicit approval and justification.
4. **Escalation notification.** Send notifications to designated approvers via email, chat or ticketing systems. Reminders should be sent prior to expiration and recorded in the audit log.
5. **Override logging.** If an approver overrides the automatic fallback, the decision and rationale must be recorded in the residual risk acceptance form or incident artefact. Overrides should trigger a governance board review if they deviate from standard policies.

By defining escalation routing, decision deadlines and safe fallback outcomes, NAP ensures that unresolved escalations cannot leave the system in an indeterminate state or allow unvetted actions to proceed. This deterministic approach aligns with high‑assurance safety culture where the absence of approval defaults to a safe state.

## Compliance runtime specification

While this document provides high‑level guidance, practical implementations need a **deterministic enforcement contract**. See `runtime/compliance_runtime_spec.md` for a formal runtime specification that defines state transitions, required artefacts per state, machine‑checkable validation rules, policy engine request/response schemas and failure escalation logic. Policy engines should adhere to that specification to ensure consistent, auditable behaviour.

## Linking to other sections

* **Risk classification and autonomy:** The policy engine uses risk class (`core/risk_classification.md`) and autonomy tier (`core/agent_autonomy_and_human_oversight.md`) to determine required artefacts and approvals.
* **Traceability:** The evidence validator relies on the traceability schema (`core/traceability_and_documentation.md`) to verify that requirements, design, code and tests are linked.
* **Risk acceptance:** Residual risk acceptances are enforced by requiring signed forms (`safety/risk_acceptance_and_residuals.md`) before releasing high‑risk tasks.
* **Supply chain and model security:** Enforcement includes verifying dataset and model signatures (`safety/model_and_data_supply_chain_security.md`) and ensuring that only approved versions are deployed.
* **Evidence anchoring:** The policy engine anchors its own logs and decisions using signatures and hash chains (`safety/evidence_anchor_and_log_integrity.md`).
* **Compliance telemetry:** Enforcement events, policy violations and approval latencies feed into the metrics described in `runtime/compliance_telemetry_and_governance_drift.md`. Monitoring these metrics helps detect governance drift and measure protocol health.
* **Runtime behavioural contracts:** The policy engine enforces runtime behavioural contracts (`safety/runtime_behavioral_contracts.md`) by integrating contract monitors and halting agents when contract invariants are violated.
* **Automation and scalability:** For guidance on implementing the policy engine using CI pipelines and automation tools, see `core/automation_and_scalability.md`.

* **Enforcement architecture:** For practical implementation patterns, CI/CD integration, risk classification services and runtime watchdogs, see `runtime/enforcement_architecture_and_implementation.md`.

By adding an enforcement and policy engine, NAP moves beyond documentation into active compliance. Automated gates, machine‑readable policies and cryptographic evidence prevent shortcuts, ensure consistency and provide a durable foundation for trust in AI agent systems.



