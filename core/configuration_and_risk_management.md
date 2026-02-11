# Configuration Management and Risk Management

NASA requires software projects to implement configuration management (CM) plans and risk management processes to ensure the completeness and correctness of software items. CM protects the integrity of project artefacts over time, while risk management identifies and mitigates threats to the project and mission. This section describes how to perform these functions within the **NexGentic Agents Protocol (NAP)**.

## Configuration management

1. **Define configuration items (CIs).** Identify all artefacts to be controlled, including source code, requirements documents, architecture and design documents, test plans, models, data sets, compiled binaries and third‑party libraries (COTS/GOTS). For each CI, assign a unique identifier and maintain version history.
2. **Version control system (VCS).** Use a VCS (e.g., Git) to store and manage CIs. Commit changes frequently with descriptive messages. Tag releases or baselines according to risk class and deliverable milestones.
3. **Change control and reviews.** All changes to CIs must follow a change control process. For Class 2–4 tasks, require peer review and approval before merging changes. Document the rationale, impacted artefacts and test results associated with each change.
4. **Configuration status accounting.** Maintain a CM database or manifest that records the current version of each CI, its status (draft, approved, released), and relationships to other CIs. Provide traceability from requirements to code and tests.
5. **Baseline, release and rollback management.** Establish baselines (approved snapshots) at key points (e.g., after requirement sign‑off, after design review, before deployment). Releases should only contain approved CIs and must include release notes summarising changes, new features, defects fixed and known issues. Each baseline should include a named **approval artefact** (e.g., change approval record) with signatures from the responsible owner and safety officer. Baseline records ensure traceability of who authorised a configuration state and support audits.

 **Rollback capability.** For each release, define rollback procedures and validate them through periodic testing (e.g., practice rolling back to the previous release in a test environment). Ensure that rollback procedures restore all configuration items (code, data, models and dependencies) and that dependent systems continue to operate correctly. Untested rollback plans provide a false sense of security and may fail under stress.
6. **Configuration audits.** Periodically audit the configuration to ensure that all CIs are present, correct and consistent. For Class 3–4 tasks, involve independent auditors and record audit findings.

7. **Evaluation datasets and prompt suites.** Treat evaluation datasets (including test data and prompt suites) as configuration items. Version control them alongside code and models, and document changes. Maintain a single source of truth for evaluation artefacts so that test results are reproducible. This requirement ensures that improvements or regressions are measured against a stable baseline rather than shifting datasets.

## Risk management

1. **Identify risks.** Continuously identify technical, programmatic and safety risks throughout the life cycle. Sources include requirement volatility, architectural complexity, technology maturity, resource limitations, schedule pressure, defects, security vulnerabilities and hazards. Use **threat modeling** to identify adversarial, misuse and misuse resistance scenarios and conduct **failure injection exercises** (e.g., chaos testing, fault injection) to reveal latent failure modes and systemic weaknesses. Document findings and feed them into the risk register and hazard analysis.
2. **Assess probability and impact.** Rate each risk’s likelihood and consequence (e.g., low/medium/high). Use qualitative or quantitative scales. Consider the risk’s effect on cost, schedule, performance and safety.
3. **Plan mitigation actions.** For each risk, define one or more mitigation actions (e.g., additional testing, design changes, redundancy, schedule buffer). Assign an owner responsible for implementing the mitigation.
4. **Track and communicate.** Maintain a risk register that records risk descriptions, classifications, mitigation actions, status and closure criteria. Review the risk register at regular intervals and at major reviews. Update risk statuses based on mitigation progress and residual risk.
 Assign each risk and hazard a **unique identifier** to support traceability. Track an **aging metric** (how long each risk has remained open) and flag risks that remain unresolved across releases. Unresolved risks may only persist beyond a release with explicit approval from the risk acceptance authority.
