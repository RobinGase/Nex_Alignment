# Requirements Management and Hazard Analysis

Proper requirements capture is a foundational step in any software project. Industry experience shows poor requirements elicitation and management as one of the most common sources of software problems. This section guides you in defining, validating and tracking requirements for agent tasks, including hazard analysis and safety‑critical classification.

## Elicit and document requirements

1. **Identify stakeholders and sources.** List everyone affected by the agent’s outcome (users, operators, safety officers, customers). Include regulatory documents or standards that impose constraints. Make sure to engage stakeholders early so that safety and mission requirements are captured upfront..
 Include security and privacy stakeholders (e.g., information security leads, data protection officers) when handling sensitive data or AI systems; their requirements influence risk classification and controls.
2. **Write clear, concise requirements.** Each requirement should be:
 * **Necessary:** Derived from stakeholder needs or hazard controls.
 * **Unambiguous:** Written in language understandable to all parties.
 * **Testable or verifiable:** Able to be verified through inspection, analysis or testing. Some requirements are satisfied by analysis (e.g., proving an invariant) rather than executable tests.
 * **Traceable:** Assigned a unique identifier and linked to higher‑level requirements and to design and test artifacts.
3. **Use a requirements taxonomy.** Categorise requirements as functional, performance, interface, safety, security, usability, data integrity or regulatory. For safety‑critical software (Class 3–4 tasks), explicitly capture hazard control requirements and assumptions.
 Include **operational requirements** covering monitoring, incident response, rollback and maintenance. These influence operational readiness and risk classification.
4. **Capture assumptions and environment.** Document environmental assumptions (e.g., network connectivity, user roles, physical context) in the task header. These assumptions influence both safety and risk classification and must be validated during planning and testing.

## Validate and verify requirements

1. **Peer review.** Perform peer review of requirements before design begins. Independent review helps identify ambiguities and missing safety constraints.
2. **Feasibility analysis.** For each requirement, assess feasibility with respect to available resources and risk class. Consider whether off‑the‑shelf (COTS/GOTS) software will be used; This protocol requires that requirements be established for all components, including COTS and open‑source.
 When using COTS or GOTS, document the vendor’s update policy, vulnerability disclosure process and contractual obligations to ensure that supply chain risks are addressed.
3. **Hazard analysis integration.** Cross‑reference each requirement with the hazard log. For Class 3–4 tasks, perform hazard analysis to identify potential hazards and hazard causes (see `safety/safety_and_assurance.md`). Ensure that at least two independent controls are identified for critical hazards and three for catastrophic hazards.
 Refer to `safety/safety_and_assurance.md` for the definitions of **critical** and **catastrophic** hazards; classification of hazards determines the number of controls and the severity of residual risk.
4. **Validation.** Validate that the set of requirements will achieve the stakeholder’s goals when satisfied, and that no conflicting requirements exist. For safety‑critical tasks, verify that safety constraints mitigate identified hazards.
 When conflicts arise, document them in a conflict matrix. Establish priority rules (e.g., safety > legal compliance > mission objectives > user experience) to guide resolution. Record the rationale for prioritisation and link it to the trace graph.
5. **Establish acceptance criteria.** Define clear, measurable criteria for each requirement that will be used to determine completion during testing and review.

## Handling requirement volatility and conflicts

AI projects often encounter rapidly changing requirements, emergent behaviours and conflicting stakeholder objectives. To manage these challenges:

1. **Version control and history.** Maintain a version history of requirements documents. When requirements change, record the rationale, author and impact analysis. Use the configuration management process (`core/configuration_and_risk_management.md`) to control updates.
 Establish a baseline requirements set for each release or approval. Audits should reference the baseline to understand what was considered “truth” at the time of approval.
2. **Impact analysis.** Analyse how requirement changes affect design, implementation, testing and hazard analysis. Re‑classify risk and update hazard controls if necessary.
3. **Conflict resolution.** When stakeholders have conflicting requirements, facilitate structured discussions to identify trade‑offs and prioritise safety, legal compliance and ethical considerations. Document the resolution and affected requirements.
4. **Emergent behaviours.** For AI systems, capture unexpected behaviours observed during testing or deployment as new requirements or hazards. Add them to the emergent behaviour register in `safety/ai_specific_considerations.md` and adjust requirements accordingly.
 Treat emergent behaviours as potential hazards. Perform severity triage to decide whether an emergent behaviour warrants an immediate risk class upgrade, a new requirement or an entry in the backlog. Severity triage should consider impact, likelihood and exposure.

## Mechanism for emergent AI behaviours

AI systems may exhibit behaviours not anticipated during initial design. To address emergent behaviours:

1. **Monitor outputs and anomalies.** During testing and operation, monitor AI outputs for anomalies or unexpected patterns. Record these as emergent behaviours.
2. **Feed back into requirements.** Analyse emergent behaviours to determine whether they reveal missing requirements or safety constraints. Incorporate new requirements or hazard controls and update test plans.
3. **Iterative refinement.** Treat the requirements document as a living artefact, updated through the lifecycle as the AI system interacts with new data and environments.

## Traceability and change management

1. **Bidirectional traceability.** Maintain traceability from each requirement to its origin (e.g., stakeholder need, hazard control) and forward to architecture components, test cases and verification results. This protocol requires bidirectional traceability to ensure that all requirements are implemented and tested.
2. **Change control.** Document all changes to requirements in the configuration management system (`core/configuration_and_risk_management.md`). Re‑evaluate hazard analysis and risk classification whenever requirements change.
3. **Metrics and measurement.** Track the number of requirements, open versus closed actions, and satisfaction status. These metrics provide insight into project progress and risk.
 In addition, track safety metrics such as the number of **open hazards**, **unverified controls** and **requirements without test coverage**. Use these metrics to guide verification priorities and to inform compliance scoring (`runtime/compliance_scoring_and_metrics.md`).

## Linking to other sections

* **Risk classification:** Use `core/risk_classification.md` to determine the risk class based on the potential impact of unmet requirements. Higher‑risk tasks require more thorough requirements review and hazard analysis.
* **Architecture and design:** Translate validated requirements into architectural components (`core/architecture_design.md`). Trace each requirement to a module or subsystem to ensure coverage.
* **Testing and verification:** Develop test cases and acceptance tests from requirements (`safety/testing_and_verification.md`). Each test should trace back to at least one requirement.
* **Safety and assurance:** For safety‑critical requirements, coordinate with the safety and assurance process (`safety/safety_and_assurance.md`) to identify hazard controls and verification strategies.

By systematically eliciting, documenting, validating and tracing requirements, you create a strong foundation for design, implementation and testing, reducing the likelihood of expensive rework later in the life cycle.





