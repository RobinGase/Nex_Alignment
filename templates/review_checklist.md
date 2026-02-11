# Review Checklist Template

Use this checklist to guide peer reviews, independent verification and validation (IV&V) activities. Tailor the checklist according to the risk class and the artefacts being reviewed (requirements, design, code, tests).

```md
## General
* [ ] Does the task header correctly state the goal, risk class and stakeholders?
* [ ] Are all assumptions, constraints and environment conditions documented?
* [ ] Are all requirements clear, complete, testable and traceable?
* [ ] Are changes logged in the configuration management system?
* [ ] Has a traceability matrix been created or updated (`core/traceability_and_documentation.md`)?
* [ ] Are dataset and model provenance, versioning and SBOM information recorded and verified (`safety/model_and_data_supply_chain_security.md`)?

## Requirements Review
* [ ] Do the requirements cover all stakeholder needs and hazard controls?
* [ ] Are safety and security requirements identified for safety‑critical tasks?
* [ ] Are requirements free from ambiguity and contradictions?
* [ ] Is bidirectional traceability established between requirements and downstream artefacts?

## Architecture and Design Review
* [ ] Is the architecture documented with context diagrams and module decompositions?
* [ ] Are interfaces clearly defined and validated?
* [ ] Does the design address all requirements and hazard controls?
* [ ] Are design decisions and trade studies recorded?
* [ ] Are modules designed for testability, modifiability and maintainability?
* [ ] Have autonomy tiers and human oversight requirements been defined in the design (`core/agent_autonomy_and_human_oversight.md`)?

## Code Review
* [ ] Does the code adhere to the coding guidelines (deterministic safety coding rules, secure coding practices)?
* [ ] Are functions small, with simple control flow and bounded loops?
* [ ] Are all parameters validated and return values checked?
* [ ] Are assertions used appropriately to enforce invariants?
* [ ] Does the code handle errors and resource management correctly?
* [ ] Are static analysis warnings addressed and documented?

## Testing and Verification Review
* [ ] Is there a test plan covering unit, integration, system and acceptance tests as appropriate?
* [ ] Do test cases trace to requirements and hazard controls?
* [ ] Are test environments controlled and documented?
* [ ] Are code coverage metrics collected and meeting targets?
* [ ] Are IV&V activities documented and findings addressed?
* [ ] Are negative testing, adversarial evaluation and red teaming incorporated into the test plan where appropriate (`safety/negative_testing_and_red_teaming.md`)?

## Safety and Hazard Review
* [ ] Are hazards identified, analysed and recorded in the hazard log?
* [ ] Are hazard controls adequate, independent and verified?
* [ ] Is residual risk acceptance documented and approved by the proper authority?
* [ ] Are risk acceptance forms and waivers attached and signed (`safety/risk_acceptance_and_residuals.md`)?
* [ ] Are evidence logs, hazard logs and test reports cryptographically anchored and verifiable (`safety/evidence_anchor_and_log_integrity.md`)?
* [ ] Are autonomy tiers appropriately matched to risk classes and do human-in-the-loop mechanisms exist (`core/agent_autonomy_and_human_oversight.md`)?

## Operations and Maintenance Review
* [ ] Are operational procedures documented and validated?
* [ ] Are monitoring and incident response mechanisms in place?
* [ ] Are maintenance plans, including patching and upgrade strategies, defined?
* [ ] Are retirement plans and archival procedures established, if applicable?

## Outcome
* [ ] All major findings have been addressed.
* [ ] The product meets acceptance criteria and is ready for the next phase.
* [ ] Follow‑up actions (if any) are documented with owners and due dates.
```

Store completed checklists with the reviewed artefacts for traceability. Use them to provide assurance evidence during audits and reviews.




