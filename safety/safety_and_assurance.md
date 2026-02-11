# Safety, Hazard Analysis and Software Assurance

Established software assurance and safety standards provide requirements for systematic software assurance, software safety, and Independent Verification and Validation (IV&V). Safety assurance aims to ensure that software systems are safe, secure, and conform to requirements. Hazard analysis identifies potential conditions that could lead to mishaps and defines controls. This section describes how to incorporate these practices into the **NexGentic Agents Protocol (NAP)**.

## Hazard analysis

1. **Define hazards and mishaps.** A hazard is a potential risk situation that can result in or contribute to a mishap. A mishap is an accident resulting in injury, loss of life, damage to equipment or mission failure.
2. **Identify hazard causes.** For each hazard, list the causes (e.g., software failure, operator error, hardware fault). Determine whether software can directly cause the hazard, provide control for the hazard or supply safety‑critical information. Software is safety‑critical if it meets any of these criteria. **Include system interaction hazards**, such as emergent behaviour in multi‑agent systems, unsafe tool chaining or user misuse. Identify how multiple agents or components could interact in unexpected ways to create hazards and document these interactions in the hazard log.
3. **Determine hazard severity.** Categorise hazards as **catastrophic**, **critical**, **marginal** or **negligible** based on their worst‑case effect (loss of life, severe injury, mission failure, etc.).
4. **Implement hazard controls.** For each hazard cause, identify design controls, procedural controls and operational controls that prevent or mitigate the hazard. Critical hazard causes require at least two independent controls; catastrophic hazard causes require three. **Independence of controls** means that no single failure mode or common cause can defeat all layers: each control should have distinct mechanisms or failure modes. Consider diverse redundancy (different algorithms, hardware or operators) to prevent common‑mode failures.
5. **Verify hazard controls.** For each control, specify verification activities (tests, inspections, analyses) and acceptance criteria. Document evidence in the hazard log and test reports.
6. **Update during the life cycle.** Perform hazard analysis early in the requirements phase and revisit it after design changes, code implementation and test results. Treat hazard analysis as a living document.

7. **Safety margins.** Define safety margins or safety factors for critical parameters (e.g., acceleration limits, temperature thresholds, timeouts) to provide a buffer between normal operation and hazardous conditions. Where feasible, justify these margins quantitatively using empirical data, simulations or statistical analysis. Document the rationale and verify that the system operates within the defined margins during testing and monitoring.

## Safety‑critical software identification

1. **Determine safety‑critical components.** Identify modules, functions or subsystems that directly control or monitor hardware with hazards, implement hazard controls or provide safety‑critical data. Even off‑line software (e.g., simulations) can be safety‑critical if it supports hazard analysis or flight operations.
2. **Classify risk based on safety criticality.** Safety‑critical software must be handled as Class 3 or 4 in `core/risk_classification.md`. Document safety‑critical status in the task header and trace requirements, design, tests and code to safety controls.

## Software assurance activities

1. **Software assurance planning.** Develop a software assurance plan for Class 3–4 tasks, either standalone or integrated into the project plan. The plan should cover process compliance, product quality, safety assurance, security assurance and IV&V participation.
2. **Assurance participation.** Assurance personnel participate in developing software management and development plans, requirements reviews, design reviews, code inspections, test readiness reviews, and acceptance reviews.
3. **Independent Verification and Validation (IV&V).** IV&V personnel evaluate process compliance and product quality independently. Their findings are documented and provided to decision makers. IV&V may perform hazard analyses, requirements traceability analysis and independent testing.
4. **Security assurance.** Evaluate security requirements, threat models and design. Confirm that the system implements appropriate access controls, encryption, input validation and secure coding practices. Use vulnerability assessments and penetration testing.
5. **Record and report.** Maintain records of assurance activities, hazards, controls and verification evidence. Provide assurance status updates at project reviews and maintain the hazard log.

6. **Independent safety review.** For Class 3–4 tasks, conduct a formal safety review independent of the development team. Reviewers must not be in the same reporting line as the developers to avoid conflicts of interest. They should come from a safety assurance organisation or an independent verification body. The safety review assesses hazard analysis, safety cases, design controls and test evidence. Record findings, required actions and sign‑offs.

## Safety case

For Class 3–4 tasks, prepare a **safety case** that provides a structured justification of why the system is acceptably safe in its intended context. A safety case is more than a checklist; it communicates the reasoning and evidence supporting safety. At a minimum, the safety case must contain:

* **Claims** – statements about system properties (e.g., “The autonomous agent cannot issue commands that exceed safe speed limits”).
* **Arguments** – logical reasoning that links evidence to claims. Arguments often decompose a claim into sub‑claims and show how the evidence supports each part.
* **Evidence** – artefacts such as test reports, hazard analyses, formal proofs or static analysis results that substantiate the claims.
* **Assumptions** – environmental, operational or user assumptions upon which the claims depend (e.g., “Operators will monitor alerts within 5 seconds”).
* **Residual risk statement** – description of residual risks that remain after controls and mitigations, with references to the formal acceptance records (`safety/risk_acceptance_and_residuals.md`). Include the sign‑offs of the authorities who accepted the residual risks.

