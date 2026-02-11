# Federated Governance and Interoperability

As AI systems span organisational boundaries, compliance and safety must be maintained across **ecosystems** rather than within isolated silos. This document introduces a framework for **federated governance** within the **NexGentic Agents Protocol (NAP)**, enabling multiple organisations, suppliers and regulators to share evidence, enforce policies and evolve the protocol cooperatively.

## Rationale

1. **Multi‑organisation value chains.** NIST notes that generative AI systems are built from many third‑party components, including datasets, pre‑trained models and software libraries. As supply chains grow, a single organisation cannot guarantee the integrity of all components.
2. **Regulatory interoperability.** Safety‑critical industries often operate under multiple regulatory frameworks. A federated governance model allows organisations to align their internal practices with external standards (e.g., sector safety standards, ISO 26262) while maintaining a common evidence language.
3. **Survivability and upgradeability.** Governance cannot be static; it must evolve as hazards, regulations and technologies change. Federated governance provides a mechanism for synchronising upgrades across stakeholders.

## Core vs extension modules

To support interoperability, NAP separates governance into **core** and **extension** modules:

* **Core governance.** The minimal set of artefacts, policies and enforcement rules required for safety and compliance (risk classification, traceability schema, hazard logs, residual risk acceptance, enforcement engine, behavioural contracts, telemetry schema). Core modules are stable and versioned. They form the basis for certification and cross‑organisation trust.
* **Extension governance.** Optional modules that add domain‑specific rules (e.g., industry‑specific hazards, privacy requirements) or advanced capabilities (e.g., quantum safety models, adaptive governance agents). Extensions must declare dependencies on core modules and adhere to the same evidence structure.

## Cross‑organisation evidence sharing

1. **Canonical assurance graph exchange.** Use the canonical assurance graph (`core/trace_graph_schema.md`) as the lingua franca for evidence. Organisations exchange portions of their assurance graphs with partners or regulators. Each node and edge carries provenance metadata and digital signatures (`safety/evidence_anchor_and_log_integrity.md`), ensuring authenticity and tamper‑evidence.
 When exchanging evidence, provide a **minimum exchange package** containing:
 * All **requirement**, **hazard**, **formal_contract**, **implementation**, **test**, **risk_acceptance** and **evidence** nodes related to the scope of the exchange.
 * All **edges** connecting these nodes, including `satisfies`, `implements`, `verifies`, `mitigates`, `depends_on` and `supersedes` relationships.
 * A **redaction manifest** listing any nodes or fields that have been redacted (e.g., proprietary code or personal data) and the reason for redaction. Redactions MUST preserve the ability to verify trace continuity; if redaction breaks continuity, provide a summary node linking the remaining graph.
 * A **sensitive evidence policy** stating which types of artefacts (e.g., personally identifiable information, trade secrets) may be redacted and under what conditions. Sensitive artefacts should be represented by cryptographic commitments (hashes) to allow verification without revealing content.
2. **Federated evidence networks.** Establish federated repositories where organisations publish and subscribe to evidence artefacts. Access control policies define who can view or reference evidence. Use distributed ledger technologies for shared state if required.
3. **Trusted attestation.** Each organisation attests to the authenticity of its evidence and enforcement components (`runtime/enforcement_and_policy_engine.md`). Attestations are chained to a trust root managed by a governance consortium.

## Cross‑domain policy compatibility

1. **Policy mapping.** Provide mappings between NAP policies and external standards (e.g., sector baseline standards, ISO / IEC 25010). Use transformation rules to translate requirements and hazards between frameworks. Document equivalence classes in extension modules.
2. **Runtime interoperability.** When agents from different organisations interact, policy engines must negotiate enforcement rules. Use a handshake protocol where agents exchange their autonomy tiers, risk classes and behavioural contracts. The most restrictive combination of policies is applied.
 In the event of incompatible policies (e.g., one agent permits an action that another prohibits), the default behaviour MUST be **fail‑closed**: reject the action and trigger escalation. Governance boards may subsequently negotiate a resolution, but execution cannot proceed until a compatible policy exists.
3. **Conflict resolution.** In cases where policies conflict (e.g., different acceptable risk levels), require escalation to human governance boards. Record decisions in residual risk acceptance forms (`safety/risk_acceptance_and_residuals.md`).
 Organisations SHOULD establish a **highest‑safety‑wins** rule: when two policies prescribe different levels of control, the stricter control MUST take precedence. Only a joint governance board may authorise deviations, and such decisions MUST be documented and attached to the assurance graph.

## Governance upgrade survivability

1. **Versioned modules.** Core and extension modules are versioned. Upgrades are proposed via governance change requests, reviewed by a cross‑organisation board and recorded in the assurance graph. Organisations can adopt new versions at their own pace while maintaining compatibility through version mapping.
2. **Backward compatibility.** Define deprecation schedules and compatibility guarantees. Provide migration guides and tooling to transform artefacts from old schemas to new ones.
3. **Resilient enforcement.** Ensure the enforcement engine can load multiple policy versions concurrently and apply the correct version based on the evidence’s version metadata. Provide fallback rules when encountering unknown policy versions (fail‑closed where safety is concerned).

## Linking to other sections

* **Trace graph and evidence:** The canonical assurance graph enables federated exchange (`core/trace_graph_schema.md`). Evidence anchor and log integrity are essential for trust (`safety/evidence_anchor_and_log_integrity.md`).
* **Ultra‑tier enhancements:** See `evaluation/ultra_tier_enhancement_blueprint.md` for cross‑organisation extensions such as consensus protocols and trust roots.
* **Economic and societal impacts:** Cross‑organisation collaboration affects cost and societal risk; incorporate multi‑stakeholder trade‑off analysis from `evaluation/economic_and_performance_risk_modeling.md`.
* **Strategic survivability:** Adoption of federated governance ensures that NAP survives beyond the boundaries of a single organisation and can adapt to global safety needs.

By formalising federated governance and interoperability, NAP becomes a **global framework** capable of spanning supply chains, industries and regulatory ecosystems. Core modules provide stability and trust, while extensions allow flexibility and evolution. Cross‑organisation evidence sharing and policy negotiation ensure that safety and accountability survive even as AI systems cross organisational boundaries.





