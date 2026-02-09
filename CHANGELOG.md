# Changelog

All notable changes to the **NexGentic Agents Protocol (NAP)** will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.1.1] – 2026-02-09
### Changed
* Cleaned repository for fresh project implementation:
 * Removed previously generated files from `audit_outputs/`.
 * Added `audit_outputs/README.md` as a clean generation target.
 * Added `.gitignore` rules to keep generated `audit_outputs/*` out of baseline commits (except `audit_outputs/README.md`).
 * Updated `README.md` to reference the clean `audit_outputs/` workflow.

## [1.1.0] – 2026-02-09
### Added
* Executable enforcement evidence tooling:
 * `tools/run_enforcement_simulations.ps1` – deterministic scenario runner that emits machine-readable evidence.
 * `tools/check_policy_runtime_parity.ps1` – parity validation for policy template rules against runtime normative constraints.
* New audit artifacts:
 * `audit_outputs/executable_simulation_results.json`
 * `audit_outputs/policy_runtime_parity_report.json`
 * `audit_outputs/benchmark_manifest.yaml`
 * `audit_outputs/source_refresh_log.md`
 * `audit_outputs/cross_framework_adapter_map.csv`

### Changed
* Clarified runtime decision ownership and removed audit/runtime authority ambiguity across:
 * `evaluation/nap_evaluation_harness.md`
 * `evaluation/multi_lens_evaluation_harness.md`
 * `runtime/compliance_runtime_spec.md`
 * `runtime/compliance_scoring_and_metrics.md`
 * `runtime/unified_governance_decision_model.md`
 * `templates/policy_engine_rules.yaml`
* Added canonical decision terminology and precedence model to `runtime/compliance_runtime_spec.md`.
* Marked high-risk advanced controls as opt-in pilots in:
 * `evaluation/ultra_tier_enhancement_blueprint.md`
 * `core/adoption_maturity_levels.md`
 * `safety/formal_verification_and_runtime_proof.md`
* Simplified lens terminology in `evaluation/multi_lens_evaluation_harness.md` by removing "Quantum" branding and treating lens weights as reference defaults.
* Updated `README.md` navigation entries for new tools and audit outputs.

## [1.0.0] – 2026-02-08
### Added
* Initial release of the NAP repository with comprehensive documents:
 * `README.md` – overview and navigation.
 * `core/risk_classification.md` – risk classes, tailoring rules and required artefacts.
 * `core/requirements_management.md` – requirements elicitation, validation and traceability.
 * `core/architecture_design.md` – architectural principles, documentation and design review guidance.
 * `core/coding_guidelines.md` – Power of Ten rules and secure coding practices.
 * `safety/testing_and_verification.md` – test planning, execution and IV&V guidance.
 * `core/configuration_and_risk_management.md` – configuration management and risk management practices.
 * `safety/safety_and_assurance.md` – hazard analysis, safety‑critical software identification and assurance activities.
 * `safety/operations_and_maintenance.md` – operational planning, maintenance and retirement procedures.
 * `templates/` – templates for task headers, hazard logs and review checklists.

### Notes
* The initial release incorporates lessons from NASA’s software engineering requirements and safety standards.