5. **Integration with hazard analysis.** Many hazards identified in `safety/safety_and_assurance.md` will appear in the risk register. However, risk management covers a broader set of threats, including cost and schedule risks. Ensure that safety‑critical hazards have mitigation plans that include independent controls.
6. **Escalation and acceptance.** When a risk cannot be reduced to an acceptable level, document it and obtain formal acceptance from the appropriate authority (e.g., project manager or safety board). For critical hazards, at least two independent controls or mitigations must exist before accepting residual risk.
 **Risk acceptance criteria must be defined and approved** prior to evaluation. Define acceptable probability/impact thresholds for each risk class and document them in the risk register. Do not adjust criteria post‑hoc to justify acceptance.

7. **Evidence anchoring and log integrity.** Protect the integrity of risk registers, change logs and configuration baselines by signing them with digital signatures and maintaining hash chains as described in `safety/evidence_anchor_and_log_integrity.md`. Anchored logs support audits, provide tamper evidence and build trust in recorded decisions.

## Model and data versioning, provenance and supply chain

AI systems rely on datasets and models that evolve over time. Poorly controlled data and model changes can introduce errors, bias or security vulnerabilities. Therefore:

1. **Dataset versioning and provenance.** Treat datasets as configuration items. Assign version identifiers to datasets and document how they were collected, processed and labelled. Record ML‑oriented metadata such as bias notes, provenance and quality status. Use the configuration management system to control dataset updates and maintain a single source of truth.
2. **Model versioning and pinning.** Store model artifacts (weights, configurations, training scripts) in version control. Use semantic versioning to track major, minor and patch changes. Pin production systems to specific model versions to ensure reproducibility and enable rollback.
 In addition to model version identifiers, record a **training data hash or lineage reference** and a **training configuration snapshot** (hyper‑parameters, software versions, random seeds). Capturing the exact training lineage helps diagnose differences in model behaviour and supports reproducibility.
3. **Third‑party and supply chain risk.** When using third‑party AI services, pre‑trained models or open‑source libraries, document their provenance, licensing, security status and version. Assess potential risks associated with model extraction, membership inference or other AI‑specific attacks.
4. **Dependency management.** Control dependencies such as machine learning frameworks, libraries and hardware drivers. Record versions and update them through the change control process. Monitor for security advisories and apply patches promptly.
5. **Data and model deprecation.** Plan for deprecating outdated datasets and model versions. Document dependencies and ensure that older versions can be archived and reproduced for audit purposes.

By managing datasets and models as first‑class configuration items with proper provenance and versioning, you reduce the risk of drift, bias and reproducibility issues.

## Residual risk tracking and acceptance

When risks cannot be fully mitigated, record them in the risk register along with mitigation actions, hazard controls and residual risk IDs. Follow the formal residual risk acceptance process (`safety/risk_acceptance_and_residuals.md`) to document rationale, obtain signatures from the task owner, Technical Authority and approving authority and specify expiry dates. Link each residual risk to the relevant requirements and hazards using the traceability framework (`core/traceability_and_documentation.md`). Update the risk register when residual risks are re‑evaluated or closed.

## Linking to other sections

* **Risk classification:** Use `core/risk_classification.md` to guide the rigor of configuration and risk management. Higher risk classes require stricter change control, more frequent audits and more detailed risk tracking.
* **Requirements, architecture and coding:** Configuration management covers artefacts produced in `core/requirements_management.md`, `core/architecture_design.md` and `core/coding_guidelines.md`. All changes to these artefacts must go through change control.
* **Testing and verification:** Record test artefacts, results and scripts under CM. Track risks identified during testing and verification (`safety/testing_and_verification.md`).
* **Safety and assurance:** Hazards and hazard controls from `safety/safety_and_assurance.md` must be logged in the risk register. Safety‑critical software changes require additional review and approval before configuration changes are released.

By implementing robust configuration and risk management, NAP ensures that software artefacts remain consistent and controlled while proactively addressing threats to success, aligning with NASA’s disciplined processes.



