# Machine‑Readable Traceability Graph Schema

To enable automated assurance and continuous compliance, the **NexGentic Agents Protocol (NAP)** defines a machine‑readable schema for representing the traceability graph described in `core/traceability_and_documentation.md`. A standard data model allows tools to exchange, validate and visualise trace information programmatically, supporting audits and policy engines. This document specifies the schema using JSON and outlines an example.

## Schema overview

The traceability graph is composed of **nodes** and **edges**. Nodes represent artefacts (requirements, design elements, code units, test cases, hazards, controls, residual risk decisions, evidence, formal contracts and proofs). Edges represent relationships (e.g., satisfies, implements, controls, mitigates, traces to). Each node and edge is assigned a globally unique identifier.

### Node definition

A node is a JSON object with the following fields:

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique identifier (e.g., `REQ-1`, `TST-5`, `HAZ-2`). |
| `type` | string | Artefact type: `requirement`, `design`, `code`, `test`, `hazard`, `control`, `risk`, `risk_acceptance`, `evidence`, `runtime_monitor`, `formal_contract`, `proof`, `policy`, `attestation`, `operational_feedback`. |
| `title` | string | Human‑readable title. |
| `description` | string | Detailed description of the artefact. |
| `attributes` | object | Additional metadata specific to the artefact type (e.g., severity for hazards, version for code). |
| `links` | array of strings | List of edge IDs originating from this node. |

The additional node types support lifecycle continuity and formal assurance workflows:

* `formal_contract`, `proof`: represent formal specifications and proof artefacts (see `safety/formal_verification_and_runtime_proof.md`).
* `risk_acceptance`, `policy`, `attestation`: represent governance decisions and integrity evidence.
* `operational_feedback`: links runtime observations back to requirements and hazards.

### Edge definition

An edge is a JSON object with the following fields:

| Field | Type | Description |
|---|---|---|
| `id` | string | Unique identifier (e.g., `EDGE-12`). |
| `relation` | string | Relationship type. NAP defines a canonical set of relationship types: `satisfies` (design or code fulfils a requirement), `implements` (code realises a design element), `verifies` (tests or analysis confirm a requirement or control), `controls` (hazard control applies to a hazard), `mitigates` (artefact reduces risk), `derives_from` (one artefact is produced from another), `depends_on` (artefact depends on another), `supersedes` (artefact replaces an earlier version) and `traces_to` (generic trace link). Tools should validate that edges use only recognised relationship types. |
| `from` | string | ID of the source node. |
| `to` | string | ID of the target node. |
| `evidence` | string (optional) | Reference to evidence artefacts (e.g., report IDs) supporting this relationship. |

### Graph definition

A traceability graph is a JSON object with two top‑level arrays: `nodes` and `edges`:

```json
{
 "nodes": [
 {
 "id": "REQ-1",
 "type": "requirement",
 "title": "System shall authenticate users",
 "description": "Only authenticated users may access the system.",
 "attributes": {
 "risk_class": 2
 },
 "links": ["EDGE-1", "EDGE-2"]
 },
 {
 "id": "TST-1",
 "type": "test",
 "title": "Authentication unit test",
 "description": "Verifies that the system rejects unauthenticated requests.",
 "attributes": {
 "status": "passed"
 },
 "links": ["EDGE-1"]
 }
 ],
 "edges": [
 {
 "id": "EDGE-1",
 "relation": "verifies",
 "from": "TST-1",
 "to": "REQ-1",
 "evidence": "TEST-REPORT-2025-001"
 },
 {
 "id": "EDGE-2",
 "relation": "satisfies",
 "from": "DES-1",
 "to": "REQ-1"
 }
 ]
}
```

This machine‑readable schema enables:

* **Automatic validation and completeness checks.** Tools can verify that every requirement node has at least one incoming `satisfies` edge and one incoming `verifies` edge.

 **Bidirectional trace completeness.** For every edge, there must exist complementary relationships that allow traversing the graph upstream and downstream. For example, if a test `verifies` a requirement, tools should also be able to find the requirement from the test. Validate that requirements have upstream `satisfies` or `implements` edges from design/code artefacts and downstream `verifies` edges from tests and that hazards link to controls and verification evidence.
* **Impact analysis.** When a node changes, downstream and upstream artefacts can be identified programmatically.
* **Integration with policy engines.** The enforcement engine can parse the graph to confirm that required artefacts exist before allowing state transitions (`runtime/enforcement_and_policy_engine.md`).
* **Visualisation and reporting.** Graph databases and visualisation tools can display the trace graph for reviewers and auditors.

* **Reproducibility and package export.** Tools can export a subset of the graph (e.g., all nodes and edges related to a release) along with evidence artefacts into a reproducibility package, as described in `safety/evidence_anchor_and_log_integrity.md`. This ensures that auditors can reconstruct the full chain of requirements, designs, implementations, tests and outcomes associated with a deployment.

## Schema representation

While the above example illustrates a JSON representation, organisations may choose alternative formats such as YAML or GraphML. The key is that the schema captures nodes, edges and relationships in a structured, machine‑interpretable form. This specification should be version‑controlled and accompanied by validation scripts to ensure consistency.

## Linking to other sections

* **Traceability and documentation:** The schema formalises the conceptual model described in `core/traceability_and_documentation.md` and supports automated tooling.
* **Policy engine:** Use the graph as input to policy checks in `runtime/enforcement_and_policy_engine.md`.
* **Compliance telemetry:** Metrics on graph completeness and health can feed into compliance monitoring (`runtime/compliance_telemetry_and_governance_drift.md`).

By publishing a machine‑readable traceability graph schema, NAP enables tool interoperability, automated validation and advanced analysis, moving the protocol closer to a fully self‑auditing system.



