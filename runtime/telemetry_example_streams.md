# Example Telemetry Event Streams

To demonstrate the **compliance telemetry and observability** capabilities required by the multi‑lens evaluation harness, this document provides sample telemetry event streams conforming to the `runtime/telemetry_schema.md`. These examples illustrate how enforcement components, drift detectors and guardian agents emit events during normal operation and in response to anomalies. Organisations can adapt these patterns when building dashboards, alerts and automated responses.

## Event stream examples

### 1. Pull request blocked due to missing artefact

```json
{
 "event_id": "a1b2c3d4-0001",
 "timestamp": "2026-02-08T12:34:56Z",
 "source": "policy_engine",
 "context": {
 "task_id": "TASK-123",
 "risk_class": 2,
 "autonomy_tier": "A1"
 },
 "event_type": "policy_violation",
 "severity": "error",
 "description": "Merge blocked: missing hazard log",
 "metrics": {
 "missing_artifacts": 1
 },
 "evidence_ids": ["HAZ-LOG-001"],
 "signature": "...digital signature..."
}
```

**Explanation:** The policy engine detects that a required hazard log is missing for a Class 2 task. It emits a `policy_violation` event, including context about the task and risk class. The event links to the missing artefact ID and is signed for tamper‑evidence.

### 2. Runtime behavioural violation

```json
{
 "event_id": "a1b2c3d4-0002",
 "timestamp": "2026-02-08T12:45:10Z",
 "source": "guardian_agent",
 "context": {
 "agent_id": "AGENT-42",
 "contract_id": "CON-7",
 "autonomy_tier": "A3"
 },
 "event_type": "runtime_violation",
 "severity": "critical",
 "description": "Invariant violated: altitude exceeded safe range",
 "metrics": {
 "measured_value": 150.0,
 "max_safe_value": 120.0
 },
 "evidence_ids": ["CON-7", "RUN-MON-15"],
 "signature": "...digital signature..."
}
```

**Explanation:** A guardian agent monitoring a drone detects that the altitude has exceeded the contract’s safe range. It emits a `runtime_violation` event with metrics showing the measured and allowed values. The event links to the behavioural contract and runtime monitor IDs.

### 3. Drift detection and escalation

```json
[
 {
 "event_id": "a1b2c3d4-0003",
 "timestamp": "2026-02-08T13:00:00Z",
 "source": "drift_detector",
 "context": {
 "model_id": "MODEL-8",
 "drift_metric": "PSI"
 },
 "event_type": "variance_threshold_exceeded",
 "severity": "warning",
 "description": "Population stability index exceeded threshold",
 "metrics": {
 "psi_value": 0.28,
 "threshold": 0.25
 },
 "evidence_ids": ["DRIFT-RPT-003"],
 "signature": "...digital signature..."
 },
 {
 "event_id": "a1b2c3d4-0004",
 "timestamp": "2026-02-08T13:00:10Z",
 "source": "policy_engine",
 "context": {
 "model_id": "MODEL-8",
 "action": "rollback"
 },
 "event_type": "policy_violation",
 "severity": "critical",
 "description": "Rollback triggered due to drift threshold exceedance",
 "metrics": {
 "psi_value": 0.28
 },
 "evidence_ids": ["DRIFT-RPT-003"],
 "signature": "...digital signature..."
 }
]
```

**Explanation:** A drift detector observes that the population stability index (PSI) exceeds the predefined threshold. It emits a `variance_threshold_exceeded` event. The policy engine then triggers a rollback, emitting a `policy_violation` event indicating that deployment is halted.

### 4. Probabilistic release gating failure

```json
{
 "event_id": "a1b2c3d4-0005",
 "timestamp": "2026-02-08T14:15:30Z",
 "source": "policy_engine",
 "context": {
 "deployment_id": "DEPLOY-22",
 "risk_class": 3,
 "autonomy_tier": "A2"
 },
 "event_type": "policy_violation",
 "severity": "error",
 "description": "Probabilistic release gate failed: confidence interval too wide",
 "metrics": {
 "confidence_interval_width": 0.18,
 "max_allowed_width": 0.10
 },
 "evidence_ids": ["PERF-TEST-012"],
 "signature": "...digital signature..."
}
```

**Explanation:** During deployment, the policy engine evaluates the confidence interval for performance metrics. The interval width is larger than the allowed threshold, so the probabilistic release gate fails and the deployment is blocked.

## Quantitative drift thresholds

Drift detection requires thresholds that trigger alerts and enforcement. Use statistical tests (e.g., Kolmogorov–Smirnov, PSI) to measure distribution differences. Set numeric thresholds based on empirical analysis and domain risk appetite. For example, a PSI threshold of 0.25 indicates moderate drift; exceeding it should trigger an evaluation and possible rollback.

## Linking to other sections

* **Telemetry schema:** Events conform to the schema defined in `runtime/telemetry_schema.md`. These examples illustrate how each field is used.
* **Policy engine:** Enforcement actions (blocking, rollback) are recorded as `policy_violation` events (`runtime/enforcement_and_policy_engine.md`).
* **Compliance telemetry:** Metrics from events feed into governance health scoring and drift analysis (`runtime/compliance_telemetry_and_governance_drift.md`).
* **Probabilistic assurance:** The confidence interval example ties directly to release gating thresholds (`evaluation/probabilistic_assurance_and_release_metrics.md`).
* **Multi‑agent risk:** Runtime violations and drift events may involve multiple agents; cross‑agent context should be captured as needed (`evaluation/multi_agent_and_emergent_risk.md`).

These sample streams provide a starting point for implementing telemetry pipelines. Organisations should tailor event types and thresholds to their domains and risk appetites while preserving the structure and signing requirements defined by NAP.



