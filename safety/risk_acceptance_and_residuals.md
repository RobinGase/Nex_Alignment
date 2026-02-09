# Risk Acceptance and Residual Risk Management

Not all risks can be eliminated. When hazard controls and mitigation efforts reduce risk but cannot drive it to zero, a formal residual risk acceptance process must be followed. NASA’s Agency Risk Management Requirements (NPR 8000.4C) assigns accountability for risk acceptance decisions to programmatic authorities and Technical Authorities, and requires documentation of the technical basis and rationale. This document adapts those principles for the **NexGentic Agents Protocol (NAP)**.

## Roles and responsibilities

* **Task owner (or project manager):** Leads the task, documents hazards and mitigation measures and proposes residual risk acceptance when necessary.
* **Technical Authority (TA):** A subject‑matter expert independent of the task owner who verifies that the technical basis for accepting residual risk is sound. The TA must concur with the acceptance decision and can elevate dissenting opinions to higher authority.
* **Approving authority:** The individual or board with the authority to accept residual risk. For NAP, this may be the project manager for Class 2 risks, the safety review board or centre director for Class 3 risks, and executive leadership for Class 4 risks. The authority is responsible for ensuring that risk acceptance is consistent with organisational risk policy and mission objectives.

## Residual risk acceptance process

1. **Complete hazard analysis and controls.** Before residual risk can be considered, perform hazard analysis (see `safety/safety_and_assurance.md`) and implement independent controls to reduce hazard severity. For critical hazards, at least two independent controls are required; for catastrophic hazards, three.
2. **Prepare a risk acceptance form.** NAP requires a formal risk acceptance form that captures:
 * Hazard ID(s) and description.
 * Risk class (from `core/risk_classification.md`).
 * Hazard controls implemented and their verification status.
 * Description of residual risk and its potential consequences.
 * Rationale for why residual risk cannot be further reduced.
 * Technical basis for acceptance, referencing design analyses, test results and traceability (`core/traceability_and_documentation.md`).
 * Signatures: task owner, Technical Authority and approving authority. NASA requires documentation of both manager approval and TA concurrence with signatures.
 * Date of acceptance and expiry (residual risk should be revisited periodically or when operating conditions change).
 * Evidence anchors: include digital signatures and hash anchors for the form itself so that acceptance decisions are tamper‑proof (`safety/evidence_anchor_and_log_integrity.md`).
3. **Review and concurrence.** The Technical Authority reviews the form, confirms that all feasible controls have been implemented and concurring evidence is documented. If the TA cannot concur, the issue is escalated to higher authority for resolution.
4. **Approval and recording.** The approving authority signs the form, accepting the residual risk. The signed form becomes part of the configuration baseline and is stored with the hazard log and risk register (`core/configuration_and_risk_management.md`). NASA requires risk acceptance documentation to be maintained and periodically reviewed.
5. **Communication and monitoring.** Communicate the accepted risk to stakeholders, including operators and assurance personnel. Monitor the associated metrics and revisit the acceptance at regular intervals or when conditions change. Periodic review is mandated by NASA to ensure continued acceptability of risk.

## Waivers and deviations

Occasionally, tasks may not meet all protocol requirements due to constraints such as legacy systems, urgent timelines or resource limitations. In such cases, a waiver or deviation request must be submitted:

1. **Describe the protocol requirement being waived.** Identify the specific section of NAP that cannot be fully satisfied (e.g., lack of independent control, incomplete testing).
2. **Justify the request.** Explain why compliance cannot be achieved and provide evidence that the remaining risk is acceptable. Compare the residual risk to organisational risk tolerance.
3. **Obtain approvals.** Waivers and deviations require the same signatures as residual risk acceptances (task owner, Technical Authority and approving authority). Document the start and end dates of the waiver and conditions for its expiration.

Waivers and deviations must be tracked and revisited regularly. If conditions change or additional resources become available, the waiver should be rescinded and the full protocol applied.

## Linking to other sections

* **Hazard analysis and safety assurance:** Residual risk acceptance is only possible after hazard analysis and control verification (`safety/safety_and_assurance.md`).
* **Risk classification:** The risk class of a task influences who can approve residual risk and the stringency of controls (`core/risk_classification.md`).
* **Traceability:** Link residual risk decisions (`RIS-#` identifiers) to requirements, hazards and controls using the traceability framework (`core/traceability_and_documentation.md`).
* **Configuration management:** Store completed risk acceptance forms, waivers and deviations in the configuration management system and risk register (`core/configuration_and_risk_management.md`). Include them in reviews and audits.

By establishing a formal process for residual risk acceptance, NAP aligns with NASA’s expectation that programmatic and technical authorities jointly approve risks, document their decisions and revisit them over time. This transparency ensures that risks are consciously assumed rather than inadvertently incurred.



