# Telemetry Event Schema for Compliance and Drift Monitoring

To enable machine‑verifiable compliance telemetry and governance drift detection, the **NexGentic Agents Protocol (NAP)** defines a standard **telemetry event schema**. This schema specifies the structure and fields of events emitted by policy engines, runtime monitors, guardian agents and drift detectors. A consistent schema allows automated aggregation, analysis and alerting across organisations and federated environments.

## Event structure

Each telemetry event is a JSON object with the following top‑level fields:

| Field | Type | Description |
|---|---|---|
| `event_id` | string | Unique identifier for the event (UUID). |
| `timestamp` | string (ISO 8601) | The time the event occurred, in UTC. |
| `schema_version` | string | Version of the telemetry schema (e.g., `1.0.0`). Increment the version when adding fields or changing semantics. See **schema versioning** below for guidance. |
| `source` | string | Component emitting the event (e.g., `policy_engine`, `guardian_agent`, `drift_detector`). |
| `context` | object | Key–value pairs providing contextual information (e.g., task ID, agent ID, risk class, autonomy tier). |
| `event_type` | string | Classification of the event (see below). |
| `severity` | string | Severity level (`info`, `warning`, `error`, `critical`). |
| `description` | string | Human‑readable description of the event. |
| `metrics` | object (optional) | Numeric metrics associated with the event (e.g., confidence interval width, variance, latency). |
| `evidence_ids` | array of strings (optional) | IDs of evidence artefacts in the assurance graph related to this event (e.g., test reports, monitors). |
| `signature` | string (optional) | Digital signature of the event payload for tamper‑evidence. Signatures are generated using the component’s private key and verified against trusted certificates. |

### Event types

Define a controlled vocabulary of event types to facilitate automated filtering and alerting. Examples include:

* `policy_violation` – The policy engine blocked an action due to missing or invalid artefacts.
* `approval_required` – A gate requires human approval for a task to proceed.
* `risk_acceptance_expiry` – A residual risk acceptance has expired and re‑approval is needed.
* `runtime_violation` – A guardian agent detected a behavioural contract violation.
* `variance_threshold_exceeded` – A drift detector observed behavioural variance beyond acceptable bounds.
* `drift_detected` – Data, model or concept drift has been detected, triggering evaluation and potential re‑training.
* `security_alert` – A supply chain or security incident was detected (e.g., model signature mismatch, dataset tampering).
* `telemetry_health` – Periodic health metrics from a component (e.g., policy evaluation latency, coverage metrics). Use these events to compute governance health scores (`runtime/compliance_telemetry_and_governance_drift.md`).

### Event categories

For scoring and dashboarding, events are grouped into categories defined in `runtime/compliance_scoring_and_metrics.md`: governance events, runtime events, drift/variance events, security events, health events and economic events. Categorising events simplifies filtering and scoring.

## Usage guidelines

1. **Emission by all components.** All enforcement, monitoring and analytics components MUST emit telemetry events conforming to this schema. Components should sign events to allow verification by other parties. Aggregate events in a central telemetry pipeline for analysis and alerting.

2. **Schema versioning and backward compatibility.** Event producers MUST include the `schema_version` field and increment it when the event structure changes. When introducing new fields, mark them as optional and avoid removing existing fields to preserve backward compatibility. Consumers SHOULD support at least two schema versions concurrently to allow smooth migration. Schema changes require review and approval by the governance board.
3. **Correlation with assurance graph.** Use the `context` and `evidence_ids` fields to link events to the canonical assurance graph (`core/trace_graph_schema.md`, `evaluation/ultra_tier_enhancement_blueprint.md`). This enables auditors to trace events back to requirements, hazards and controls.
4. **Drift and variance monitoring.** Drift detectors and variance monitors should emit events when statistical thresholds are exceeded. Include relevant metrics (e.g., PSI, KL divergence, variance) to support probabilistic release decisions and automatic rollback triggers. Document the chosen statistical methods and thresholds so that auditors understand the basis for alerts and can evaluate their adequacy.
5. **Health scoring.** Use `telemetry_health` events to compute governance health metrics (e.g., policy violation rate, evidence anchoring coverage, residual risk acceptance rate) as described in `runtime/compliance_telemetry_and_governance_drift.md`.

## Linking to other sections

* **Compliance telemetry:** The metrics and monitoring techniques defined in `runtime/compliance_telemetry_and_governance_drift.md` rely on events emitted using this schema.
* **Enforcement and policy engine:** Policy decisions and enforcement actions should generate telemetry events to document gating, approvals and violations (`runtime/enforcement_and_policy_engine.md`).
* **Probabilistic assurance:** Variance and confidence interval monitoring events support probabilistic release gating (`evaluation/probabilistic_assurance_and_release_metrics.md`).
* **Multi‑agent risk:** Guardians and drift detectors should emit events describing emergent behaviours and self‑modification incidents (`evaluation/multi_agent_and_emergent_risk.md`).
* **Evidence anchoring:** Sign events and link them to evidence IDs as defined in `safety/evidence_anchor_and_log_integrity.md` to ensure tamper‑proof logging.

By standardising telemetry events, NAP enables automated compliance monitoring, cross‑component correlation and federated evidence sharing. Telemetry is a cornerstone of self‑auditing governance and adaptive safety intelligence.



