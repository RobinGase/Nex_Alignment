# Testing, Verification and Independent Validation

Testing and verification ensure that the software meets its requirements, functions correctly and performs safely under expected conditions. This protocol requires projects to establish and maintain test plans, procedures and reports. Independent testing and validation (IV&V) are mandatory for higher‑risk software. This section describes how to plan and conduct testing and verification within the **NexGentic Agents Protocol (NAP)**.

## Test planning

1. **Create a test plan early.** Develop a test plan during the planning phase, based on the requirements and architecture. The plan should include test objectives, test types, resources, schedule, entry and exit criteria and responsibilities.
2. **Define test levels.** Organise tests into levels such as:
 * **Unit tests** – test individual functions or modules. Required for Class 1 and above.
 * **Integration tests** – test interfaces between modules and services.
 * **System tests** – test the entire agent system against requirements.
 * **Acceptance tests** – validate that the system meets stakeholder acceptance criteria.
 * **Regression tests** – ensure that new changes do not introduce regressions.
 * **Fault injection and chaos tests** – deliberately introduce faults, latency spikes, resource exhaustion or network partitions to verify fault tolerance. Mandatory for Class 3–4 tasks.
3. **Class‑dependent rigour.** Higher risk classes require more comprehensive testing. For Class 2 tasks, include integration and system tests. For Class 3–4 tasks, implement acceptance tests, stress tests and failure injection (fault tolerance) tests.
 For each class and autonomy tier, define the **minimum required test artefacts** (e.g., test plan, test report, coverage report, IV&V record). Use the `core/risk_tier_artifact_matrix.md` to identify which artefacts must be produced for a given task.
4. **Test environment and configuration management.** Ensure that the test environment (including support software, models, COTS/GOTS and reused components) is under configuration management before testing begins. Document environment details, versions and dependencies in the test plan.

## Test design and execution

1. **Design test cases from requirements.** Each requirement and hazard control identified in `core/requirements_management.md` should have at least one corresponding test case. Use equivalence partitioning, boundary analysis and **negative testing**—design tests that intentionally provide invalid, malicious or adversarial inputs to verify robustness. See `safety/negative_testing_and_red_teaming.md` for techniques such as fuzzing, prompt injection and adversarial example generation.
2. **Test data and inputs.** Generate representative input data, including edge cases. For safety‑critical tasks, test plausible fault scenarios and invalid inputs to confirm that safety controls operate correctly.
3. **Automate tests.** Automate unit and integration tests where possible to facilitate regression testing. Use continuous integration workflows to run tests on every change.
4. **Record results.** Document test results, including inputs, expected outputs, actual outputs, pass/fail status and evidence (logs, screenshots, metrics). Provide a summary in the verification log.
 Include a **reproducibility bundle** containing the random seed, configuration files, model versions and test environment details. This bundle enables reviewers to reproduce the test results precisely and aids in auditability.

## Verification and validation activities

1. **Static analysis.** Perform static analysis on the codebase to detect defects and measure code quality and complexity. Document tool configurations and results.
2. **Code coverage.** Measure code coverage (statement, branch and condition coverage) and track it over time. This protocol requires that code coverage measurements be selected, implemented, tracked and reported. Set coverage goals based on risk class (e.g., ≥80 % for Class 2, ≥90 % for Class 3–4).
 Coverage metrics apply to deterministic code paths. For AI behaviour, use **dataset/prompt coverage** analogs: measure how many unique data slices, prompt patterns or scenario categories are exercised by your evaluation suite. Document prompt coverage and tie it back to requirements and hazards.
3. **Independent Verification and Validation (IV&V).** For Class 3–4 tasks, an independent organisation or team must witness and approve testing. IV&V personnel review requirements, design and implementation and perform their own analysis and tests. Document all IV&V activities and findings.
4. **Peer reviews and inspections.** Conduct peer reviews of code, test cases and test results. Peer review checklists should include compliance with requirements, adherence to coding guidelines and coverage of hazard controls.
5. **Validation on the target platform.** Validate the software on the actual deployment platform or a high‑fidelity simulation to ensure that behaviour in the operational environment matches expectations.
6. **Documentation and reporting.** Compile a verification report summarising test coverage, defects found, defect resolution status, outstanding risks and residual hazards. This report supports readiness reviews and approvals.

