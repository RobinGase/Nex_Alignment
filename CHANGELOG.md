# Changelog

All notable changes to the **NexGentic Agents Protocol (NAP)** will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.1.3] – 2026-02-10
### Added
* Migration and rollback guide for path default changes:
  * `docs/MIGRATION_PATH_UPDATE.md`
* Canonical version governance artifacts:
  * `VERSION.txt`
  * `tools/check_version_consistency.ps1`
* CI/CD integration baseline for automated validation:
  * `.github/workflows/nap-validation.yml` – GitHub Actions workflow for Linux pwsh validation
  * `.gitlab-ci.yml` – Optional GitLab CI example for GitLab users
* Comprehensive Pester test suite for validation tooling:
  * `tools/tests/Test-GetListFromBlock.ps1` – Regex-based YAML list extraction tests
  * `tools/tests/Test-AutonomyRank.ps1` – Autonomy tier to rank conversion tests
  * `tools/tests/Test-ProfileValidation.ps1` – Profile and bundle validation logic tests
  * `tools/tests/fixtures/` – YAML fixtures for testing
  * `tools/tests/QuickTest.ps1` – Quick verification runner (no Pester required)
  * `tools/tests/README.md` – Test execution guide
* Parser migration strategy documentation:
  * `docs/PARSER_MIGRATION_STRATEGY.md` – Trigger criteria and migration options for YAML parsing

### Changed
* Made PowerShell tooling deterministic from any working directory by switching default paths to `$PSScriptRoot`-relative values:
 * `tools/validate_use_case_profiles.ps1`
 * `tools/check_policy_runtime_parity.ps1`
 * `tools/run_enforcement_simulations.ps1`
 * `tools/run_optional_workflows.ps1`
* Improved path-related error handling with remediation guidance in PowerShell tooling.
* Updated command examples to run directly from repository root:
 * `START_HERE.md`
 * `INFO.md`
 * `use_case_playbooks/README.md`
* Synchronized YAML catalog versions to canonical source:
 * `profiles/use_case_profiles.yaml`
 * `profiles/use_case_bundles.yaml`
 * `maps/use_case_doc_routes.yaml`

## [1.1.2] – 2026-02-09
### Added
* Optional env-driven integration runner:
 * `tools/run_optional_workflows.ps1` – detects enabled integrations from `.env` and executes optional tool-calls.
 * `.env.example` – template for optional workflow toggles and Notion credentials.

### Changed
* Updated navigation and generated-output docs to include optional workflow support:
 * `README.md`
 * `START_HERE.md`
 * `INFO.md`
 * `audit_outputs/README.md`
* Updated `.gitignore` to ignore local `.env` secrets while keeping `.env.example` tracked.

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
 * `core/coding_guidelines.md` – deterministic safety coding rules and secure coding practices.
 * `safety/testing_and_verification.md` – test planning, execution and IV&V guidance.
 * `core/configuration_and_risk_management.md` – configuration management and risk management practices.
 * `safety/safety_and_assurance.md` – hazard analysis, safety‑critical software identification and assurance activities.
 * `safety/operations_and_maintenance.md` – operational planning, maintenance and retirement procedures.
 * `templates/` – templates for task headers, hazard logs and review checklists.

### Notes
* The initial release incorporates lessons from rigorous software engineering requirements and safety standards.






