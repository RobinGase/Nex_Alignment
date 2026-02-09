# Risk–Autonomy Matrix and Approval Requirements

As the **NexGentic Agents Protocol (NAP)** introduces both risk classes and autonomy tiers, it is important to clarify how these dimensions interact. This matrix summarises approval requirements, testing depth and human oversight based on the combination of risk class (0–4) and autonomy tier (A0–A4). The goal is to provide an at‑a‑glance reference for planners, reviewers and policy engines.

## Matrix overview

| Risk class \ Autonomy tier | A0 – Advisor | A1 – Assistive | A2 – Autonomous w/ approval | A3 – Supervised autonomy | A4 – Full autonomy |
|---|---|---|---|---|---|
| **Class 0 – Minimal** | Self‑service; review optional | Same as A0 | Requires human confirmation before irreversible actions | Discouraged; rarely needed | Not permitted |
| **Class 1 – Low** | Minimal documentation and logging | Basic review and diff summaries | Human approval before execution | Continuous monitoring recommended | Not permitted |
| **Class 2 – Medium** | Task header, plan, diff summary, unit tests | Same as A2 | Human approval required; IV&V recommended | Only with robust safety boundaries and monitoring | Not permitted |
| **Class 3 – High** | Hazard analysis, formal peer review | Same as A2 | Human approval plus IV&V; formal test plan and hazard controls | Allowed only with redundant controls and risk acceptance; operator monitoring mandatory | Not permitted unless formally justified and residual risk accepted |
| **Class 4 – Critical** | Same as Class 3/A0 | Same as Class 3/A1 | Human approval plus formal IV&V and safety board sign‑off | Allowed only under exceptional circumstances; must implement multiple independent controls and kill‑switches | Allowed only if absolutely necessary and explicitly approved by executive authority; requires full traceability, hazard analysis, signed residual risk acceptance and continuous telemetry monitoring |

### Notes on interpretation

* **Prohibited combinations.** Full autonomy (A4) is not permitted for Classes 0–2 tasks because the potential benefit rarely outweighs the increased complexity. For Class 3 tasks, A4 may be considered only with explicit residual risk acceptance from senior authorities and after demonstrating that no safe human‑in‑the‑loop alternative exists.
* **Escalation paths.** For combinations requiring human approval (A2), tasks must pass through the policy engine’s approval workflow (`runtime/enforcement_and_policy_engine.md`) before actions are executed. For A3 tasks, continuous monitoring and automatic kill‑switch triggers must be implemented (`safety/safety_and_assurance.md`).
* **Testing and validation.** As risk and autonomy increase, the depth of testing must increase. Incorporate negative testing, adversarial evaluation and red teaming for Class 2–4 tasks (`safety/negative_testing_and_red_teaming.md`). Include independent verification and validation for Class 3–4 tasks (`safety/testing_and_verification.md`).
* **Residual risk acceptance.** For Class 3–4 tasks with A3–A4 autonomy, residual risk acceptance is mandatory (`safety/risk_acceptance_and_residuals.md`). Document rationale, hazard controls and sign‑offs. Link the acceptance decision to the traceability matrix (`core/traceability_and_documentation.md`).

## Linking to other sections

* **Risk classification:** See `core/risk_classification.md` for definitions of risk classes and required artefacts.
* **Agent autonomy:** See `core/agent_autonomy_and_human_oversight.md` for definitions of autonomy tiers and oversight guidelines.
* **Policy engine:** Use this matrix to configure the policy engine rules (`runtime/enforcement_and_policy_engine.md`).
* **Testing and verification:** The matrix informs which test types and depths are necessary (`safety/testing_and_verification.md`).
* **Safety and assurance:** High‑risk autonomy combinations require hazard analysis, kill‑switches and human‑in‑the‑loop controls (`safety/safety_and_assurance.md`).

This matrix helps teams quickly determine the appropriate level of rigour and approval required for any task based on its potential impact and the intended autonomy of the agent.



