# NexGentic Agents Protocol (NAP)

This repository contains an updated **NexGentic Agents Protocol (NAP)**, a NASA‑inspired framework for developing, verifying and operating AI‑driven software systems. It integrates lessons from NASA’s software engineering requirements, software assurance standards and safety guidelines. The goal is to achieve predictable, auditable and safe agent behaviour while covering the full software life‑cycle from requirements through retirement. 

## Start here first

For a cleaner and deterministic navigation flow, begin with `START_HERE.md`.
It routes developers and agents to the right folder and protocol documents by use case.

## Phase 4 canonical layout

Canonical protocol documents are organized into topic folders:

- `core/`
- `safety/`
- `runtime/`
- `evaluation/`

Root-level markdown files now include only repository entrypoints (`README.md`, `START_HERE.md`, `CHANGELOG.md`).
All protocol content is canonicalized under topic folders.

## Why a new structure?

Earlier drafts focused primarily on risk classes and process gating but missed key NASA priorities such as requirements management, architecture documentation, hazard analysis, configuration management and maintenance planning. This new structure addresses those gaps. Each section links to related guidance to encourage consistent application. Together the documents implement NASA’s expectation that software projects plan comprehensively, document decisions, validate and verify independently and manage risk throughout the life‑cycle.

## Repository overview

