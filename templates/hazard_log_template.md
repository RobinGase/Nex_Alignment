# Hazard Log Template

The hazard log is a living document used to record hazards, their causes, controls and verification status. For safety‑critical tasks (Class 3–4), maintain this log under configuration management and update it whenever new hazards or controls are identified.

```md
| Hazard ID | Description | Severity (Catastrophic/Critical/Marginal/Negligible) | Software Components Involved | Causes | Controls (Design/Procedural/Operational) | Verification Activities | Status | Residual Risk Acceptance |
|---|---|---|---|---|---|---|---|---|
| H‑1 | Describe the hazard | Critical | List modules or functions | List root causes (e.g., variable overflow, sensor failure) | Describe independent controls (e.g., bounds check, watchdog timer, operator procedure) | List tests, analyses and inspections used to verify controls | Open/Closed | Identify authority that accepted residual risk |
| H‑2 |... |... |... |... |... |... |... |... |
```

For each entry:

* **Hazard ID** – Unique identifier used for traceability.
* **Description** – Clear statement of the hazardous condition.
* **Severity** – Categorise according to worst‑case outcome.
* **Software Components Involved** – Identify code modules, services or data paths related to the hazard.
* **Causes** – Identify the root causes (e.g., software failure, interface error, operator error).
* **Controls** – Provide at least two independent controls for critical hazards and three for catastrophic hazards.
* **Verification Activities** – Describe tests, analyses or reviews that verify the controls.
* **Status** – Indicate whether the hazard is open (controls not yet fully verified) or closed (controls verified and accepted).
* **Residual Risk Acceptance** – Document who has accepted any remaining risk, the rationale and conditions for acceptance, and link to the risk acceptance form ID (see `safety/risk_acceptance_and_residuals.md`).

Maintain evidence (test results, analyses) to support verification. Link each hazard to requirements, design elements and code components.



