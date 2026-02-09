# Compliance Telemetry and Governance Drift Monitoring

As the **NexGentic Agents Protocol (NAP)** becomes deeply integrated into development and operations, it is important to monitor the health of the governance process itself. Without visibility into compliance metrics, organisations may overlook deviations, unmitigated risks or erosion of process adherence over time. This document defines telemetry metrics and techniques for detecting governance drift, drawing on NIST guidance that AI systems require frequent maintenance and monitoring due to drift and that human roles and responsibilities must be clearly defined.

## Objectives

1. **Measure protocol adherence.** Quantify how well teams follow NAP requirements across the lifecycle.
2. **Detect governance drift.** Identify trends where compliance weakens (e.g., increasing waiver requests, decreasing test coverage) and trigger corrective actions.
3. **Support continuous improvement.** Use metrics to prioritise training, tooling enhancements and process refinements.

## Core compliance metrics

The following metrics provide a baseline for measuring protocol health. Collect them continuously via the policy engine, traceability tools and configuration management systems:

| Metric | Description | Interpretation |
|---|---|---|
| **Task distribution by risk class and autonomy tier** | Count of tasks per risk class (0–4) and autonomy tier (A0–A4) over time. | Shifts towards higher autonomy and risk require increased oversight and assurance. Unexpected spikes may indicate mission changes or misclassification. |
| **Traceability completeness** | Percentage of requirements that have at least one satisfying design element, code unit and test case in the trace graph. | Low completeness indicates missing artefacts or weak traceability. |
| **Evidence anchoring coverage** | Ratio of artefacts (hazard logs, test reports, risk acceptance forms) that are signed and hash‑chained. | Lower values suggest gaps in evidence integrity or process adoption. |
| **Residual risk acceptance rate** | Number and severity of residual risks accepted per time period. | An upward trend may reflect growing technical debt or schedule pressure. Use this metric to trigger risk management reviews. |
| **Policy violations and overrides** | Count of times the policy engine blocks actions due to missing artefacts or expired approvals, and number of overrides by human approvers. | Frequent violations may indicate training gaps or process misalignment. |
| **Approval latency** | Average time between submission of an artefact and approval or rejection by required authorities. | High latency may bottleneck delivery; very low latency may signal cursory reviews. |
| **Coverage of adversarial tests** | Proportion of relevant tasks that include negative testing and red teaming. | Ensures that vulnerability testing scales with risk. |
| **Maintenance and drift incidents** | Number of incidents triggered by drift detection, emergent behaviours or operational anomalies. | Increasing incidents may require improved monitoring or model retraining. |
| **Waiver/exception expiry compliance** | Ratio of active waivers (risk acceptance approvals, policy exceptions, overrides) that are still within their authorised time window. Count and flag waivers that have expired without renewal. | Low compliance indicates that exceptions are becoming permanent without formal review. Trigger escalation when expired waivers exceed an acceptable threshold. |

### Advanced metrics

* **Protocol health score.** Compute a composite score (0–100) weighted by metrics such as traceability completeness, evidence anchoring coverage and policy violation rate. Use this score to track overall compliance and set thresholds for alerts.

* **Compliance scoring framework.** Use the scoring formula defined in `runtime/compliance_scoring_and_metrics.md` to calculate scores based on missing artefacts, policy violations, drift incidents, runtime violations and economic events. Publishing these scores as `telemetry_health` events enables automated monitoring and comparison across projects.
* **Human involvement ratio.** Measure the proportion of tasks requiring human approval versus those auto‑approved. Compare against autonomy tier policies to identify misuse or overuse of autonomy.
* **Training and documentation coverage.** Track how many team members have completed protocol training and how often templates and guidelines are accessed. Use this to target coaching efforts.

## Telemetry schemas and versioning

Telemetry events must follow canonical schemas defined in `runtime/telemetry_schema.md`. Each schema version includes a version number, a change log and backward compatibility rules. When updating event fields or adding metrics, increment the version number and document the change. The policy engine and monitoring tools must support at least two concurrent schema versions during migration periods. Schema changes require review by the governance board to ensure that downstream analysis remains valid.

## Governance drift detection

1. **Trend analysis.** Visualise metrics over time to detect gradual degradation. For example, decreasing traceability completeness may indicate process fatigue. Use statistical techniques to detect significant deviations.
2. **Threshold alerts.** Define thresholds for key metrics (e.g., evidence anchoring coverage below 90 %) and configure the policy engine or monitoring system to trigger alerts when thresholds are crossed.
3. **Escalation severity tiers.** Not all deviations are equal. Define severity levels (e.g., informational, warning, critical) and map metric thresholds to these tiers. For example, a small decrease in traceability completeness might trigger a **warning**, while a drop below 70 % triggers a **critical** alert requiring immediate executive attention. The policy engine and operations teams should respond according to the severity, escalating to higher authorities for critical events.
4. **Threshold semantics and release gating.** For each metric, define three threshold levels that correspond to governance actions:
 * **Warning:** Metric deviates from target but remains within a tolerable range. Generate an alert and assign corrective actions but allow releases to proceed. Document reasons and monitor for further drift.
 * **Escalation:** Metric crosses a predefined escalation threshold. Require human review and approval before continuing. The policy engine may block automated progression until issues are resolved. Examples include evidence anchoring coverage dropping below 90 %, or waiver expiry compliance falling below 95 %.
 * **Freeze/No‑Go:** Metric exceeds a critical threshold, indicating systemic failure (e.g., traceability completeness below 70 %, unmitigated critical hazards). The policy engine MUST halt releases and trigger a high‑severity incident. Only after corrective actions are taken and metrics return to acceptable ranges may releases resume.

 Defining explicit threshold semantics ensures that governance responses are predictable and machine‑enforceable. Organisations should calibrate thresholds based on domain risk and update them through the risk management process.
4. **Root cause investigation.** When metrics indicate drift, perform causal analysis: is it due to new team members, complex tasks, tool failures, adversarial interference or procedural obstacles? Update training, tools or processes accordingly.
5. **Feedback loops.** Regularly review compliance dashboards with stakeholders (project managers, safety officers, engineers). Use metrics to prioritise improvements and track the impact of changes. When drift is detected, document the response, corrective actions and lessons learned. Feed this information back into the unified governance decision model to refine thresholds and penalties.

## Integration with NAP

* **Policy engine telemetry.** Instrument the policy engine to record metric data and export it to dashboards. This includes counts of rule evaluations, pass/fail rates and enforcement latencies.
* **Traceability tools.** Use the machine‑readable trace graph (`core/trace_graph_schema.md`) to compute traceability completeness metrics automatically.
* **Operations monitoring.** Extend operational dashboards (`safety/operations_and_maintenance.md`) to include governance metrics alongside system health metrics.
* **Risk management.** Incorporate governance metrics into risk reviews, focusing on systemic risks such as process non‑compliance or tooling failures.

By establishing compliance telemetry and governance drift monitoring, NAP becomes self‑reflective. Teams gain visibility into how well the protocol is being followed, enabling proactive improvements and ensuring that high‑assurance practices endure as organisations scale.