## Adversarial evaluation and red teaming

For AI systems, incorporate adversarial evaluation into the verification process. Techniques include fuzzing, prompt injection, adversarial example generation and chaos engineering. Organise formal red teaming exercises to simulate adaptive attacks and identify vulnerabilities. **Define the scope and threat model** for each red team engagement (e.g., which components are in scope, which attack classes are relevant). Document findings, update hazard logs and implement mitigations. Integration of adversarial evaluation is mandatory for Class 3–4 tasks and recommended for Class 2 tasks. See `safety/negative_testing_and_red_teaming.md` for detailed guidance.

## Evaluating AI models and drift monitoring

Traditional software testing methods are insufficient for machine learning models and generative AI systems. Additional evaluation procedures are needed:

1. **Representative evaluation datasets.** Create and maintain datasets representative of the real‑world data the model will encounter. Include edge cases, rare events and ethically sensitive scenarios. Document dataset provenance, bias characteristics and versioning.
2. **Performance and fairness metrics.** Define metrics such as accuracy, precision, recall, F1 score, calibration error and fairness measures (e.g., disparate impact). For LLM agents, include metrics for coherence, factual accuracy and harmful content detection. Track these metrics over time and across different data slices.
3. **Prompt and instruction regression tests.** For generative models, maintain a suite of prompts and expected responses. Run regression tests after model or prompt updates to detect changes in behaviour or alignment. Flag any unacceptable divergences and require review.
4. **Drift monitoring.** Monitor input data distributions and output distributions for signs of data drift, model drift or concept drift. Use statistical methods to detect significant shifts and trigger re‑evaluation or re‑training.
 Examples of drift statistics include the **population stability index (PSI)**, **Kolmogorov–Smirnov (K‑S) statistic** and **Kullback–Leibler divergence**. Define drift thresholds in your policy engine (`runtime/compliance_scoring_and_metrics.md`) and specify whether crossing a threshold triggers a rollback (fail‑closed) or a scheduled review (e.g., retraining within a certain timeframe).
5. **Alignment drift and safety monitoring.** Monitor for undesired model behaviours such as hallucination, bias amplification or security vulnerabilities. Use adversarial testing to probe model robustness. Include safety and ethical criteria in evaluation.
6. **Re‑training and re‑validation.** When drift or performance degradation is detected, update the model with new data and re‑validate it using the full testing process, including hazard analysis and risk classification. Document changes, training data and evaluation results.

Adding these AI‑specific evaluation activities ensures that machine learning and generative components remain reliable and aligned with stakeholder expectations throughout the lifecycle.

## Linking to other sections

* **Risk classification:** Refer to `core/risk_classification.md` for the level of testing required for each class. Class 3–4 tasks require formal IV&V and thorough testing.
* **Requirements management:** Each test case traces back to a requirement in `core/requirements_management.md`. Hazard controls must be verified.
* **Coding guidelines:** Ensure that code subjected to tests adheres to `core/coding_guidelines.md` and that static analysis results are incorporated into the test plan.
* **Configuration and risk management:** Record test artefacts, versions and test environment configurations in `core/configuration_and_risk_management.md`. Track risks and defects found during testing in the risk register and hazard log.
* **Safety and assurance:** Tests for safety‑critical tasks must verify hazard controls and confirm that the system maintains safe states under fault conditions (`safety/safety_and_assurance.md`).
* **Negative testing and red teaming:** Incorporate adversarial testing and red teaming strategies described in `safety/negative_testing_and_red_teaming.md` to probe robustness against malicious inputs and emergent threats.

* **Probabilistic assurance:** Use the guidance in `evaluation/probabilistic_assurance_and_release_metrics.md` to compute confidence intervals, variance and reliability indices for AI models. Incorporate these metrics into test reports and release decisions.

By following this structured testing and verification process, the NAP achieves high confidence that software behaves as intended and meets rigorous safety and assurance standards.






