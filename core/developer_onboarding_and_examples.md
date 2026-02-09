# Developer Onboarding and Example Walkthrough

The **NexGentic Agents Protocol (NAP)** is comprehensive by design. Adopting it without guidance could feel overwhelming, especially for teams accustomed to agile AI workflows. This document provides a **narrative onboarding** and a concrete **example walkthrough** to demonstrate how to apply NAP step‑by‑step.

## Quick‑start checklist

1. **Declare your use-case profile first.** Select a primary profile (and optional secondary profiles) from `profiles/use_case_profiles.yaml` that matches the task domain, then validate it against `runtime/use_case_profile_framework.md`.
2. **Assign risk/autonomy and scaffold artifacts.** Use `core/risk_classification.md` and `core/agent_autonomy_and_human_oversight.md` to assign risk class and autonomy tier that satisfy profile floor/ceiling rules, then create the task header and required artifacts from `core/risk_tier_artifact_matrix.md`.
3. **Build the trace graph.** As you define requirements, design elements and tests, link them using the trace graph schema (`core/trace_graph_schema.md`). Use unique IDs for each artefact and ensure links are recorded. The `core/traceability_and_documentation.md` describes how to maintain trace continuity.
4. **Write behavioural contracts.** For any agent actions or inter‑agent messages, define runtime behavioural contracts (`safety/runtime_behavioral_contracts.md`). Specify allowed actions, preconditions, postconditions and safety invariants.
5. **Develop and test.** Implement code following `core/coding_guidelines.md` and separate safety‑critical components as described in `core/architecture_design.md`. Write unit, integration and system tests. Use the guidelines in `safety/testing_and_verification.md` to plan IV&V if required.
6. **Run the policy engine.** Submit your task state transitions to a policy engine implementing `runtime/compliance_runtime_spec.md`. The engine validates artefacts, computes the unified governance score (`runtime/unified_governance_decision_model.md`) and determines whether you may proceed to the next state.
7. **Monitor telemetry.** Integrate runtime monitors to emit telemetry events according to `runtime/telemetry_schema.md`. Observe drift metrics, compliance scores and economic metrics via dashboards.
8. **Document residual risks and economics.** Capture any unresolved hazards in risk acceptance forms (`safety/risk_acceptance_and_residuals.md`) and record economic trade‑offs (`evaluation/economic_and_performance_risk_modeling.md`). Link these to your trace graph.
9. **Iterate and improve.** Use compliance scores and monitoring feedback to address deficiencies. When ready, release or retire the agent following `safety/operations_and_maintenance.md`.

## Example project: Email classification agent

### Scenario

You are building an AI agent to classify incoming emails into categories (spam, work, personal). The agent has **risk class 1** because misclassification has minor business impact and **autonomy tier A1** (suggest category; a human user approves final classification).

### Applying NAP

1. **Profile declaration and classification.** Create `TASK-001` with description, goal, assumptions and `primary_use_case_profile = website_frontend`, then assign `risk_class = 1` and `autonomy_tier = A1`.
2. **Artefacts.** According to the risk matrix, you need a **requirements document** and **design summary**. Write the requirements for classification accuracy and latency. Create a simple design architecture diagram and record assumptions (e.g., training data sources). Because risk class 1 does not require hazard logs or formal proofs, you can proceed after completing requirements and design.
3. **Trace graph.** Link requirements (`REQ-1`: “Classify emails into spam/work/personal with ≥ 95 % accuracy”) to design elements (`DES-1`: “Use fine‑tuned language model”) and to tests (`TST-1`: “Measure accuracy on validation set”). Record these links in the trace graph.
4. **Behavioural contract.** Define a contract specifying allowed actions (read email text, call classification model, output suggested category) and prohibited actions (e.g., sending emails). This contract (CON-1) limits side effects and will be enforced at runtime.
5. **Implementation and testing.** Implement classification using a pre‑trained transformer model. Write unit tests to ensure correct input parsing and integration tests to measure accuracy and latency. Compute probabilistic metrics (error rate, confidence intervals) and run canary tests with a subset of user emails.
6. **Policy evaluation.** Submit the `PLAN` → `READ` → `CHANGE` → `VERIFY` transitions to the policy engine. The engine verifies the existence of `REQ-1`, `DES-1`, `TST-1` and `CON-1`, checks traceability and computes the governance score. Because risk class 1 / A1 tasks are low risk, the engine should auto‑approve transitions as long as required artefacts exist and metrics meet thresholds.
7. **Release and monitor.** Upon entering `RELEASE`, the engine records the governance score and emits telemetry events. Drift detectors monitor classification distribution; if PSI exceeds 0.25, the engine triggers a `variance_threshold_exceeded` event and may roll back or request retraining.
8. **Residual risks.** If the agent occasionally misclassifies sensitive emails, document this in a residual risk acceptance form. Record that misclassification has minor impact and that retraining plans mitigate the risk.
9. **Iteration.** Monitor compliance scores, drift metrics and user feedback. If classification accuracy drops or drift increases, refine the model or adjust thresholds. Regularly review the risk class and autonomy tier as the agent evolves.

### Visualising the flow

In practice, the unified decision model flow is:
`risk class + autonomy tier -> base score -> subtract compliance/probabilistic/economic/residual penalties -> apply precedence vetoes -> approve/manual review/block/escalate`.

## Developer tips

* **Use automation tools.** To reduce process overhead, implement CLI tools that generate scaffolding (task headers, template files) and run policy engine evaluations automatically. See `core/automation_and_scalability.md` for guidelines.
* **Start simple.** For low‑risk tasks, adopt a lightweight subset of NAP. As you gain experience, progressively incorporate hazard analysis, behavioural contracts and probabilistic gating.
* **Visual dashboards.** Integrate telemetry streams into dashboards that display compliance scores, drift metrics and governance status. Visual feedback helps teams understand how their work affects governance health.
* **Collaborate.** Engage product managers, safety engineers and developers in risk reviews. Diverse perspectives improve requirement quality and hazard identification.

By following a structured yet flexible workflow, teams can apply NAP without losing momentum. Narrative examples and diagrams make the protocol more approachable and demonstrate how high‑assurance governance can coexist with practical development practices.



