# Normative vs Reference Guidance

The **NexGentic Agents Protocol (NAP)** contains a mix of normative (mandatory) requirements and reference (recommended or customisable) guidance. Understanding which elements are mandatory and which may be tailored is essential for auditors, implementers and governance tools. This document clarifies how to distinguish normative from reference material and how to manage customisations safely.

## 1. Definitions

* **Normative requirements**: Provisions that MUST be followed for compliance with NAP. These include safety rules, hazard controls, evidentiary artefacts, policy engine behaviours, escalation timeouts and other elements that underpin the assurance model. Changing a normative requirement requires formal governance board approval and may affect certification.
* **Reference guidance**: Recommendations, default values and examples that MAY be customised by organisations. Reference guidance offers sensible starting points but recognises that different domains have different risk appetites, resources and constraints. Deviations from reference guidance MUST be documented, justified and recorded in the assurance graph and risk register.
* **Immutable provisions**: A small subset of requirements that cannot be overridden without revising the protocol itself (e.g., prohibiting autonomy tier A4 for Class 0–2, and allowing A4 for Class 3–4 only under exceptional controls). These provisions are implicitly normative and non‑negotiable.

## 2. Identifying normative content

1. **Normative parameters**: Values in the `core/governance_parameter_registry.md` marked **Normative** MUST be used verbatim unless the governance board approves a change. Examples include baseline scores (`BASELINE_SCORE_CLASS_0…4`), autonomy adjustments (`AUTONOMY_ADJ_A0…A4`), approval thresholds (`T_APP`, `T_REVIEW`, `T_BLOCK`), escalation timeouts and the compliance score threshold (`COMPLIANCE_SCORE_THRESHOLD`).
2. **Mandatory artefacts**: Sections of the protocol that specify artefacts (e.g., hazard logs, risk acceptance forms, trace graphs, proof artefacts) are normative. Projects MUST produce these artefacts, store them in version control and link them in the trace graph.
3. **Policy engine behaviour**: Rules in the enforcement engine and compliance runtime spec (e.g., hard-veto conditions, escalation procedures, fail-closed logic) are normative. Implementations MUST enforce these behaviours without modification.
4. **Risk class and autonomy tier mapping**: The definitions of risk classes, autonomy tiers and the risk–autonomy matrix are normative. Organisations MAY add additional tiers but MAY NOT weaken safety requirements for existing tiers.
5. **Formal verification requirements**: Minimum formal methods by risk and autonomy tier are normative, as defined in `safety/formal_verification_and_runtime_proof.md`. Teams MAY exceed these requirements but MAY NOT skip required formal contracts for high-risk tasks.
6. **Experimental extensions**: Advanced controls explicitly marked as pilot/opt-in (e.g., autonomous governance-agent policy adaptation and runtime dynamic proof gating in `evaluation/ultra_tier_enhancement_blueprint.md`) are reference guidance unless promoted through formal change control.
7. **Use-case profile enforcement**: Profile declaration, profile floor/ceiling checks, composite conflict handling and profile mismatch outcomes are normative runtime behaviors defined by `runtime/use_case_profile_framework.md` and `runtime/compliance_runtime_spec.md`.

## 3. Managing reference content

Reference guidance is provided throughout NAP to aid implementation. When customising reference values or practices:

1. **Document the rationale.** Explain why the default guidance is not adequate and provide evidence (e.g., data distribution analysis, cost–benefit analysis). Link this rationale in the trace graph and risk register.
2. **Update the parameter registry.** When changing reference parameters (e.g., PSI thresholds, reliability weights, drift metrics), update the `core/governance_parameter_registry.md` with new values, a description and justification. This ensures that downstream documents and tools remain consistent.
3. **Maintain safety margins.** Adjustments MUST NOT weaken safety. For example, lowering drift thresholds may be acceptable if the domain is less sensitive, but raising thresholds without justification increases hazard exposure and violates normative guidance.
4. **Audit impacts.** Changes to reference guidance may affect risk scores, gating decisions and monitoring. Recompute relevant metrics, update the unified decision model and run simulations to ensure that the system remains within acceptable risk bounds.
5. **Profile tuning boundaries.** Optional profile additions, operation tag taxonomy tuning and non-normative bundle extensions are reference guidance unless promoted through change control. Tuning MUST NOT relax profile minimum risk floors or autonomy ceilings.

## 4. Normative statements in documents

Most NAP documents include normative statements using keywords such as **MUST**, **SHALL** or **CANNOT**. Reference guidance uses **MAY**, **SHOULD** or **RECOMMENDED**. When reading or implementing NAP:

* Treat **MUST**, **SHALL** and **CANNOT** as mandatory.
* Treat **MAY**, **SHOULD** and **RECOMMENDED** as guidance that can be modified with justification.
* Cross‑reference the parameter registry to verify whether numeric values are normative or reference.

## 5. Change control and documentation

To preserve trust and auditability, all changes to normative or reference guidance must follow the change control process:

1. **Proposal.** Submit a change proposal detailing the parameter or guidance to be modified, the rationale, risk analysis and expected impact.
2. **Review and approval.** The governance board (or designated authority) reviews proposals. Normative changes require consensus and may require external regulator approval. Reference changes require at least one safety officer and one technical lead approval.
3. **Documentation.** Upon approval, update the parameter registry or relevant document, record the change in the assurance graph and hazard log, and include the new values in the version control history.
4. **Communication.** Inform affected teams and update automation (e.g., policy engine rules) to reflect the change. Re-run simulations, tests and risk evaluations to ensure that the change does not introduce unintended consequences.

## 6. Examples

* A team developing a financial AI assistant wants to raise the PSI critical threshold from 0.5 to 0.55. They **MAY** do so because `PSI_CRIT` is a reference parameter. They MUST update `core/governance_parameter_registry.md` with the new value, provide justification (e.g., robust training data, lower exposure), and obtain governance board approval. They MUST NOT reduce safety by raising the threshold if the domain is high risk (e.g., medical diagnostics) without a compelling justification.
* A team building an autonomous drone system wants to lower the autonomy adjustment for A2 tasks to −3 points. Autonomy adjustments are normative parameters (`AUTONOMY_ADJ_A0…A4`). The team MUST submit a deviation request to the governance board. If approved, they MUST update the registry and adjust gating logic. Otherwise the default adjustments remain.

## 7. Summary

Normative vs reference guidance ensures that NAP remains both enforceable and adaptable. Normative requirements define the non‑negotiable safety backbone of the protocol. Reference guidance provides sensible defaults and flexibility. By clearly distinguishing these categories and maintaining a central parameter registry, NAP achieves consistency, auditability and domain‑specific customisation without compromising safety.



