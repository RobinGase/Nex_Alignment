# Adoption Maturity Levels

Implementing the **NexGentic Agents Protocol (NAP)** in its entirety requires significant investment in tooling, processes and cultural change. To support organisations of varying sizes and readiness levels, this document introduces a **maturity model** that defines incremental adoption levels. Each level builds on the previous one and adds new capabilities, allowing teams to gradually enhance safety and governance without overwhelming resources.

## Level 1 – Foundations

* **Risk classification and templates.** Teams start by using `core/risk_classification.md` to classify tasks and by adopting the basic task header, hazard log and review checklist templates (`templates/`).
* **Basic testing and peer review.** Unit tests and peer reviews are required for Class 1–2 tasks. Traceability is informal but documented in prose.
* **Manual approvals.** Human approvers review tasks based on the risk class. Residual risks are recorded in simple logs.
* **Training and awareness.** Team members receive introductory training on NAP principles and high-assurance practices.

**Entry criteria:** The organisation has identified AI projects, designated a governance lead and committed to adopting NAP principles. Team members have completed an introductory training session and have access to the basic templates.

**Exit criteria:** All new tasks are classified using `core/risk_classification.md`; the task header and hazard log templates are used for Class 1–2 tasks; manual approvals are documented; and the team can demonstrate at least one completed project with informal traceability and recorded residual risks.

* **Quick‑start pathways.** Provide a **Quick‑Start Guide** that summarises the minimal steps needed to comply with NAP for low‑risk tasks. The guide includes a short checklist, sample task header and links to scaffolding tools (`core/automation_and_scalability.md`). Encourage new teams to start here before advancing to higher maturity levels.

## Level 2 – Structured Engineering

* **Formal traceability.** Adopt the traceability matrix guidelines (`core/traceability_and_documentation.md`) to link requirements, design, code and tests. Begin using hazard logs and risk registers.
* **Increased testing rigour.** Integration tests, system tests and regression tests become standard for Class 2 tasks. Negative testing and adversarial evaluation are introduced (`safety/negative_testing_and_red_teaming.md`).
* **Configuration management.** Implement configuration control and change management (`core/configuration_and_risk_management.md`). Begin versioning datasets and models (`safety/model_and_data_supply_chain_security.md`).
* **Initial automation.** Automate static analysis and unit tests in CI pipelines. Use risk calculators to suggest risk classes.

**Entry criteria:** Level 1 exit criteria met; team has an established version control and CI pipeline.

**Exit criteria:** The project maintains a machine‑readable trace matrix connecting requirements to design, code and tests; hazard logs and risk registers exist; configuration management is in place; risk calculators are integrated into CI; and at least one release has been produced following these structured practices.

## Level 3 – Automated Assurance

* **Policy engine deployment.** Implement a policy engine as described in `runtime/enforcement_and_policy_engine.md` and `runtime/enforcement_architecture_and_implementation.md`. Integrate policy checks into CI/CD pipelines and enforce state machine transitions.
* **Machine‑readable trace graphs.** Create trace graphs according to `core/trace_graph_schema.md`. Use tools to validate trace completeness and generate reports.
* **Evidence anchoring.** Adopt digital signatures and hash chains for logs and artefacts (`safety/evidence_anchor_and_log_integrity.md`).
* **Probabilistic assurance.** Incorporate statistical metrics and confidence‑based release gates (`evaluation/probabilistic_assurance_and_release_metrics.md`). Implement canary deployments and runtime safety metrics.
* **Compliance telemetry.** Collect metrics defined in `runtime/compliance_telemetry_and_governance_drift.md` and start building dashboards.

**Entry criteria:** Level 2 exit criteria met; team has sufficient automation infrastructure to support policy engine deployment.

**Exit criteria:** A policy engine enforces state transitions and checks artefacts in CI/CD; machine‑readable trace graphs are generated and validated; evidence anchoring is applied to key artefacts; probabilistic assurance metrics are computed for high‑risk tasks; and compliance telemetry dashboards display core metrics with defined thresholds and alerts.

## Level 4 – Adaptive Governance

* **Multi‑agent and emergent risk management.** Apply `evaluation/multi_agent_and_emergent_risk.md` to model and mitigate emergent behaviours. Introduce cross‑agent monitoring and simulation.
* **Runtime behavioural contracts.** Define and enforce behavioural contracts (`safety/runtime_behavioral_contracts.md`) for safety‑critical and autonomous tasks.
* **Economic and performance modelling.** Integrate cost and latency trade‑off analysis into risk decisions (`evaluation/economic_and_performance_risk_modeling.md`).
* **Automated compliance scoring.** Implement scoring algorithms that combine safety metrics, economic metrics and business KPIs. Use scores to drive automatic gating and prioritisation.
* **Enhanced policy resilience.** Use distributed consensus and self‑integrity checks in the policy engine (`runtime/enforcement_and_policy_engine.md`). Deploy override agents and fallback patterns.

**Entry criteria:** Level 3 exit criteria met; the organisation operates multiple agents or systems requiring emergent behaviour analysis.

**Exit criteria:** Behavioural contracts are enforced at runtime; economic and performance models inform risk decisions; multi‑agent simulation tools are in place; compliance scoring algorithms gate releases; distributed policy engines operate with failover; and adaptive controls adjust safety measures based on telemetry and emergent behaviour.

## Level 5 – Self‑Auditing Autonomy

* **Behavioural contract synthesis and enforcement.** Explore research into automatically synthesising behavioural contracts from requirements and operational data. Integrate contract learning with reinforcement learning supervision.
* **Continuous multi‑agent simulation.** Maintain digital twins of production environments to continuously simulate agent behaviour and emergent effects. Use simulation results to pre‑emptively adjust policies and contracts.
* **Probabilistic and economic optimisation.** Use advanced modelling to optimise risk controls, confidence thresholds and cost impacts simultaneously. Implement AI‑driven policy engines that adapt gating rules based on real‑time metrics and predicted outcomes.
* **Optional autonomous governance-agent pilots.** Pilot agents that monitor compliance telemetry, analyse governance drift and recommend process refinements. These pilots must operate in recommendation mode, require human approval for policy changes and include rollback safeguards.
* **Widespread cultural adoption.** NAP becomes embedded in organisational culture. Teams treat safety, traceability and continuous improvement as core values rather than burdens. Governance becomes a competitive advantage.

**Entry criteria:** Level 4 exit criteria met; the organisation has mature AI operations, a culture of governance and continuous improvement, and resources to invest in advanced research and tooling.

**Exit criteria:** Behavioural contract synthesis and continuous simulation are integrated into operations; economic and probabilistic optimisation drive adaptive policy engines; the organisation demonstrates compliance with external standards (e.g., EU AI Act, ISO/IEC 25010); and NAP practices are institutionalised across teams with minimal human enforcement. If autonomous governance-agent pilots are used, they must satisfy pilot-gate controls (human approval, rollback, non-decreasing safety thresholds).

## Using the maturity model

* **Assess current level.** Use the maturity model to assess where your organisation currently sits. Identify gaps between current practices and the next level.
* **Plan incremental adoption.** Set realistic adoption goals based on your resources, domain and risk appetite. Focus on improvements that deliver the most safety value relative to cost.
* **Iterate and adapt.** Treat the maturity model as a living framework. As technology evolves and organisational needs change, adjust maturity levels and associated capabilities.

By defining adoption maturity levels, NAP helps organisations chart a path from basic compliance to sophisticated, self‑auditing AI governance. Teams can build confidence gradually, ensuring that safety and accountability grow alongside innovation and scale.