| Path | Purpose |
| --- | --- |
| `START_HERE.md` | Primary navigation entrypoint that routes agents and developers by use case, folder, and required validation steps. |
| `core/README.md` | Core baseline index for risk, autonomy, requirements, architecture and traceability foundations. |
| `safety/README.md` | Safety/assurance index for hazard controls, verification depth, formal methods and residual-risk handling. |
| `runtime/README.md` | Runtime enforcement index for deterministic decision ownership, profile checks and policy execution. |
| `evaluation/README.md` | Evaluation index for advisory harnesses, probabilistic assurance context and audit output interpretation. |
| `use_case_playbooks/README.md` | Profile-by-profile playbook index for quick domain routing and first-doc reads. |
| `maps/README.md` | Routing assets index for machine-friendly protocol navigation. |
| `maps/use_case_doc_routes.yaml` | Machine-readable profile-to-document routing map for agent/tool integration. |
| `core/risk_classification.md` | Describes risk classes, tailoring rules and required artefacts. Introduces quantitative triggers and examples. |
| `core/requirements_management.md` | Outlines how to elicit, document, validate and trace requirements; introduces hazard analysis and safety‑critical identification. |
| `core/architecture_design.md` | Provides guidance for designing and reviewing software architecture and module design. |
| `core/coding_guidelines.md` | Summarises coding rules inspired by NASA’s “Power of Ten” and secure coding practices. |
| `safety/testing_and_verification.md` | Defines testing strategies, verification processes, code coverage and Independent Verification & Validation (IV&V). |
| `core/configuration_and_risk_management.md` | Specifies configuration management, change control, versioning and risk management practices. |
| `safety/safety_and_assurance.md` | Describes hazard analysis, safety‑critical classification, hazard controls and software assurance objectives. |
| `safety/operations_and_maintenance.md` | Covers operational planning, maintenance, monitoring and retirement procedures. |
| `safety/ai_specific_considerations.md` | Addresses AI‑specific challenges including uncertainty management, emergent behaviours, human‑in‑the‑loop design, model/data governance and drift monitoring. |
| `core/automation_and_scalability.md` | Offers guidance on automation tooling, lightweight execution paths and scaling the protocol to larger teams. |
| `core/traceability_and_documentation.md` | Defines a bidirectional traceability schema linking requirements, design, code, tests, hazard controls and risk decisions. |
| `safety/risk_acceptance_and_residuals.md` | Establishes a formal process for residual risk acceptance, including roles, approval forms and waiver procedures. |
| `safety/model_and_data_supply_chain_security.md` | Provides guidance on dataset and model provenance, versioning, digital signatures and supply chain risk management. |
| `core/agent_autonomy_and_human_oversight.md` | Defines autonomy tiers and human oversight guidelines, complementing risk classes and aligning with NIST’s emphasis on varying levels of autonomy. |
| `safety/negative_testing_and_red_teaming.md` | Describes negative testing, adversarial evaluation and red teaming to uncover vulnerabilities. |
| `safety/evidence_anchor_and_log_integrity.md` | Explains cryptographic evidence anchoring and log integrity mechanisms to ensure tamper‑proof documentation. |
| `runtime/enforcement_and_policy_engine.md` | Proposes a machine‑enforced policy engine to gate tasks, verify evidence and automate compliance with NAP. |
| `core/risk_autonomy_matrix.md` | Provides a matrix combining risk classes and autonomy tiers to identify required approvals, testing depth and oversight. |
| `core/trace_graph_schema.md` | Specifies a machine‑readable schema for the traceability graph, enabling automated assurance and tool interoperability. |
| `runtime/compliance_telemetry_and_governance_drift.md` | Defines compliance metrics and drift monitoring techniques to measure protocol adherence and detect governance erosion. |
| `safety/runtime_behavioral_contracts.md` | Describes how to define and enforce runtime behavioural contracts that bound AI agents’ actions and invariants. |
| `evaluation/multi_agent_and_emergent_risk.md` | Addresses risks arising from multi‑agent systems, emergent behaviours and self‑modification, and provides modelling and control strategies. |
| `evaluation/probabilistic_assurance_and_release_metrics.md` | Defines statistical assurance metrics (confidence intervals, variance) and canary release gating for AI and multi‑agent systems. |
| `runtime/enforcement_architecture_and_implementation.md` | Offers practical guidance for implementing the policy engine, risk classification services, CI/CD integration and runtime enforcement patterns. |
| `evaluation/economic_and_performance_risk_modeling.md` | Integrates cost, latency and business impact into risk decisions and trade‑off analysis for safety‑critical AI. |
| `core/adoption_maturity_levels.md` | Outlines a maturity model with incremental adoption levels, helping organisations progress from foundational practices to self‑auditing autonomy. |
| `evaluation/ultra_tier_enhancement_blueprint.md` | Presents an executive gap analysis and detailed blueprint for achieving near‑perfect governance completeness across formal behavioural envelopes, self‑trust bootstrapping, adaptive compliance, assurance graphs, multi‑agent formalisation, probabilistic release, federated governance, economic ethics, formal verification hooks and autonomous compliance runtimes. |
| `core/normative_and_reference_guidance.md` | Clarifies the distinction between normative (mandatory) and reference (customisable) elements of the protocol, provides guidance on managing deviations and updating parameters, and explains change control and auditability. |
| `evaluation/multi_agent_simulation_and_modeling.md` | Provides a methodological framework for designing, executing and analysing multi‑agent simulations, including scenario design, simulation environments, coverage criteria, metrics and normative vs reference requirements. Complements the modelling guidance in `evaluation/multi_agent_and_emergent_risk.md`. |
| `runtime/telemetry_schema.md` | Defines the standard schema for telemetry events, enabling automated compliance monitoring, drift detection and governance health scoring. |
| `evaluation/nap_evaluation_harness.md` | Provides a deterministic, fail‑closed evaluation framework and multi‑agent workflow for objectively assessing NAP compliance and scoring. Harness outcomes are assurance recommendations only (`assurance_go`/`assurance_no_go`) and are not runtime authorization gates. |
| `evaluation/multi_lens_evaluation_harness.md` | Extends the evaluation harness to incorporate nine assurance lenses (NASA safety, hyperscale industry, AI autonomy, formal verification, DevSecOps, telemetry, developer ergonomics, survivability and economic ethics). Defines lens‑specific evidence requirements and fail‑closed scoring rules. Multi‑lens outcomes are advisory and do not replace runtime gate ownership. |
| `safety/formal_verification_and_runtime_proof.md` | Integrates formal verification into NAP by defining formal contracts, proof artefacts and runtime verification hooks, enabling mathematical and statistical assurance boundaries. |
| `runtime/telemetry_example_streams.md` | Provides sample telemetry event streams demonstrating how policy violations, drift detections and probabilistic release failures are recorded using the standard telemetry schema. Includes threshold guidance for drift detection. |
| `evaluation/federated_governance_and_interoperability.md` | Defines a federated governance model for cross‑organisation interoperability, core versus extension modules, evidence sharing, policy negotiation and upgrade survivability. |
| `runtime/compliance_runtime_spec.md` | Specifies the deterministic enforcement contract for NAP, including state transitions, artefact requirements, machine‑checkable validation rules, policy engine request/response schemas, failure escalation states and canonical decision terminology/precedence ownership. |
| `runtime/use_case_profile_framework.md` | Defines the modular use-case profile layer, deterministic profile composition rules, runtime verification behavior and override boundaries. |
| `profiles/` | Profile catalogs for domain-specific governance selection. Includes reusable bundles (`profiles/use_case_bundles.yaml`) and profile definitions (`profiles/use_case_profiles.yaml`). |
| `core/risk_tier_artifact_matrix.md` | Provides a table mapping risk classes and autonomy tiers to mandatory artefacts, enabling machine validation and auditing of compliance. |
| `runtime/compliance_scoring_and_metrics.md` | Defines event categories, quantitative drift thresholds and a compliance scoring formula to convert telemetry into measurable governance health. |
| `evaluation/probabilistic_release_gate_example.md` | Walks through a worked example of a probabilistic release gate, illustrating statistical calculations and gating decisions. |
| `runtime/unified_governance_decision_model.md` | Unifies risk classification, compliance scoring, probabilistic release gating and residual risk acceptance into a single quantitative decision model. Provides formulas, example penalties and decision thresholds, integrates these elements into the policy engine, and acts as the authoritative runtime decision function with `runtime/compliance_runtime_spec.md`. |
| `core/developer_onboarding_and_examples.md` | Offers a narrative onboarding and example walkthrough, including a quick‑start checklist, a sample low‑risk project, and diagrams to illustrate the unified decision model. Helps new teams apply NAP without being overwhelmed. |
| `templates/` | Contains copy-and-paste templates for task headers, review checklists, hazard logs, policy engine rules, use-case override requests and dataset/model documentation. |
| `tools/run_enforcement_simulations.ps1` | Executable simulation harness that validates deterministic runtime outcomes (`approve`, `manual_review`, `block`, `escalate`) for representative policy scenarios. Writes machine-readable results to `audit_outputs/`. |
| `tools/check_policy_runtime_parity.ps1` | Parity check script that validates policy template rules against runtime normative constraints (for example, A4 prohibition for Class 0–2). Writes a machine-readable report to `audit_outputs/`. |
| `tools/validate_use_case_profiles.ps1` | Validates profile and bundle catalogs, checks cross-references and emits `audit_outputs/use_case_profile_validation_report.json`. |
| `audit_outputs/README.md` | Generated-output workspace. Starts empty for fresh implementations; populate by running scripts in `tools/`. |
| `CHANGELOG.md` | Records notable changes to the protocol. |