Safety cases provide a single artefact that regulators, auditors and reviewers can examine to understand how safety has been argued and demonstrated. Update the safety case whenever new hazards, mitigations or evidence emerge.

## Hazard log

The hazard log is a central record of hazards, hazard causes, controls, verification status and closure. Use the template provided in `templates/hazard_log_template.md` to document each hazard. The log should include:

* Hazard description and severity classification.
* Software components involved.
* Hazard causes and associated risk class.
* Controls implemented (design, procedural, operational).
* Verification activities and results.
* Residual risk acceptance and authority sign‑off.

## Human‑in‑the‑loop and kill‑switch patterns

The NIST AI Risk Management Framework emphasises the need to define human roles and responsibilities when overseeing AI systems. Human oversight helps mitigate biases and ensures accountability. Incorporate the following patterns into safety analysis:

1. **Role definition.** Specify which decisions the AI can perform autonomously and which require human approval. Document the authority of operators and approvers in the task header and hazard log.
2. **Kill‑switch implementation.** Provide mechanisms for operators to halt AI actions immediately when unsafe conditions or anomalous behaviour are detected. Kill‑switches should be physically or programmatically accessible, clearly labelled and tested regularly.
3. **Escalation and override procedures.** Define escalation paths when the AI system encounters high uncertainty or emergent behaviour. Operators must be able to override AI decisions and record the rationale for review. Collect data on overrides to improve models and adjust trust calibration.
4. **Operator training and cognitive load.** Train operators to understand AI limitations, uncertainty indicators and potential biases. Design user interfaces to prioritise critical alerts and minimise cognitive overload. Provide clear explanations of AI outputs to support informed decisions.
5. **Bias awareness.** Recognise that human cognitive biases can affect decisions throughout the AI lifecycle. Provide training and mitigation strategies to ensure that human interventions improve safety and fairness.

These human‑in‑the‑loop mechanisms complement hazard controls and assurance activities by ensuring meaningful human control and the ability to shut down or correct AI systems when necessary.

## Residual risk acceptance and traceability

Hazard analysis may reveal risks that cannot be completely eliminated. In such cases, NAP requires a formal residual risk acceptance process (`safety/risk_acceptance_and_residuals.md`). Residual risk decisions must be documented in the hazard log and linked to hazards, controls and requirements via unique identifiers defined in the traceability framework (`core/traceability_and_documentation.md`). Signatures from the task owner, Technical Authority and approving authority provide accountability and ensure that risks are consciously accepted rather than overlooked.

### Residual risk escalation and authority

Residual risks are not all equal in severity. NAP defines an escalation path to ensure that the appropriate authority reviews each acceptance:

* **Low and medium residual risks:** may be accepted by the project manager or task owner in consultation with the safety officer and documented in the hazard log.
* **Critical residual risks (Class 3):** must be accepted by the project manager with concurrence from the Technical Authority. The acceptance record should specify the residual risk ID, rationale, mitigation attempts and an expiry or re‑evaluation date.
* **Catastrophic residual risks (Class 4):** require acceptance by a higher‑level authority (e.g., centre director, governance board or safety review board) with concurrence from the Technical Authority and safety assurance organisation. Catastrophic acceptance must demonstrate that all feasible controls have been applied, that multiple independent mitigations exist and that the risk is being actively monitored.

Document all residual risk acceptance decisions, signatures and dates in the risk register and hazard log. Periodically review residual risks to determine if they can be further mitigated or closed.

## Evidence anchoring

Safety assurance relies on trustworthy evidence. To protect hazard logs, assurance reports and test results from tampering, sign these artefacts using digital signatures and maintain hash chains as described in `safety/evidence_anchor_and_log_integrity.md`. Cryptographic anchoring ensures that verification evidence remains authentic and tamper‑proof.

## Linking to other sections

* **Risk classification:** Risk classes defined in `core/risk_classification.md` determine when hazard analysis and software assurance are required. Class 3–4 tasks always require hazard analysis and independent verification.
* **Requirements management:** Capture safety requirements and hazard controls during requirements elicitation (`core/requirements_management.md`). Each hazard and control must trace back to a requirement.
* **Architecture and design:** Design the architecture to separate safety‑critical functions and implement independent hazard controls (`core/architecture_design.md`).
* **Coding guidelines:** Implement hazard controls using robust coding practices and assert safety‑critical invariants (`core/coding_guidelines.md`).
* **Testing and verification:** Plan tests to verify hazard controls, including fault injection and stress tests (`safety/testing_and_verification.md`). IV&V activities support verification of safety requirements.
* **Configuration and risk management:** Record hazards and controls in the risk register (`core/configuration_and_risk_management.md`) and maintain versioned hazard logs.

By systematically performing hazard analysis, identifying safety‑critical software and executing assurance activities, NAP aligns with the objective to ensure that software systems are safe, secure and compliant with requirements.






