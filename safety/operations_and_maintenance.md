# Operations, Maintenance and Retirement

NASA requires planning for operations, maintenance and retirement throughout the software life cycle. Software is not complete when it is delivered; it must be monitored, maintained, updated and eventually retired in a controlled manner. This section describes how to manage these phases within the **NexGentic Agents Protocol (NAP)**.

## Operational planning

1. **Define operational objectives and constraints.** Clarify what the system is expected to do in its operational environment and any constraints (performance, availability, latency, safety). Include these in operational requirements.
2. **Establish operational procedures.** Document procedures for deploying, starting, stopping and monitoring the system. Define roles and responsibilities for operators and support personnel.
3. **Monitoring and logging.** Implement monitoring to track system performance, resource usage and error conditions. Log operational events, including user actions, errors, warnings and security events. To support **forensic reconstruction of decisions**, telemetry and logs must capture sufficient context to explain what the system did and why (e.g., inputs, model versions, autonomy level, risk class and control decisions). Analyse logs for anomalies, policy violations and potential hazards.
4. **Incident response and rollback.** Define procedures for responding to incidents, including error triage, escalation and rollback to a safe state. For Class 2–4 tasks, create an approved rollback plan before deployment. **Rollbacks must be exercised in a test environment** so that teams are confident procedures work as expected. For Class 3–4 tasks, conduct **tabletop incident simulations** that rehearse operational responses to failures, security breaches or unsafe AI behaviours. Use these exercises to validate escalation paths and improve the incident playbook.

## Maintenance and updates

1. **Bug fixes and minor changes.** Use the change control process (`core/configuration_and_risk_management.md`) for all updates. Assess the impact and risk class of each change. For Class 3–4 tasks, perform hazard analysis and IV&V on changes.
2. **Patch management.** Schedule regular patch cycles to address security vulnerabilities and defects. Test patches in a staging environment before deploying to production. Document patch contents and update the configuration baseline. **Security patches that address critical vulnerabilities may bypass the normal release cadence** to minimise exposure, but must still trigger a **retrospective assurance review** and update the risk register and hazard analysis. Record the justification for emergency patches and any deviations from standard processes.
3. **Enhancements and refactoring.** Treat major enhancements like new development: update requirements (`core/requirements_management.md`), review architecture and design (`core/architecture_design.md`), follow coding guidelines, perform testing, update hazard analysis, and obtain appropriate approvals.
4. **Preventive maintenance.** Perform maintenance to improve reliability and performance (e.g., database maintenance, log rotation, hardware upgrades). Plan maintenance windows to minimise disruption.
5. **Deprecation and retirement planning.** Identify components or features scheduled for retirement. Provide timelines for phasing them out and communicate with stakeholders. Ensure that alternative solutions or replacements are available before decommissioning.

## Retirement

1. **Assess readiness for retirement.** Determine whether the system is obsolete, superseded or no longer needed. Evaluate impacts on dependent systems and stakeholders.
2. **Plan the shutdown.** Develop a retirement plan that describes how to disable the system safely, archive data, preserve records (requirements, design, test results, hazard logs) and transfer responsibilities. Ensure that hazard controls remain in place until the system is fully decommissioned.
3. **Archival, knowledge retention and data governance.** Archive documentation, code, configuration records and assurance artefacts in a retrievable format. Define **data retention and deletion policies** that specify which data must be retained (e.g., safety evidence, audit logs), retention durations and secure disposal methods. Provide plans for **knowledge transfer or archival summaries** so that future teams can understand the system’s design, operation and rationale. NASA expects projects to maintain records for future retrieval.
4. **Post‑retirement evaluation.** Conduct a lessons‑learned review to capture successes and issues encountered. Feed these insights into future projects to continuously improve processes and safety.

## Continuous AI evaluation and drift monitoring

AI systems require ongoing evaluation to detect data, model or concept drift, which may necessitate corrective maintenance. Integrate continuous evaluation into operational procedures:

1. **Telemetry and metrics collection.** Continuously collect metrics such as model performance, uncertainty measures, latency, resource usage and error rates. Aggregated metrics should be monitored for trends and anomalies.
2. **Drift detection and alerts.** Implement automated drift detection methods (see `safety/ai_specific_considerations.md`) and configure alerts when thresholds are exceeded. **Document the rationale for each threshold** and link it to the associated risk class and safety requirements. Threshold definitions should consider acceptable error budgets, user impact and hazard severity. Integrate alerts with incident response plans so that operators know when to investigate, roll back or retrain.
3. **Scheduled evaluation and re‑training.** Schedule periodic evaluations using representative datasets. When performance degradation is detected, plan for re‑training and validation following the full protocol. **Re‑training must include a re‑evaluation of risk classification and hazard analysis**; changes to model architecture, training data or performance characteristics may alter the risk class or autonomy tier, requiring updated controls and approvals.
4. **Alignment monitoring.** For generative agents, monitor for hallucinations, bias amplification, prompt injection and harmful outputs. Use curated evaluation prompts and update them as threats evolve.
5. **Human oversight and escalation.** Maintain human‑in‑the‑loop oversight during operations. Operators should review AI outputs when drift or anomalies are detected and decide whether to continue, halt or retrain.

## Operator cognitive load and training

Operators play a critical role in monitoring AI systems, intervening when necessary and ensuring safe operation. To manage cognitive load and empower operators:

1. **Training programmes.** Provide regular training on AI system behaviour, uncertainty interpretation, emergent behaviour recognition and escalation procedures. Include bias awareness and ethical considerations.
2. **User interface design.** Design dashboards and alerts to prioritise high‑impact events. Avoid information overload by grouping notifications and providing actionable insights.
3. **Workload management.** Monitor operator workload and adjust staffing or automation to prevent fatigue. Use automation to handle routine events while reserving human attention for complex or safety‑critical situations.
4. **Feedback loops.** Encourage operators to provide feedback on AI performance, including false positives/negatives and usability issues. Incorporate this feedback into model improvements and protocol updates.

By integrating continuous evaluation, drift monitoring and operator support into operations and maintenance, the NAP ensures that AI systems remain reliable, aligned and safe throughout their operational life.

## Linking to other sections

* **Risk classification:** Operational and maintenance activities should respect the risk classification (`core/risk_classification.md`). High‑risk systems require more rigorous monitoring and incident management.
* **Configuration management:** All operational procedures, deployments and maintenance activities must be captured in the configuration management system (`core/configuration_and_risk_management.md`). Use baselines to manage different operational versions.
* **Testing and verification:** Before deploying updates or retiring systems, perform appropriate testing and verification (`safety/testing_and_verification.md`). Verify that maintenance changes do not compromise hazard controls or safety.
* **Safety and assurance:** During operations, monitor for safety‑related anomalies. Update hazard analysis and assurance plans as the operational environment changes (`safety/safety_and_assurance.md`).
* **Compliance telemetry:** Use metrics defined in `runtime/compliance_telemetry_and_governance_drift.md` to monitor protocol adherence during operations and maintenance. Include operational metrics (drift incidents, human oversight rate) alongside compliance metrics on dashboards.

By planning for operations, maintenance and retirement early and continuously, the NAP ensures that deployed agents remain safe, reliable and responsive to changing conditions throughout their life cycle.