## Getting started

1. Open `START_HERE.md` and follow its use-case routing flow.
2. Use `core/README.md` for baseline protocol setup, then `runtime/README.md` for deterministic enforcement flow.
3. Read `core/risk_classification.md` and `core/agent_autonomy_and_human_oversight.md` to assign risk class and autonomy tier that satisfy profile floor/ceiling constraints.
4. Use `templates/task_header_template.md` to capture profile declarations, operation tags, goal, constraints and plan.
5. Execute and test according to `safety/testing_and_verification.md`, ensuring independent review when required.
6. Log configuration items and risks as described in `core/configuration_and_risk_management.md`.
7. Perform hazard analysis and assurance activities from `safety/safety_and_assurance.md`.
8. Plan for deployment, maintenance and retirement with `safety/operations_and_maintenance.md`.
9. Review `safety/ai_specific_considerations.md` to address AI‑specific uncertainties, emergent behaviours and drift monitoring, and integrate these considerations into requirements, design and operations.
10. Build traceability matrices as described in `core/traceability_and_documentation.md` and ensure that every requirement, design element, test case and hazard control has a unique identifier and links.
11. Create a machine‑readable trace graph following `core/trace_graph_schema.md` to enable automated validation and tool interoperability.
12. When hazards cannot be fully mitigated, follow `safety/risk_acceptance_and_residuals.md` to document residual risks, obtain approvals and record waivers.
13. Manage datasets and models securely by following `safety/model_and_data_supply_chain_security.md` for provenance, versioning and signature practices.
14. Determine the autonomy tier for each task using `core/agent_autonomy_and_human_oversight.md` and ensure appropriate human oversight.
15. Use `core/risk_autonomy_matrix.md` to understand how risk class and autonomy tier combine to determine the required approvals, testing depth and oversight.
16. Integrate negative testing and adversarial evaluation into your test plans using `safety/negative_testing_and_red_teaming.md`.
17. Anchor logs and evidence with digital signatures and hash chains per `safety/evidence_anchor_and_log_integrity.md`.
18. Implement or integrate a policy engine as described in `runtime/enforcement_and_policy_engine.md` to automate compliance and gating, and use the policy engine rules template in `templates/policy_engine_rules.yaml`.
19. Define runtime behavioural contracts for safety‑critical or high‑autonomy tasks following `safety/runtime_behavioral_contracts.md` and ensure that contract monitors are integrated into runtime environments.
20. Monitor protocol adherence and detect governance drift by implementing metrics and dashboards as described in `runtime/compliance_telemetry_and_governance_drift.md`.
21. Finally, consider automating protocol steps and adopting lightweight execution paths as described in `core/automation_and_scalability.md`.

22. For AI systems and multi‑agent environments, incorporate probabilistic metrics and confidence‑based release gating using `evaluation/probabilistic_assurance_and_release_metrics.md`.
23. Model and mitigate multi‑agent and self‑modification risks by following `evaluation/multi_agent_and_emergent_risk.md`. Use simulations and cross‑agent monitoring to detect emergent behaviours and update hazard logs accordingly.
24. Integrate cost, latency and business considerations into your risk decisions by consulting `evaluation/economic_and_performance_risk_modeling.md`. Document trade‑off analysis and align safety measures with business objectives.
25. Use `runtime/enforcement_architecture_and_implementation.md` to design and implement the policy engine and enforcement mechanisms that integrate with your CI/CD pipelines, runtime environments and monitoring systems.
26. Assess your organisation’s current governance maturity and plan incremental adoption by referring to `core/adoption_maturity_levels.md`.

27. Apply the unified decision model from `runtime/unified_governance_decision_model.md` to combine risk class, compliance score, probabilistic metrics, economic harm and residual risks into a single governance score. Use this model to inform policy engine decisions and gating thresholds.

28. Use `core/developer_onboarding_and_examples.md` to familiarise new team members with NAP. Follow the quick‑start checklist and study the worked example to see how artefacts, trace graphs and enforcement decisions come together in practice.

This modular structure allows teams to adopt the components that are most relevant to their project while maintaining compliance with NASA’s high standards.



